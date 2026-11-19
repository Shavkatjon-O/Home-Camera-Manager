"""FastAPI dependencies of the events module."""

from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.auth.dependencies import get_current_user
from app.core.database import get_db
from app.modules.events.services import EventService


def get_event_service(
    session: AsyncSession = Depends(get_db),
    actor: UserContext = Depends(get_current_user),
) -> EventService:
    """Build the event service for a signed-in request.

    Args:
        session: Request-scoped database session.
        actor: Signed-in user.

    Returns:
        The service.
    """
    return EventService(session, actor)
