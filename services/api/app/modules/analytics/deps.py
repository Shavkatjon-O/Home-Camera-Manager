"""FastAPI dependencies of the analytics module."""

import hmac

from fastapi import Depends, Header
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.core.database import get_db
from app.core.exceptions import Unauthorized, Unavailable
from app.modules.analytics.services import AnalyticsIngestService, AnalyticsSettingsService, AnalyticsViewService
from app.modules.analytics.services.counts import AreaService, CountService
from app.modules.analytics.services.follow import FollowPtzService
from app.modules.analytics.services.journeys import JourneyService
from app.tenancy.access import SiteAccess
from app.tenancy.dependencies import get_site_access


def get_view_service(
    session: AsyncSession = Depends(get_db),
    access: SiteAccess = Depends(get_site_access),
) -> AnalyticsViewService:
    """Build the view service for a signed-in request.

    Args:
        session: Request-scoped database session.
        access: Access of the signed-in member to the request's site.

    Returns:
        The service.
    """
    return AnalyticsViewService(session, access.user)


def get_settings_service(
    session: AsyncSession = Depends(get_db),
    access: SiteAccess = Depends(get_site_access),
) -> AnalyticsSettingsService:
    """Build the settings service for a signed-in request.

    Args:
        session: Request-scoped database session.
        access: Access of the signed-in member to the request's site.

    Returns:
        The service.
    """
    return AnalyticsSettingsService(session)


def require_analytics_token(authorization: str = Header("")) -> None:
    """Require the analytics service's shared token.

    Args:
        authorization: The Authorization header.

    Raises:
        Unavailable: No token is configured, so the internal endpoints are off.
        Unauthorized: The header does not carry the token.
    """
    if not settings.analytics_token:
        raise Unavailable("analytics_disabled", "SSS_ANALYTICS_TOKEN is not set")
    if not hmac.compare_digest(authorization.encode(), f"Bearer {settings.analytics_token}".encode()):
        raise Unauthorized("invalid_token", "The analytics token is missing or wrong")


def get_ingest_service(
    session: AsyncSession = Depends(get_db),
    authorized: None = Depends(require_analytics_token),
) -> AnalyticsIngestService:
    """Build the ingest service for a request of the analytics service.

    Args:
        session: Request-scoped database session.
        authorized: Result of the token check.

    Returns:
        The service.
    """
    return AnalyticsIngestService(session)


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


def get_journey_service(
    session: AsyncSession = Depends(get_db),
    access: SiteAccess = Depends(get_site_access),
) -> JourneyService:
    """Build the journey service for a signed-in request.

    Args:
        session: Request-scoped database session.
        access: Access of the signed-in member to the request's site.

    Returns:
        The service.
    """
    return JourneyService(session, access.user)


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


def get_journey_ingest_service(
    session: AsyncSession = Depends(get_db),
    authorized: None = Depends(require_analytics_token),
) -> JourneyService:
    """Build the journey service for a report of the analytics service.

    Args:
        session: Request-scoped database session.
        authorized: Result of the token check.

    Returns:
        The service.
    """
    return JourneyService(session)


def get_follow_service(
    session: AsyncSession = Depends(get_db),
    authorized: None = Depends(require_analytics_token),
) -> FollowPtzService:
    """Build the follow PTZ service for a command of the analytics service.

    Args:
        session: Request-scoped database session.
        authorized: Result of the token check.

    Returns:
        The service.
    """
    return FollowPtzService(session)
