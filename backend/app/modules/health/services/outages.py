"""Outage service."""

from datetime import datetime
from uuid import UUID

from sqlalchemy import func, select

from app.core.base_service import BaseModelService
from app.models import Camera, NetworkDevice, Outage
from app.modules.health.enums import TargetKind
from app.modules.health.schemas import OutageList, OutageRead
from app.modules.health.services.overview import duration_seconds

__all__ = ["OutageService"]


class OutageService(BaseModelService[Outage]):
    """List recorded outages with the names of their targets and causes."""

    model = Outage
    not_found_code = "outage_not_found"

    async def names(self) -> dict[UUID, str]:
        """Map device and camera ids to names.

        Returns:
            The name of every device and camera, including deleted ones.
        """
        devices = await self.session.execute(select(NetworkDevice.uuid, NetworkDevice.name))
        cameras = await self.session.execute(select(Camera.uuid, Camera.name))
        return {target_uuid: name for target_uuid, name in [*devices.all(), *cameras.all()]}

    def read(self, outage: Outage, until: datetime, names: dict[UUID, str]) -> OutageRead:
        """Convert an outage row to its API form.

        Args:
            outage: Outage row.
            until: Time used as the end of an outage that is still open.
            names: Target names keyed by public id.

        Returns:
            The outage with names filled in and its duration.
        """
        return OutageRead(
            uuid=outage.uuid,
            target_kind=TargetKind(outage.target_kind),
            target_uuid=outage.target_uuid,
            target_name=names.get(outage.target_uuid),
            started_at=outage.started_at,
            ended_at=outage.ended_at,
            ongoing=outage.ended_at is None,
            duration_seconds=duration_seconds(outage.started_at, outage.ended_at, until),
            failed_samples=outage.failed_samples,
            upstream_uuid=outage.upstream_uuid,
            upstream_name=names.get(outage.upstream_uuid) if outage.upstream_uuid else None,
            created_at=outage.created_at,
            updated_at=outage.updated_at,
        )

    async def list_page(self, page: int, page_size: int, target_uuid: UUID | None = None) -> OutageList:
        """List outages, newest first.

        Args:
            page: One-based page number.
            page_size: Outages per page.
            target_uuid: Only list outages of this device or camera.

        Returns:
            The requested page of outages.
        """
        filters = [Outage.deleted_at.is_(None)]
        if target_uuid is not None:
            filters.append(Outage.target_uuid == target_uuid)
        total = await self.session.scalar(select(func.count()).select_from(Outage).where(*filters))
        rows = list(
            await self.session.scalars(
                select(Outage)
                .where(*filters)
                .order_by(Outage.created_at.desc(), Outage.id.desc())
                .offset((page - 1) * page_size)
                .limit(page_size)
            )
        )
        until = await self.session.scalar(select(func.now()))
        names = await self.names() if rows else {}
        return OutageList(
            items=[self.read(outage, until, names) for outage in rows],
            total=total or 0,
            page=page,
            page_size=page_size,
        )
