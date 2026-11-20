"""The calls of a paired connector: authentication, heartbeat, discovery reports and its camera list."""

import hashlib
import json
from datetime import UTC, datetime

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import Unauthorized
from app.core.security import hash_token
from app.models import Camera, Connector, DiscoveredCamera
from app.modules.devices.enums import CameraBrand, FoundBy
from app.modules.devices.schemas import (
    ConnectorCameraConfig,
    ConnectorConfig,
    DiscoveryReport,
    HeartbeatAck,
    HeartbeatIn,
)
from app.streaming.status import ProbeResult, StatusStore
from app.streaming.supervisor import supervisor

__all__ = ["ConnectorDeviceService", "authenticate_connector", "config_version"]


async def authenticate_connector(session: AsyncSession, token: str | None) -> Connector:
    """Find the paired connector a bearer token belongs to.

    Args:
        session: Database session.
        token: The bearer token, if sent.

    Returns:
        The connector.

    Raises:
        Unauthorized: The token is missing, unknown or revoked.
    """
    if not token:
        raise Unauthorized("invalid_connector_token", "The connector token is missing")
    connector = await session.scalar(
        select(Connector).where(Connector.token_hash == hash_token(token), Connector.revoked_at.is_(None))
    )
    if connector is None:
        raise Unauthorized("invalid_connector_token", "The connector token is unknown or revoked")
    return connector


def config_version(cameras: list[ConnectorCameraConfig]) -> str:
    """Digest a connector's camera list.

    Args:
        cameras: The cameras.

    Returns:
        The first 16 hex digits of its SHA-256.
    """
    data = json.dumps([camera.model_dump(mode="json") for camera in cameras], sort_keys=True)
    return hashlib.sha256(data.encode()).hexdigest()[:16]


class ConnectorDeviceService:
    """Serves one authenticated connector.

    Attributes:
        session: Database session.
        connector: The connector.
        statuses: Store of camera reachability the wall and the apps read.
    """

    def __init__(self, session: AsyncSession, connector: Connector, statuses: StatusStore | None = None):
        """Bind the service to a connector.

        Args:
            session: Database session.
            connector: The authenticated connector.
            statuses: Camera reachability store, the supervisor's when omitted.
        """
        self.session = session
        self.connector = connector
        self.statuses = statuses if statuses is not None else supervisor.statuses

    async def cameras(self) -> list[Camera]:
        """Load the connector's live cameras.

        Returns:
            The cameras in wall order.
        """
        return list(
            await self.session.scalars(
                select(Camera)
                .where(Camera.connector_id == self.connector.id, Camera.deleted_at.is_(None))
                .order_by(Camera.position, Camera.id)
            )
        )

    async def config(self) -> ConnectorConfig:
        """Return the connector's camera list without credentials.

        Returns:
            The cameras with the list's digest.
        """
        cameras = [
            ConnectorCameraConfig(
                uuid=camera.uuid,
                name=camera.name,
                brand=CameraBrand(camera.brand),
                host=camera.host,
                rtsp_port=camera.rtsp_port,
                onvif_port=camera.onvif_port,
                main_path=camera.main_path,
                sub_path=camera.sub_path,
                enabled=camera.enabled,
                channel=camera.channel or 1,
            )
            for camera in await self.cameras()
        ]
        return ConnectorConfig(version=config_version(cameras), cameras=cameras)

    async def heartbeat(self, report: HeartbeatIn, client: str | None) -> HeartbeatAck:
        """Record a heartbeat: version, address, ports, health and camera reachability.

        In direct mode the connector is reached at the address it reports, or else at the heartbeat's source
        address, unless a member pinned an address.

        Args:
            report: The heartbeat.
            client: Source address of the request.

        Returns:
            Whether a discovery run is wanted and the camera list's digest.
        """
        now = datetime.now(UTC)
        connector = self.connector
        health = dict(report.health)
        pinned = bool((connector.health or {}).get("address_pinned"))
        if pinned:
            health["address_pinned"] = True
        elif report.address or client:
            connector.address = report.address or client
        connector.version = report.version or connector.version
        connector.api_port = report.api_port
        connector.rtsp_port = report.rtsp_port
        connector.last_seen_at = now
        connector.health = {**health, "uptime_seconds": report.uptime_seconds}
        known = {camera.uuid: camera for camera in await self.cameras()}
        for item in report.cameras:
            camera = known.get(item.uuid)
            if camera is None:
                continue
            self.statuses.record(
                camera.uuid,
                camera.host,
                camera.rtsp_port,
                ProbeResult(online=item.online, checked_at=now, error=item.error),
            )
        requested = connector.discovery_requested_at
        wanted = requested is not None and (connector.discovered_at is None or connector.discovered_at < requested)
        await self.session.commit()
        return HeartbeatAck(discovery_requested=wanted, config_version=(await self.config()).version, server_time=now)

    async def report_discovery(self, report: DiscoveryReport) -> int:
        """Store the cameras a discovery run found, replacing the previous run's.

        Args:
            report: The candidates.

        Returns:
            The number of candidates stored.
        """
        now = datetime.now(UTC)
        rows = {
            row.host: row
            for row in await self.session.scalars(
                select(DiscoveredCamera).where(DiscoveredCamera.connector_id == self.connector.id)
            )
        }
        registered = {camera.host: camera.uuid for camera in await self.cameras()}
        seen = set()
        for item in report.cameras:
            seen.add(item.host)
            row = rows.get(item.host)
            if row is None:
                row = DiscoveredCamera(connector_id=self.connector.id, host=item.host)
                self.session.add(row)
            row.open_ports = sorted(set(item.open_ports))
            row.brand = item.brand.value if item.brand else None
            row.manufacturer = item.manufacturer
            row.model = item.model
            row.onvif_port = item.onvif_port
            row.found_by = FoundBy(item.found_by).value
            row.scopes = item.scopes
            row.seen_at = now
            row.deleted_at = None
            row.camera_uuid = registered.get(item.host)
        for host, row in rows.items():
            if host not in seen:
                row.deleted_at = now
        self.connector.discovered_at = now
        await self.session.commit()
        return len(seen)
