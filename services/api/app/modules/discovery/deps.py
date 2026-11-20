"""FastAPI dependencies of the camera discovery module."""

from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.modules.discovery.services import DiscoveryService
from app.tenancy.access import SiteAccess
from app.tenancy.dependencies import get_site_access


def get_discovery_service(
    session: AsyncSession = Depends(get_db),
    access: SiteAccess = Depends(get_site_access),
) -> DiscoveryService:
    """Build the discovery service for a signed-in request.

    Args:
        session: Request-scoped database session.
        access: Access of the signed-in member to the request's site.

    Returns:
        Discovery service bound to the session and the user.
    """
    return DiscoveryService(session, access.user)
