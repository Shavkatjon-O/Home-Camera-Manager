"""FastAPI dependencies of the insights module."""

from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.modules.insights.services.counts import AreaService, CountService
from app.modules.investigation.deps import require_analytics_token
from app.modules.tenancy.deps import get_site_access
from app.modules.tenancy.services.access import SiteAccess


def get_count_service(
    session: AsyncSession = Depends(get_db),
    access: SiteAccess = Depends(get_site_access),
) -> CountService:
    """Build the count service for a signed-in request.

    Args:
        session: Request-scoped database session.
        access: Access of the signed-in member to the request's site.

    Returns:
        The service.
    """
    return CountService(session, access.user)


def get_area_service(
    session: AsyncSession = Depends(get_db),
    access: SiteAccess = Depends(get_site_access),
) -> AreaService:
    """Build the area service for a signed-in request.

    Args:
        session: Request-scoped database session.
        access: Access of the signed-in member to the request's site.

    Returns:
        The service.
    """
    return AreaService(session, access.user)


def get_count_ingest_service(
    session: AsyncSession = Depends(get_db),
    authorized: None = Depends(require_analytics_token),
) -> CountService:
    """Build the count service for a report of the analytics service.

    Args:
        session: Request-scoped database session.
        authorized: Result of the token check.

    Returns:
        The service.
    """
    return CountService(session)
