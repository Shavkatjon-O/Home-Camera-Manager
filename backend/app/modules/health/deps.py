"""FastAPI dependencies that build the health services for a request."""

from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.modules.health.services import CameraLinkService, HealthOverviewService, NetworkDeviceService, OutageService
from app.tenancy.access import SiteAccess
from app.tenancy.dependencies import get_site_access


def get_network_device_service(
    session: AsyncSession = Depends(get_db),
    access: SiteAccess = Depends(get_site_access),
) -> NetworkDeviceService:
    """Build the network device service for a request.

    Args:
        session: Request-scoped database session.
        access: Access of the signed-in member to the request's site.

    Returns:
        The service bound to the session and user.
    """
    return NetworkDeviceService(session, access.user)


def get_camera_link_service(
    session: AsyncSession = Depends(get_db),
    access: SiteAccess = Depends(get_site_access),
) -> CameraLinkService:
    """Build the camera link service for a request.

    Args:
        session: Request-scoped database session.
        access: Access of the signed-in member to the request's site.

    Returns:
        The service bound to the session and user.
    """
    return CameraLinkService(session, access.user)


def get_health_overview_service(
    session: AsyncSession = Depends(get_db),
    access: SiteAccess = Depends(get_site_access),
) -> HealthOverviewService:
    """Build the health overview service for a request.

    Args:
        session: Request-scoped database session.
        access: Access of the signed-in member to the request's site.

    Returns:
        The service bound to the session and user.
    """
    return HealthOverviewService(session, access.user)


def get_outage_service(
    session: AsyncSession = Depends(get_db),
    access: SiteAccess = Depends(get_site_access),
) -> OutageService:
    """Build the outage service for a request.

    Args:
        session: Request-scoped database session.
        access: Access of the signed-in member to the request's site.

    Returns:
        The service bound to the session and user.
    """
    return OutageService(session, access.user)
