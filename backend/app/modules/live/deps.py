"""FastAPI dependencies of the live module."""

from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.modules.live.services import LiveService
from app.tenancy.access import SiteAccess
from app.tenancy.dependencies import get_site_access


def get_live_service(
    session: AsyncSession = Depends(get_db), access: SiteAccess = Depends(get_site_access)
) -> LiveService:
    """Build the live service for a member of the request's site.

    Args:
        session: Request-scoped database session, limited to the site by the access.
        access: Access of the signed-in member to the request's site.

    Returns:
        The service.
    """
    return LiveService(session)
