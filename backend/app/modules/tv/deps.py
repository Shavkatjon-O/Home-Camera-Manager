from fastapi import Depends
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import TvDeviceContext, UserContext
from app.auth.dependencies import get_current_user
from app.core.database import get_db
from app.modules.cameras.services import CameraService
from app.modules.tv.services import TvConfigService, TvDeviceService, TvPairingService

device_bearer = HTTPBearer(auto_error=False)


def get_pairing_service(session: AsyncSession = Depends(get_db)) -> TvPairingService:
    return TvPairingService(session)


def get_pairing_admin_service(
    session: AsyncSession = Depends(get_db),
    actor: UserContext = Depends(get_current_user),
) -> TvPairingService:
    return TvPairingService(session, actor)


def get_device_service(
    session: AsyncSession = Depends(get_db),
    actor: UserContext = Depends(get_current_user),
) -> TvDeviceService:
    return TvDeviceService(session, actor)


async def get_tv_device(
    credentials: HTTPAuthorizationCredentials | None = Depends(device_bearer),
    session: AsyncSession = Depends(get_db),
) -> TvDeviceContext:
    token = credentials.credentials if credentials is not None else None
    return await TvDeviceService(session).authenticate(token)


def get_tv_config_service(
    session: AsyncSession = Depends(get_db),
    device: TvDeviceContext = Depends(get_tv_device),
) -> TvConfigService:
    return TvConfigService(session, device)


def get_tv_camera_service(
    session: AsyncSession = Depends(get_db),
    device: TvDeviceContext = Depends(get_tv_device),
) -> CameraService:
    return CameraService(session)


def get_tv_stream_service(session: AsyncSession = Depends(get_db)) -> TvConfigService:
    return TvConfigService(session)
