"""FastAPI dependencies that build the health services for a request."""

from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.auth.dependencies import get_current_user
from app.core.database import get_db
from app.modules.health.services import CameraLinkService, HealthOverviewService, NetworkDeviceService, OutageService


def get_network_device_service(
    session: AsyncSession = Depends(get_db),
    actor: UserContext = Depends(get_current_user),
) -> NetworkDeviceService:
    """Build the network device service for a request.

    Args:
        session: Request-scoped database session.
        actor: Signed-in user making the request.

    Returns:
        The service bound to the session and user.
    """
    return NetworkDeviceService(session, actor)


def get_camera_link_service(
    session: AsyncSession = Depends(get_db),
    actor: UserContext = Depends(get_current_user),
) -> CameraLinkService:
    """Build the camera link service for a request.

    Args:
        session: Request-scoped database session.
        actor: Signed-in user making the request.

    Returns:
        The service bound to the session and user.
    """
    return CameraLinkService(session, actor)


def get_health_overview_service(
    session: AsyncSession = Depends(get_db),
    actor: UserContext = Depends(get_current_user),
) -> HealthOverviewService:
    """Build the health overview service for a request.

    Args:
        session: Request-scoped database session.
        actor: Signed-in user making the request.

    Returns:
        The service bound to the session and user.
    """
    return HealthOverviewService(session, actor)


def get_outage_service(
    session: AsyncSession = Depends(get_db),
    actor: UserContext = Depends(get_current_user),
) -> OutageService:
    """Build the outage service for a request.

    Args:
        session: Request-scoped database session.
        actor: Signed-in user making the request.

    Returns:
        The service bound to the session and user.
    """
    return OutageService(session, actor)
