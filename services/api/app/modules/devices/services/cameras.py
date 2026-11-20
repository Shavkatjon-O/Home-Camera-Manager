"""Camera registry service."""

import logging
from uuid import UUID, uuid4

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.core.base_service import BaseModelService
from app.core.exceptions import BadGateway, Conflict, NotFound, Unprocessable
from app.core.security import decrypt_secret, encrypt_secret
from app.models import Camera, Connector, Device
from app.modules.devices.agent import AgentClient
from app.modules.devices.enums import CameraBrand, CameraSort
from app.modules.devices.schemas import (
    CameraCreate,
    CameraList,
    CameraRead,
    CameraStatus,
    CameraStreams,
    CameraUpdate,
    PtzMove,
)
from app.modules.devices.schemas.capabilities import CapabilitiesRead, capabilities_read
from app.modules.devices.services.defaults import DEFAULT_RTSP_PORT, apply_brand_defaults
from app.modules.devices.services.manifests import camera_manifest
from app.streaming.names import MAIN, SUB, stream_name
from app.streaming.supervisor import CameraSupervisor, supervisor
from camera_adapters.onvif.cache import OnvifCache, PtzTarget, onvif_cache
from camera_adapters.onvif.client import OnvifClient, pick_streams, uri_path
from camera_adapters.onvif.soap import OnvifError

__all__ = ["CameraService"]

logger = logging.getLogger(__name__)

STREAM_FIELDS = ("host", "rtsp_port", "username", "main_path", "sub_path", "enabled")
ONVIF_FIELDS = ("host", "onvif_port", "username", "ptz_enabled")


