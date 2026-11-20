"""Owner lookups for rows written in bulk, which skip the ownership stamping of the ORM."""

from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import AnalyticsView
from app.tenancy.scope import UNSCOPED_OPTION

__all__ = ["view_owners"]


async def view_owners(session: AsyncSession, view_uuids: set[UUID]) -> dict[UUID, dict[str, int | None]]:
    """Load the site and organisation of views.

    Args:
        session: Database session.
        view_uuids: Public ids of the views.

    Returns:
        View id to a mapping with site_id and organisation_id, ready to merge into a row.
    """
    if not view_uuids:
        return {}
    rows = await session.execute(
        select(AnalyticsView.uuid, AnalyticsView.site_id, AnalyticsView.organisation_id)
        .where(AnalyticsView.uuid.in_(list(view_uuids)))
        .execution_options(**{UNSCOPED_OPTION: True})
    )
    return {uuid: {"site_id": site_id, "organisation_id": organisation_id} for uuid, site_id, organisation_id in rows}
