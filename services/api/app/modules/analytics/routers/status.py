"""Route of the analytics service status."""

from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.analytics.observations import observations
from app.core.database import get_db
from app.models import AnalyticsView
from app.modules.analytics.schemas import AnalyticsStatus
from app.modules.tenancy.deps import get_site_access
from app.modules.tenancy.services.access import SiteAccess

router = APIRouter()


@router.get("/status", response_model=AnalyticsStatus)
async def read_analytics_status(
    access: SiteAccess = Depends(get_site_access), session: AsyncSession = Depends(get_db)
) -> AnalyticsStatus:
    """Return the latest state the analytics service reported, with the views of the request's site only.

    Args:
        access: Access of the signed-in member to the request's site.
        session: Request-scoped database session, limited to the site.

    Returns:
        The status.
    """
    site_views = {str(uuid) for uuid in await session.scalars(select(AnalyticsView.uuid))}
    return AnalyticsStatus(
        pipeline=observations.pipeline,
        gpu=observations.gpu,
        updated_at=observations.updated_at,
        views={key: value for key, value in observations.views.items() if key in site_views},
    )