class CameraService(BaseModelService[Camera]):
    """Camera registry operations that keep the stream server, status probes and ONVIF cache in step.

    Attributes:
        cameras: Supervisor that syncs streams to the stream server and probes cameras.
        onvif: Cache of ONVIF connections used for pan, tilt and zoom.
    """

    model = Camera
    not_found_code = "camera_not_found"

    def __init__(
        self,
        session: AsyncSession,
        actor: UserContext | None = None,
        cameras: CameraSupervisor = supervisor,
        onvif: OnvifCache = onvif_cache,
    ):
        """Bind the service to a session, the acting user and the streaming collaborators.

        Args:
            session: Database session the service works in.
            actor: User making the request, if any.
            cameras: Supervisor that syncs streams and probes cameras.
            onvif: Cache of ONVIF connections.
        """
        super().__init__(session, actor)
        self.cameras = cameras
        self.onvif = onvif

    def capabilities(self, camera: Camera) -> CapabilitiesRead:
        """Return a camera's capability manifest, built from its brand when none is stored yet.

        Args:
            camera: Camera row.

        Returns:
            The manifest.
        """
        if camera.capabilities:
            return capabilities_read(camera.capabilities)
        return capabilities_read(camera_manifest(camera))

    async def device_uuids(self, cameras: list[Camera]) -> dict[int, UUID]:
        """Load the public ids of the devices of cameras.

        Args:
            cameras: Camera rows.

        Returns:
            Device database id to public id.
        """
        ids = {camera.device_id for camera in cameras if camera.device_id is not None}
        if not ids:
            return {}
        return dict((await self.session.execute(select(Device.id, Device.uuid).where(Device.id.in_(ids)))).all())

    async def connector_uuids(self, cameras: list[Camera]) -> dict[int, UUID]:
        """Load the public ids of the connectors of cameras.

        Args:
            cameras: Camera rows.

        Returns:
            Connector database id to public id.
        """
        ids = {camera.connector_id for camera in cameras if camera.connector_id is not None}
        if not ids:
            return {}
        return dict(
            (await self.session.execute(select(Connector.id, Connector.uuid).where(Connector.id.in_(ids)))).all()
        )

    def read(
        self, camera: Camera, connectors: dict[int, UUID] | None = None, devices: dict[int, UUID] | None = None
    ) -> CameraRead:
        """Build the API view of a camera with its last known status.

        Args:
            camera: Camera row.
            connectors: Connector database id to public id, for a connector camera.
            devices: Device database id to public id.

        Returns:
            The camera as the API returns it.
        """
        status = self.cameras.statuses.get(camera.uuid, camera.host, camera.rtsp_port)
        return CameraRead(
            uuid=camera.uuid,
            name=camera.name,
            brand=CameraBrand(camera.brand),
            host=camera.host,
            device_host=camera.device_host,
            rtsp_port=camera.rtsp_port,
            onvif_port=camera.onvif_port,
            username=camera.username,
            has_password=bool(camera.password_encrypted),
            main_path=camera.main_path,
            sub_path=camera.sub_path,
            lenses=camera.lenses,
            ptz_enabled=camera.ptz_enabled,
            location=camera.location,
            position=camera.position,
            enabled=camera.enabled,
            status=CameraStatus(online=status.online, checked_at=status.checked_at, error=status.error),
            streams=CameraStreams(
                main=stream_name(camera.uuid, MAIN),
                sub=stream_name(camera.uuid, SUB) if camera.sub_path else None,
            ),
            created_at=camera.created_at,
            updated_at=camera.updated_at,
            connector=(connectors or {}).get(camera.connector_id) if camera.connector_id else None,
            device=(devices or {}).get(camera.device_id) if camera.device_id else None,
            channel=camera.channel,
            capabilities=self.capabilities(camera),
        )

    async def read_one(self, camera: Camera) -> CameraRead:
        """Build the API view of one camera with its connector.

        Args:
            camera: Camera row.

        Returns:
            The camera as the API returns it.
        """
        return self.read(camera, await self.connector_uuids([camera]), await self.device_uuids([camera]))

    def live(self):
        """Build a query for cameras that have not been soft-deleted.

        Returns:
            Select statement over live cameras.
        """
        return select(Camera).where(Camera.deleted_at.is_(None))

    async def list_page(self, page: int, page_size: int, sort: CameraSort) -> CameraList:
        """List live cameras one page at a time.

        Args:
            page: Page number, starting at 1.
            page_size: Number of cameras per page.
            sort: Wall position first, or newest first.

        Returns:
            The page with the total number of live cameras.
        """
        total = await self.session.scalar(select(func.count()).select_from(Camera).where(Camera.deleted_at.is_(None)))
        query = self.live()
        if sort == CameraSort.POSITION:
            query = query.order_by(Camera.position.asc(), Camera.created_at.desc(), Camera.id.desc())
        else:
            query = query.order_by(Camera.created_at.desc(), Camera.id.desc())
        rows = list(await self.session.scalars(query.offset((page - 1) * page_size).limit(page_size)))
        connectors = await self.connector_uuids(rows)
        devices = await self.device_uuids(rows)
        return CameraList(
            items=[self.read(camera, connectors, devices) for camera in rows],
            total=total or 0,
            page=page,
            page_size=page_size,
        )

    async def detail(self, uuid: UUID) -> CameraRead:
        """Return one camera.

        Args:
            uuid: Public id of the camera.

        Returns:
            The camera.
        """
        return await self.read_one(await self.get(uuid))

    async def ensure_unique(self, host: str, main_path: str, exclude_id: int | None = None) -> None:
        """Check that no other live camera has the same host and main path.

        Args:
            host: Host to check.
            main_path: Main stream path to check.
            exclude_id: Internal id of a camera to leave out, such as the one being updated.

        Raises:
            Conflict: Another live camera has that host and main path.
        """
        query = select(Camera.id).where(
            Camera.deleted_at.is_(None),
            Camera.host == host,
            Camera.main_path == main_path,
        )
        if exclude_id is not None:
            query = query.where(Camera.id != exclude_id)
        if await self.session.scalar(query.limit(1)) is not None:
            raise Conflict("camera_exists", f"A camera with the host {host} and the path {main_path} already exists")

    async def next_position(self) -> int:
        """Pick the wall position after the last live camera.

        Returns:
            One more than the highest position in use.
        """
        highest = await self.session.scalar(select(func.max(Camera.position)).where(Camera.deleted_at.is_(None)))
        return (highest or 0) + 1

    async def resolve_onvif(self, values: dict, password: str | None) -> dict:
        """Fill missing PTZ support and stream settings by asking the camera over ONVIF.

        Settings already present in the values are kept. When the camera does not answer but a main
        path is already known, the values are returned unchanged.

        Args:
            values: Camera fields from the request.
            password: Camera password, if any.

        Returns:
            Copy of the values with PTZ support, main path, RTSP port and sub path filled in where missing.

        Raises:
            BadGateway: The camera does not answer and no main path is known, or it reports no stream address.
        """
        client = OnvifClient(values["host"], values["onvif_port"], values.get("username"), password)
        try:
            profiles = await client.stream_profiles()
        except OnvifError as exc:
            if values.get("main_path"):
                return values
            raise BadGateway("onvif_error", str(exc))
        result = dict(values)
        if result.get("ptz_enabled") is None:
            result["ptz_enabled"] = any(profile.ptz for profile in profiles)
        if result.get("main_path"):
            return result
        main, sub = pick_streams(profiles)
        if main is None:
            raise BadGateway("onvif_error", "The camera reported no stream address")
        main_path, main_port = uri_path(main.stream_uri)
        result["main_path"] = main_path
        if result.get("rtsp_port") is None and main_port is not None:
            result["rtsp_port"] = main_port
        if sub is not None and result.get("sub_path") is None:
            result["sub_path"] = uri_path(sub.stream_uri)[0]
        return result

    async def connector(self, uuid: UUID) -> Connector:
        """Load a paired connector of the request's site.

        Args:
            uuid: Public id of the connector.

        Returns:
            The connector.

        Raises:
            NotFound: The site has no paired connector with the id.
        """
        connector = await self.session.scalar(
            select(Connector).where(
                Connector.uuid == uuid, Connector.revoked_at.is_(None), Connector.deleted_at.is_(None)
            )
        )
        if connector is None:
            raise NotFound("connector_not_found", f"Connector {uuid} does not exist")
        return connector

    async def camera_connector(self, camera: Camera) -> Connector:
        """Load the connector of a connector camera.

        Args:
            camera: Camera row.

        Returns:
            The connector.

        Raises:
            Conflict: The connector was removed.
        """
        connector = await self.session.get(Connector, camera.connector_id)
        if connector is None or connector.revoked_at is not None:
            raise Conflict("connector_revoked", "The camera's connector was removed")
        return connector

    def agent_config(self, camera: Camera, password: str | None) -> dict:
        """Build the camera fields handed to its connector.

        Args:
            camera: Camera row.
            password: Password to hand over; None keeps the one the connector holds, empty removes it.

        Returns:
            The fields with the credentials.
        """
        return {
            "name": camera.name,
            "brand": camera.brand,
            "host": camera.host,
            "rtsp_port": camera.rtsp_port,
            "onvif_port": camera.onvif_port,
            "username": camera.username,
            "password": password,
            "main_path": camera.main_path,
            "sub_path": camera.sub_path,
            "enabled": camera.enabled,
        }

    async def resolve_through(self, connector: Connector, values: dict, password: str | None) -> dict:
        """Fill missing stream paths and PTZ support by asking the camera through its connector.

        Args:
            connector: The connector.
            values: Camera fields from the request.
            password: Camera password, if any.

        Returns:
            Copy of the values with what the connector found filled in where missing.

        Raises:
            BadGateway: The connector could not reach the camera and no main path is known.
        """
        if values.get("main_path") and values.get("ptz_enabled") is not None:
            return values
        found = await AgentClient(connector).test_camera(
            {
                "host": values["host"],
                "brand": CameraBrand(values["brand"]).value,
                "rtsp_port": values.get("rtsp_port"),
                "onvif_port": values.get("onvif_port"),
                "username": values.get("username"),
                "password": password,
                "main_path": values.get("main_path"),
                "sub_path": values.get("sub_path"),
            }
        )
        if not found.get("main_path") and not values.get("main_path"):
            raise BadGateway("camera_unreachable", found.get("error") or "The connector found no stream on the camera")
        result = dict(values)
        for field in ("main_path", "sub_path", "rtsp_port"):
            if result.get(field) is None and found.get(field) is not None:
                result[field] = found[field]
        if result.get("ptz_enabled") is None and found.get("ptz") is not None:
            result["ptz_enabled"] = bool(found["ptz"])
        return result

    async def create(self, payload: CameraCreate) -> CameraRead:
        """Register a camera, start streaming it and probe it in the background.

        Args:
            payload: Camera to register.

        Returns:
            The new camera.

        Raises:
            Unprocessable: No main stream path is given or found.
            Conflict: A live camera already has that host and main path.
        """
        values = payload.model_dump(exclude={"password", "connector"})
        values = apply_brand_defaults(payload.brand, values)
        connector = await self.connector(payload.connector) if payload.connector else None
        if connector is not None:
            values = await self.resolve_through(connector, values, payload.password)
        elif payload.brand == CameraBrand.ONVIF and (not values.get("main_path") or values.get("ptz_enabled") is None):
            values = await self.resolve_onvif(values, payload.password)
        if not values.get("main_path"):
            raise Unprocessable("main_path_required", "A main stream path is required")
        if values.get("rtsp_port") is None:
            values["rtsp_port"] = DEFAULT_RTSP_PORT
        if values.get("ptz_enabled") is None:
            values["ptz_enabled"] = False
        await self.ensure_unique(values["host"], values["main_path"])
        camera = Camera(
            uuid=uuid4(),
            connector_id=connector.id if connector is not None else None,
            name=values["name"],
            brand=CameraBrand(values["brand"]).value,
            location=values.get("location"),
            host=values["host"],
            device_host=values.get("device_host"),
            rtsp_port=values["rtsp_port"],
            onvif_port=values.get("onvif_port"),
            username=values.get("username"),
            password_encrypted=encrypt_secret(payload.password) if payload.password and connector is None else None,
            main_path=values["main_path"],
            sub_path=values.get("sub_path"),
            lenses=values.get("lenses") or 1,
            ptz_enabled=values["ptz_enabled"],
            position=await self.next_position(),
            enabled=values["enabled"],
        )
        if connector is not None:
            await AgentClient(connector).put_camera(camera.uuid, self.agent_config(camera, payload.password))
        manifest = camera_manifest(camera)
        device = Device(
            connector_id=camera.connector_id,
            kind="camera",
            adapter=camera.brand,
            name=camera.name,
            host=camera.device_host or camera.host,
            onvif_port=camera.onvif_port,
            rtsp_port=camera.rtsp_port,
            channel_count=1,
            capabilities=manifest.to_dict(),
        )
        self.session.add(device)
        await self.session.flush()
        camera.device_id = device.id
        camera.channel = 1
        camera.capabilities = manifest.to_dict()
        self.session.add(camera)
        await self.commit()
        await self.session.refresh(camera)
        await self.cameras.sync(camera)
        if connector is None:
            self.cameras.probe_later(camera)
        return await self.read_one(camera)

    async def update(self, uuid: UUID, payload: CameraUpdate) -> CameraRead:
        """Change a camera and refresh whatever depends on the changed fields.

        Streams are synced only when a stream setting or the password changed, the ONVIF cache is
        dropped only when an ONVIF setting or the password changed, and the camera is probed again
        when its host or RTSP port changed.

        Args:
            uuid: Public id of the camera.
            payload: Fields to change.

        Returns:
            The updated camera.

        Raises:
            Conflict: The new host and main path belong to another live camera.
        """
        camera = await self.get(uuid)
        changes = payload.model_dump(exclude_unset=True)
        password_given = "password" in changes
        password = changes.pop("password", None)
        host = changes.get("host", camera.host)
        main_path = changes.get("main_path", camera.main_path)
        if host != camera.host or main_path != camera.main_path:
            await self.ensure_unique(host, main_path, exclude_id=camera.id)
        before = {field: getattr(camera, field) for field in STREAM_FIELDS + ONVIF_FIELDS}
        for field, value in changes.items():
            if field == "brand":
                value = CameraBrand(value).value
            setattr(camera, field, value)
        password_changed = False
        if password_given and password is not None:
            if password == "":
                password_changed = camera.password_encrypted is not None
                camera.password_encrypted = None
            else:
                password_changed = decrypt_secret(camera.password_encrypted) != password
                camera.password_encrypted = encrypt_secret(password)
        connector = await self.session.get(Connector, camera.connector_id) if camera.connector_id else None
        if connector is not None:
            camera.password_encrypted = None
            changed = any(before[field] != getattr(camera, field) for field in STREAM_FIELDS + ONVIF_FIELDS)
            if changed or password_given or "brand" in changes or "sub_path" in changes:
                await AgentClient(connector).put_camera(camera.uuid, self.agent_config(camera, password))
        await self.commit()
        await self.session.refresh(camera)
        stream_changed = password_changed or any(before[field] != getattr(camera, field) for field in STREAM_FIELDS)
        onvif_changed = password_changed or any(before[field] != getattr(camera, field) for field in ONVIF_FIELDS)
        if onvif_changed:
            self.onvif.forget(camera.uuid)
        if stream_changed:
            await self.cameras.sync(camera)
        if connector is None and (before["host"] != camera.host or before["rtsp_port"] != camera.rtsp_port):
            self.cameras.probe_later(camera)
        return await self.read_one(camera)

    async def delete(self, uuid: UUID) -> None:
        """Soft-delete a camera and remove its streams and cached ONVIF connection.

        Args:
            uuid: Public id of the camera.
        """
        camera = await self.get(uuid)
        camera.deleted_at = func.now()
        await self.commit()
        self.onvif.forget(camera.uuid)
        await self.cameras.remove(camera.uuid)
        if camera.connector_id is not None:
            connector = await self.session.get(Connector, camera.connector_id)
            if connector is not None and connector.revoked_at is None:
                try:
                    await AgentClient(connector).delete_camera(camera.uuid)
                except (BadGateway, Conflict) as exc:
                    logger.warning("The connector keeps the removed camera %s until it syncs: %s", uuid, exc.message)

    async def reorder(self, uuids: list[UUID]) -> None:
        """Set the wall order, keeping cameras that are not listed after the listed ones.

        Args:
            uuids: Camera ids in the order they should appear.

        Raises:
            NotFound: A listed camera does not exist.
        """
        rows = await self.session.scalars(
            self.live().order_by(Camera.position.asc(), Camera.created_at.desc(), Camera.id.desc())
        )
        cameras = list(rows)
        by_uuid = {camera.uuid: camera for camera in cameras}
        missing = [str(uuid) for uuid in uuids if uuid not in by_uuid]
        if missing:
            raise NotFound(self.not_found_code, f"Camera {missing[0]} does not exist")
        listed = set(uuids)
        ordered = [by_uuid[uuid] for uuid in uuids] + [camera for camera in cameras if camera.uuid not in listed]
        for position, camera in enumerate(ordered, start=1):
            if camera.position != position:
                camera.position = position
        await self.commit()

    async def check(self, uuid: UUID) -> CameraRead:
        """Probe a camera now.

        Args:
            uuid: Public id of the camera.

        Returns:
            The camera with its status after the probe.
        """
        camera = await self.get(uuid)
        if camera.connector_id is None:
            await self.cameras.probe_camera(camera)
        return await self.read_one(camera)

    async def ptz_target(self, camera: Camera) -> PtzTarget:
        """Resolve the ONVIF client, address and profile used to move a camera.

        Args:
            camera: Camera row.

        Returns:
            Target for pan, tilt and zoom calls.

        Raises:
            Conflict: PTZ is off for the camera or it has no ONVIF port.
            BadGateway: The camera does not answer over ONVIF.
        """
        if not camera.ptz_enabled:
            raise Conflict("ptz_not_supported", "PTZ is not enabled for this camera")
        if camera.onvif_port is None:
            raise Conflict("ptz_not_supported", "The camera has no ONVIF port")
        try:
            return await self.onvif.ptz_target(
                camera.uuid,
                camera.host,
                camera.onvif_port,
                camera.username,
                decrypt_secret(camera.password_encrypted),
            )
        except OnvifError as exc:
            raise BadGateway("onvif_error", str(exc))

    async def ptz_move(self, uuid: UUID, move: PtzMove) -> None:
        """Start a continuous pan, tilt and zoom move.

        The cached ONVIF connection is dropped when the call fails.

        Args:
            uuid: Public id of the camera.
            move: Speed on each axis.

        Raises:
            BadGateway: The camera rejects the move.
        """
        camera = await self.get(uuid)
        if camera.connector_id is not None:
            if not camera.ptz_enabled:
                raise Conflict("ptz_not_supported", "PTZ is not enabled for this camera")
            await AgentClient(await self.camera_connector(camera)).ptz(camera.uuid, move.pan, move.tilt, move.zoom)
            return
        target = await self.ptz_target(camera)
        try:
            await target.client.continuous_move(target.address, target.profile_token, move.pan, move.tilt, move.zoom)
        except OnvifError as exc:
            self.onvif.forget(camera.uuid)
            raise BadGateway("onvif_error", str(exc))

    async def ptz_stop(self, uuid: UUID) -> None:
        """Stop any pan, tilt and zoom move in progress.

        The cached ONVIF connection is dropped when the call fails.

        Args:
            uuid: Public id of the camera.

        Raises:
            BadGateway: The camera rejects the stop.
        """
        camera = await self.get(uuid)
        if camera.connector_id is not None:
            if not camera.ptz_enabled:
                raise Conflict("ptz_not_supported", "PTZ is not enabled for this camera")
            await AgentClient(await self.camera_connector(camera)).ptz_stop(camera.uuid)
            return
        target = await self.ptz_target(camera)
        try:
            await target.client.stop(target.address, target.profile_token)
        except OnvifError as exc:
            self.onvif.forget(camera.uuid)
            raise BadGateway("onvif_error", str(exc))
