"""FastAPI dependencies of the push module."""

from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.auth.dependencies import get_current_user
from app.core.database import get_db
from app.modules.push.services import PushTargetService


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
