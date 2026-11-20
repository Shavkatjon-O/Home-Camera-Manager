"""FastAPI dependencies of the analytics module."""

import hmac

from fastapi import Depends, Header
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.core.database import get_db
from app.core.exceptions import Unauthorized, Unavailable
from app.modules.analytics.services import AnalyticsIngestService, AnalyticsViewService
from app.modules.analytics.services.follow import FollowPtzService
from app.modules.tenancy.deps import get_site_access
from app.modules.tenancy.services.access import SiteAccess


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
