"""FastAPI dependencies of the alerting module."""

from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.auth.dependencies import get_current_user
from app.core.database import get_db
from app.modules.alerting.services import AnalyticsSettingsService, PushTargetService
from app.modules.tenancy.deps import get_site_access
from app.modules.tenancy.services.access import SiteAccess


def get_push_service(
    session: AsyncSession = Depends(get_db), actor: UserContext = Depends(get_current_user)
) -> PushTargetService:
    """Build the push target service for a signed-in request.

    Args:
        session: Request-scoped database session.
        actor: Signed-in user.

    Returns:
        The service.
    """
    return PushTargetService(session, actor)


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
