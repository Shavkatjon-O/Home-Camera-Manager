"""Adding devices: identify them through a connector or directly, then add the chosen channels as cameras."""

import logging
from dataclasses import replace
from datetime import UTC, datetime
from uuid import UUID, uuid4

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.core.config import settings
from app.core.exceptions import BadGateway, NotFound, ServiceError, Unprocessable
from app.core.security import encrypt_secret
from app.models import Camera, Connector, Device, DiscoveredCamera
from app.modules.billing.enums import Limit
from app.modules.billing.services.entitlements import require_capacity
from app.modules.devices.agent import AgentClient
from app.modules.devices.enums import CameraBrand
from app.modules.devices.schemas.capabilities import capabilities_read
from app.modules.devices.schemas.devices import DeviceRead
from app.modules.devices.schemas.pairing import (
    AttemptOutcome,
    ChannelRead,
    IdentifyRequest,
    IdentifyResult,
    PairingDeviceCreate,
    PairingMethodId,
)
from app.modules.devices.services.cameras import CameraService
from app.modules.devices.services.devices import DeviceService
from app.modules.devices.services.pairing_telemetry import PairingTelemetryService
from app.modules.tenancy.services.scope import scope_of
from camera_adapters.base import AdapterError, Channel, DeviceKind, Identity, Target
from camera_adapters.fingerprint import collect
from camera_adapters.manifest import CapabilityManifest
from camera_adapters.registry import Registry, default_registry

__all__ = ["DevicePairingService", "identity_from_agent", "identity_result"]

logger = logging.getLogger(__name__)

ADAPTER_ERRORS = {"unreachable": BadGateway, "no_stream": BadGateway}


def adapter_failure(exc: AdapterError) -> ServiceError:
    """Turn an adapter error into the API error with the same code.

    A device that refuses the login answers 422 rather than 401, so the app does not mistake it for its own
    expired session.

    Args:
        exc: The adapter error.

    Returns:
        The service error.
    """
    kind = ADAPTER_ERRORS.get(exc.code, Unprocessable)
    return kind(f"device_{exc.code}", exc.message)


def identity_from_agent(data: dict) -> Identity:
    """Rebuild an identity a connector reported.

    Args:
        data: The identity as JSON.

    Returns:
        The identity.
    """
    channels = tuple(
        Channel(
            index=int(item.get("index", position + 1)),
            name=str(item.get("name") or f"Channel {position + 1}"),
            token=item.get("token"),
            main_path=item.get("main_path"),
            sub_path=item.get("sub_path"),
            width=item.get("width"),
            height=item.get("height"),
            encoding=item.get("encoding"),
            ptz=bool(item.get("ptz")),
        )
        for position, item in enumerate(data.get("channels") or [])
    )
    return Identity(
        adapter=str(data.get("adapter") or "rtsp"),
        kind=DeviceKind(data.get("kind") or "camera"),
        vendor=data.get("vendor"),
        model=data.get("model"),
        firmware=data.get("firmware"),
        rtsp_port=data.get("rtsp_port"),
        channels=channels,
        manifest=CapabilityManifest.from_dict(data.get("manifest")),
    )


def identity_result(identity: Identity, attempt: UUID) -> IdentifyResult:
    """Build the API view of an identity.

    Args:
        identity: The identity.
        attempt: The pairing attempt.

    Returns:
        The result, without the serial number.
    """
    return IdentifyResult(
        adapter=identity.adapter,
        kind=identity.kind.value,
        vendor=identity.vendor,
        model=identity.model,
        rtsp_port=identity.rtsp_port,
        channels=[
            ChannelRead(
                index=channel.index,
                name=channel.name,
                main_path=channel.main_path,
                sub_path=channel.sub_path,
                width=channel.width,
                height=channel.height,
                encoding=channel.encoding,
                ptz=channel.ptz,
            )
            for channel in identity.channels
        ],
        capabilities=capabilities_read(identity.manifest),
        attempt=attempt,
    )


def channel_manifest(identity: Identity, channel: Channel) -> CapabilityManifest:
    """Narrow a device's manifest to one channel.

    Args:
        identity: The device's identity.
        channel: The channel.

    Returns:
        The channel's manifest.
    """
    manifest = identity.manifest
    control = manifest.control
    return manifest.replaced(
        media={"sub": bool(channel.sub_path)},
        control={
            "ptz": control.ptz and channel.ptz,
            "zoom": control.zoom and channel.ptz,
            "presets": control.presets and channel.ptz,
            "home": control.home and channel.ptz,
        },
    )


