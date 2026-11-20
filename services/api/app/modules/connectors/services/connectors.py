"""Connectors as members see them: listing, renaming, removing, discovery and stream tests."""

import logging
from datetime import UTC, datetime, timedelta
from uuid import UUID

from sqlalchemy import func, select, update

from app.core.base_service import BaseModelService
from app.core.config import settings
from app.core.exceptions import BadGateway, Conflict
from app.models import Camera, Connector, DiscoveredCamera
from app.modules.cameras.enums import CameraBrand
from app.modules.connectors.agent import AgentClient, agent_address
from app.modules.connectors.enums import ConnectorMode, FoundBy
from app.modules.connectors.schemas import (
    ConnectorList,
    ConnectorRead,
    ConnectorUpdate,
    DiscoveredList,
    DiscoveredRead,
    StreamTest,
    StreamTestResult,
)

__all__ = ["ConnectorService", "connector_online"]

logger = logging.getLogger(__name__)


def connector_online(connector: Connector, now: datetime) -> bool:
    """Tell whether a connector sent a heartbeat recently.

    Args:
        connector: The connector.
        now: Current time.

    Returns:
        True when its last heartbeat is newer than the offline limit.
    """
    if connector.last_seen_at is None:
        return False
    return now - connector.last_seen_at < timedelta(seconds=settings.connector_offline_seconds)


class ConnectorService(BaseModelService[Connector]):
    """Connectors of the request's site.

    Attributes:
        model: Connectors.
        not_found_code: Error code of an unknown connector.
    """

    model = Connector
    not_found_code = "connector_not_found"

    async def live(self, uuid: UUID) -> Connector:
        """Load a paired connector of the site.

        Args:
            uuid: Public id.

        Returns:
            The connector.

        Raises:
            NotFound: No paired connector of the site has the id.
        """
        connector = await self.get(uuid)
        if connector.revoked_at is not None:
            raise Conflict("connector_revoked", "The connector was removed")
        return connector

    async def reads(self, connectors: list[Connector]) -> list[ConnectorRead]:
        """Build the API views of connectors.

        Args:
            connectors: The connectors.

        Returns:
            The connectors in the given order.
        """
        ids = [connector.id for connector in connectors]
        counts = dict(
            (
                await self.session.execute(
                    select(Camera.connector_id, func.count())
                    .where(Camera.connector_id.in_(ids), Camera.deleted_at.is_(None))
                    .group_by(Camera.connector_id)
                )
            ).all()
        )
        now = datetime.now(UTC)
        return [
            ConnectorRead(
                uuid=connector.uuid,
                name=connector.name,
                version=connector.version,
                mode=ConnectorMode(connector.mode),
                address=agent_address(connector),
                online=connector_online(connector, now),
                last_seen_at=connector.last_seen_at,
                camera_count=counts.get(connector.id, 0),
                discovery_requested_at=connector.discovery_requested_at,
                discovered_at=connector.discovered_at,
                health=connector.health or {},
                created_at=connector.created_at,
            )
            for connector in connectors
        ]

    async def list(self) -> ConnectorList:
        """List the site's paired connectors.

        Returns:
            The connectors, oldest first.
        """
        rows = await self.session.scalars(
            select(Connector)
            .where(Connector.deleted_at.is_(None), Connector.revoked_at.is_(None))
            .order_by(Connector.created_at, Connector.id)
        )
        return ConnectorList(items=await self.reads(list(rows)))

    async def read(self, uuid: UUID) -> ConnectorRead:
        """Return one connector.

        Args:
            uuid: Public id.

        Returns:
            The connector.
        """
        return (await self.reads([await self.live(uuid)]))[0]

    async def update(self, uuid: UUID, payload: ConnectorUpdate) -> ConnectorRead:
        """Rename a connector or set the address central reaches it at.

        Args:
            uuid: Public id.
            payload: Fields to change.

        Returns:
            The connector.
        """
        connector = await self.live(uuid)
        if payload.name is not None:
            connector.name = payload.name.strip()
        if payload.address is not None:
            connector.address = payload.address.strip()
            connector.health = {**(connector.health or {}), "address_pinned": True}
        await self.commit()
        await self.session.refresh(connector)
        return (await self.reads([connector]))[0]

    async def remove(self, uuid: UUID) -> None:
        """Unpair a connector: its token stops working and its cameras are removed.

        Args:
            uuid: Public id.
        """
        connector = await self.live(uuid)
        now = datetime.now(UTC)
        connector.revoked_at = now
        connector.deleted_at = now
        await self.session.execute(
            update(Camera)
            .where(Camera.connector_id == connector.id, Camera.deleted_at.is_(None))
            .values(deleted_at=now)
            .execution_options(synchronize_session=False)
        )
        await self.commit()

    async def request_discovery(self, uuid: UUID) -> ConnectorRead:
        """Ask a connector to look for cameras now.

        The connector is called at once when it can be reached; otherwise it learns of the request from its next
        heartbeat.

        Args:
            uuid: Public id.

        Returns:
            The connector.
        """
        connector = await self.live(uuid)
        connector.discovery_requested_at = datetime.now(UTC)
        await self.commit()
        try:
            await AgentClient(connector).discover()
        except (BadGateway, Conflict) as exc:
            logger.info("Connector %s will see the discovery request on its next heartbeat: %s", uuid, exc.message)
        return (await self.reads([connector]))[0]

    async def discovered(self, uuid: UUID) -> DiscoveredList:
        """List the cameras a connector found.

        Args:
            uuid: Public id.

        Returns:
            The candidates.
        """
        connector = await self.live(uuid)
        rows = await self.session.scalars(
            select(DiscoveredCamera)
            .where(DiscoveredCamera.connector_id == connector.id, DiscoveredCamera.deleted_at.is_(None))
            .order_by(DiscoveredCamera.host)
        )
        return DiscoveredList(
            items=[
                DiscoveredRead(
                    uuid=row.uuid,
                    host=row.host,
                    open_ports=row.open_ports or [],
                    brand=CameraBrand(row.brand) if row.brand else None,
                    manufacturer=row.manufacturer,
                    model=row.model,
                    onvif_port=row.onvif_port,
                    found_by=FoundBy(row.found_by),
                    seen_at=row.seen_at,
                    camera=row.camera_uuid,
                )
                for row in rows
            ],
            discovered_at=connector.discovered_at,
        )

    async def test(self, uuid: UUID, payload: StreamTest) -> StreamTestResult:
        """Have a connector test a camera's credentials and find its streams.

        Args:
            uuid: Public id.
            payload: The camera to test.

        Returns:
            What the connector found.
        """
        connector = await self.live(uuid)
        answer = await AgentClient(connector).test_camera(payload.model_dump(mode="json"))
        return StreamTestResult.model_validate(answer)
