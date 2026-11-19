"""FastAPI dependencies of the analytics module."""

import hmac

from fastapi import Depends, Header
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.auth.dependencies import get_current_user
from app.core.config import settings
from app.core.database import get_db
from app.core.exceptions import Unauthorized, Unavailable
from app.modules.analytics.services import AnalyticsIngestService, AnalyticsSettingsService, AnalyticsViewService


def get_view_service(
    session: AsyncSession = Depends(get_db),
    actor: UserContext = Depends(get_current_user),
) -> AnalyticsViewService:
    """Build the view service for a signed-in request.

    Args:
        session: Request-scoped database session.
        actor: Signed-in user.

    Returns:
        The service.
    """
    return AnalyticsViewService(session, actor)


def get_settings_service(
    session: AsyncSession = Depends(get_db),
    actor: UserContext = Depends(get_current_user),
) -> AnalyticsSettingsService:
    """Build the settings service for a signed-in request.

    Args:
        session: Request-scoped database session.
        actor: Signed-in user.

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
        raise Unavailable("analytics_disabled", "HC_ANALYTICS_TOKEN is not set")
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