class DevicePairingService:
    """Identifies and adds devices at the request's site.

    Attributes:
        session: Database session limited to the request's site.
        actor: Signed-in admin.
        site_id: Database id of the site.
        registry: Adapter registry for direct identification.
        telemetry: Pairing telemetry of the organisation.
        cameras: Camera service that keeps go2rtc in step.
    """

    def __init__(self, session: AsyncSession, actor: UserContext, site_id: int, registry: Registry | None = None):
        """Bind the service to a scoped session.

        Args:
            session: Database session limited to the request's site.
            actor: Signed-in admin.
            site_id: Database id of the site.
            registry: Adapter registry, the default one when omitted.
        """
        self.session = session
        self.actor = actor
        self.site_id = site_id
        self.registry = registry or default_registry()
        self.telemetry = PairingTelemetryService(session, site_id)
        self.cameras = CameraService(session, actor)

    async def connector(self, uuid: UUID | None) -> Connector | None:
        """Load the paired connector a request names.

        Args:
            uuid: Public id, if any.

        Returns:
            The connector, or None when none is named.

        Raises:
            NotFound: The site has no such connector.
            Unprocessable: None is named and the backend may not reach cameras itself.
        """
        if uuid is None:
            if not settings.direct_cameras:
                raise Unprocessable("connector_required", "Name the connector that reaches the device")
            return None
        connector = await self.session.scalar(
            select(Connector).where(
                Connector.uuid == uuid, Connector.revoked_at.is_(None), Connector.deleted_at.is_(None)
            )
        )
        if connector is None:
            raise NotFound("connector_not_found", f"Connector {uuid} does not exist")
        return connector

    def target(self, request: IdentifyRequest) -> Target:
        """Build the adapter target of a request.

        Args:
            request: The request.

        Returns:
            The target.
        """
        return Target(
            host=request.host or "",
            port=request.port,
            rtsp_port=request.rtsp_port,
            username=request.username,
            password=request.password,
            device_id=request.device_id,
            url=request.rtsp_url,
        )

    async def run_identify(self, request: IdentifyRequest, connector: Connector | None) -> Identity:
        """Identify a device through its connector, or directly.

        Args:
            request: The device.
            connector: Its connector, or None for direct mode.

        Returns:
            The identity.

        Raises:
            ServiceError: The adapter or the connector failed.
        """
        if connector is not None:
            answer = await AgentClient(connector).identify(request.model_dump(mode="json", exclude={"connector"}))
            error = answer.get("error")
            if isinstance(error, dict):
                raise adapter_failure(
                    AdapterError(str(error.get("code") or "invalid"), str(error.get("message") or ""))
                )
            return identity_from_agent(answer)
        target = self.target(request)
        adapter = "rtsp" if request.rtsp_url else request.adapter
        if request.rtsp_url and not target.host:
            target = replace(target, host="rtsp")
        try:
            fingerprint = None if adapter else await collect(target.host)
            identity, _ = await self.registry.identify(target, fingerprint, adapter)
        except AdapterError as exc:
            raise adapter_failure(exc)
        return identity

    async def identify(
        self, request: IdentifyRequest, method: PairingMethodId = PairingMethodId.MANUAL_HOST
    ) -> IdentifyResult:
        """Identify a device and record the attempt.

        Args:
            request: The device.
            method: Pairing method the member uses.

        Returns:
            What the adapter found.
        """
        attempt = await self.telemetry.start(method, request.adapter, "identify")
        await self.session.commit()
        try:
            identity = await self.run_identify(request, await self.connector(request.connector))
        except ServiceError as exc:
            self.telemetry.finish(attempt, AttemptOutcome.FAILED, "identify", request.adapter, exc.code)
            await self.session.commit()
            raise
        attempt.adapter = identity.adapter
        attempt.last_step = "identified"
        await self.session.commit()
        return identity_result(identity, attempt.uuid)

    def chosen_channels(self, identity: Identity, wanted: list[int] | None) -> list[Channel]:
        """Pick the channels to add.

        Args:
            identity: The device's identity.
            wanted: Channel numbers asked for, if any.

        Returns:
            The channels.

        Raises:
            Unprocessable: A recorder was asked for no channel, or for one it does not have.
        """
        by_index = {channel.index: channel for channel in identity.channels}
        if wanted is None:
            if identity.kind != DeviceKind.CAMERA and len(by_index) > 1:
                raise Unprocessable("channels_required", "Pick the recorder's channels to add")
            return list(identity.channels)
        missing = [index for index in wanted if index not in by_index]
        if missing or not wanted:
            raise Unprocessable("channel_not_found", f"The device has no channel {missing[0] if missing else 0}")
        return [by_index[index] for index in dict.fromkeys(wanted)]

    async def create(self, request: PairingDeviceCreate) -> DeviceRead:
        """Identify a device and add it with the chosen channels as cameras.

        The credentials of a device behind a connector go to the connector with each camera and are not stored by
        the backend.

        Args:
            request: The device, its channels and the method used.

        Returns:
            The new device with its channels.

        Raises:
            ServiceError: The device could not be identified or added, such as camera_exists for a camera the site
                has; the attempt is recorded as failed and the session stays usable.
        """
        attempt = await self.telemetry.find(request.attempt) or await self.telemetry.start(
            request.method, request.adapter
        )
        await self.session.commit()
        try:
            connector = await self.connector(request.connector)
            identity = await self.run_identify(request, connector)
            channels = self.chosen_channels(identity, request.channels)
            device = await self.store(request, identity, channels, connector)
        except ServiceError as exc:
            await self.session.rollback()
            await self.session.refresh(attempt)
            self.telemetry.finish(attempt, AttemptOutcome.FAILED, "create", request.adapter, exc.code)
            await self.session.commit()
            raise
        self.telemetry.finish(attempt, AttemptOutcome.SUCCEEDED, "create", identity.adapter)
        await self.session.commit()
        return await DeviceService(self.session, self.actor).read(device.uuid)

    async def store(
        self, request: PairingDeviceCreate, identity: Identity, channels: list[Channel], connector: Connector | None
    ) -> Device:
        """Write the device and its cameras, hand them to the connector and start their streams.

        Args:
            request: The request.
            identity: The device's identity.
            channels: Channels to add.
            connector: The connector, or None for direct mode.

        Returns:
            The device.

        Raises:
            Conflict: A channel's stream is already registered at the site.
        """
        scope = scope_of(self.session)
        if scope is not None:
            await require_capacity(self.session, scope.organisation_id, Limit.CAMERAS, len(channels))
        now = datetime.now(UTC)
        brand = identity.adapter if identity.adapter in {item.value for item in CameraBrand} else CameraBrand.RTSP.value
        host = request.host or (identity.channels[0].name if not request.host else request.host)
        if request.rtsp_url:
            host = request.rtsp_url.split("://", 1)[1].split("/", 1)[0].split("@")[-1].split(":")[0]
        device = Device(
            connector_id=connector.id if connector else None,
            kind=identity.kind.value,
            adapter=identity.adapter,
            name=request.name.strip(),
            vendor=identity.vendor,
            model=identity.model,
            host=host,
            onvif_port=request.port,
            rtsp_port=identity.rtsp_port,
            username=request.username if connector is None else None,
            password_encrypted=encrypt_secret(request.password) if request.password and connector is None else None,
            channel_count=max(1, len(identity.channels)),
            capabilities=identity.manifest.to_dict(),
            identified_at=now,
        )
        self.session.add(device)
        await self.session.flush()
        cameras = []
        position = await self.cameras.next_position()
        for offset, channel in enumerate(channels):
            if not channel.main_path:
                raise Unprocessable("no_stream", f"Channel {channel.index} has no stream")
            await self.cameras.ensure_unique(host, channel.main_path)
            camera = Camera(
                uuid=uuid4(),
                device_id=device.id,
                channel=channel.index,
                connector_id=device.connector_id,
                name=request.name.strip() if len(channels) == 1 else f"{request.name.strip()} {channel.index}",
                brand=brand,
                host=host,
                rtsp_port=identity.rtsp_port or 554,
                onvif_port=request.port if brand != CameraBrand.RTSP.value else None,
                username=request.username,
                password_encrypted=encrypt_secret(request.password) if request.password and connector is None else None,
                main_path=channel.main_path,
                sub_path=channel.sub_path,
                lenses=1,
                ptz_enabled=channel.ptz,
                position=position + offset,
                enabled=True,
                capabilities=channel_manifest(identity, channel).to_dict(),
            )
            self.session.add(camera)
            cameras.append(camera)
        await self.session.flush()
        if connector is not None:
            agent = AgentClient(connector)
            for camera in cameras:
                await agent.put_camera(
                    camera.uuid, {**self.cameras.agent_config(camera, request.password), "device_id": request.device_id}
                )
        if request.discovered is not None:
            found = await self.session.scalar(
                select(DiscoveredCamera).where(DiscoveredCamera.uuid == request.discovered)
            )
            if found is not None:
                found.camera_uuid = cameras[0].uuid
        await self.session.commit()
        for camera in cameras:
            await self.session.refresh(camera)
            await self.cameras.cameras.sync(camera)
            if connector is None:
                self.cameras.cameras.probe_later(camera)
        return device
