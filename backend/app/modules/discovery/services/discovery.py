"""Camera discovery service."""

import time
from collections.abc import Iterable
from datetime import UTC, datetime

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.core.config import settings
from app.core.exceptions import BadGateway, Unprocessable
from app.discovery.scanner import SubnetError, parse_subnet, scan
from app.models import Camera
from app.modules.discovery.schemas import (
    InspectProfile,
    InspectRequest,
    InspectResult,
    ScanItem,
    ScanRequest,
    ScanResult,
)
from app.onvif.client import DeviceInfo, OnvifClient
from app.onvif.soap import OnvifError

__all__ = ["DiscoveryService", "index_hosts"]


def index_hosts(cameras: Iterable[Camera]) -> dict[str, Camera]:
    """Map every address a camera uses to that camera.

    Args:
        cameras: Cameras to index.

    Returns:
        Camera by host and by device host; the first camera wins when an address repeats.
    """
    hosts: dict[str, Camera] = {}
    for camera in cameras:
        for host in (camera.host, camera.device_host):
            if host:
                hosts.setdefault(host, camera)
    return hosts


class DiscoveryService:
    """Scan the network for cameras and inspect a camera over ONVIF.

    Attributes:
        session: Database session the service works in.
        actor: User making the request, if any.
    """

    def __init__(self, session: AsyncSession, actor: UserContext | None = None):
        """Bind the service to a session and the user acting through it.

        Args:
            session: Database session the service works in.
            actor: User making the request, if any.
        """
        self.session = session
        self.actor = actor

    async def registered_hosts(self) -> dict[str, Camera]:
        """Load live cameras indexed by address.

        Returns:
            Camera by host and by device host.
        """
        rows = await self.session.scalars(
            select(Camera).where(Camera.deleted_at.is_(None)).order_by(Camera.position.asc(), Camera.id.asc())
        )
        return index_hosts(rows)

    async def scan(self, payload: ScanRequest) -> ScanResult:
        """Scan a subnet and mark the hosts that are already registered cameras.

        Args:
            payload: Subnet to scan; the configured default subnet is used when it is missing.

        Returns:
            Hosts found, each with the id of the registered camera at its address, if any.

        Raises:
            Unprocessable: The subnet is invalid or too large.
        """
        try:
            network = parse_subnet(payload.subnet or settings.discovery_subnet)
        except SubnetError as exc:
            raise Unprocessable(exc.code, exc.message)
        scanned_at = datetime.now(UTC)
        started = time.perf_counter()
        found = await scan(network)
        duration_ms = round((time.perf_counter() - started) * 1000)
        registered = await self.registered_hosts()
        items = []
        for item in found:
            camera = registered.get(item.host)
            items.append(
                ScanItem(
                    host=item.host,
                    open_ports=item.open_ports,
                    brand=item.brand,
                    manufacturer=item.manufacturer,
                    model=item.model,
                    onvif_port=item.onvif_port,
                    camera_uuid=camera.uuid if camera is not None else None,
                )
            )
        return ScanResult(subnet=str(network), scanned_at=scanned_at, duration_ms=duration_ms, items=items)

    async def inspect(self, payload: InspectRequest) -> InspectResult:
        """Read a camera's stream profiles and device information over ONVIF.

        Device information is optional: an empty one is used when the camera does not give it.

        Args:
            payload: Address and optional login of the camera.

        Returns:
            Device information and stream profiles.

        Raises:
            BadGateway: The camera does not answer for its stream profiles.
        """
        client = OnvifClient(payload.host, payload.onvif_port, payload.username, payload.password)
        try:
            profiles = await client.stream_profiles()
        except OnvifError as exc:
            raise BadGateway("onvif_error", str(exc))
        try:
            info = await client.device_information()
        except OnvifError:
            info = DeviceInfo()
        return InspectResult(
            manufacturer=info.manufacturer,
            model=info.model,
            firmware=info.firmware,
            profiles=[
                InspectProfile(
                    token=profile.token,
                    name=profile.name,
                    encoding=profile.encoding,
                    width=profile.width,
                    height=profile.height,
                    stream_uri=profile.stream_uri,
                )
                for profile in profiles
            ],
            ptz=any(profile.ptz for profile in profiles),
        )
