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
    return NetworkDeviceService(session, actor)


def get_camera_link_service(
    session: AsyncSession = Depends(get_db),
    actor: UserContext = Depends(get_current_user),
) -> CameraLinkService:
    return CameraLinkService(session, actor)


def get_health_overview_service(
    session: AsyncSession = Depends(get_db),
    actor: UserContext = Depends(get_current_user),
) -> HealthOverviewService:
    return HealthOverviewService(session, actor)


def get_outage_service(
    session: AsyncSession = Depends(get_db),
    actor: UserContext = Depends(get_current_user),
) -> OutageService:
    return OutageService(session, actor)
