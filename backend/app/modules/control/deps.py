"""FastAPI dependencies of the camera control module."""

from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.auth.dependencies import get_current_user
from app.core.database import get_db
from app.modules.control.services import CameraControlService


def get_control_service(
    session: AsyncSession = Depends(get_db),
    actor: UserContext = Depends(get_current_user),
) -> CameraControlService:
    """Build the camera control service for a request.

    Args:
        session: Database session for the request.
        actor: Signed-in user making the request.

    Returns:
        Service bound to the session and the user.
    """
    return CameraControlService(session, actor)
