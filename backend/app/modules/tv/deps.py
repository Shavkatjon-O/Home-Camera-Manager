"""FastAPI dependencies of the TV module."""

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
    """Build the pairing service for requests a TV makes without a token.

    Args:
        session: Database session for the request.

    Returns:
        Pairing service without an acting user.
    """
    return TvPairingService(session)


def get_pairing_admin_service(
    session: AsyncSession = Depends(get_db),
    actor: UserContext = Depends(get_current_user),
) -> TvPairingService:
    """Build the pairing service for a signed-in user.

    Args:
        session: Database session for the request.
        actor: Signed-in user making the request.

    Returns:
        Pairing service acting for the user.
    """
    return TvPairingService(session, actor)


def get_device_service(
    session: AsyncSession = Depends(get_db),
    actor: UserContext = Depends(get_current_user),
) -> TvDeviceService:
    """Build the device service for a signed-in user.

    Args:
        session: Database session for the request.
        actor: Signed-in user making the request.

    Returns:
        Device service acting for the user.
    """
    return TvDeviceService(session, actor)


async def get_tv_device(
    credentials: HTTPAuthorizationCredentials | None = Depends(device_bearer),
    session: AsyncSession = Depends(get_db),
) -> TvDeviceContext:
    """Authenticate the TV behind a request from its bearer device token.

    Args:
        credentials: Bearer credentials of the request, if sent.
        session: Database session for the request.

    Returns:
        The paired device that owns the token.
    """
    token = credentials.credentials if credentials is not None else None
    return await TvDeviceService(session).authenticate(token)


def get_tv_config_service(
    session: AsyncSession = Depends(get_db),
    device: TvDeviceContext = Depends(get_tv_device),
) -> TvConfigService:
    """Build the config service for an authenticated TV.

    Args:
        session: Database session for the request.
        device: Paired TV making the request.

    Returns:
        Config service acting for the device.
    """
    return TvConfigService(session, device)


def get_tv_camera_service(
    session: AsyncSession = Depends(get_db),
    device: TvDeviceContext = Depends(get_tv_device),
) -> CameraService:
    """Build the camera service for an authenticated TV.

    Args:
        session: Database session for the request.
        device: Paired TV making the request; it only has to authenticate.

    Returns:
        Camera service without an acting user.
    """
    return CameraService(session)


def get_tv_stream_service(session: AsyncSession = Depends(get_db)) -> TvConfigService:
    """Build the config service for the stream endpoints, which carry no device token.

    Args:
        session: Database session for the request.

    Returns:
        Config service without a device.
    """
    return TvConfigService(session)
