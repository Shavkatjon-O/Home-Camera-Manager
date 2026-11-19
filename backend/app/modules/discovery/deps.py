"""FastAPI dependencies of the camera discovery module."""

from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.auth.dependencies import get_current_user
from app.core.database import get_db
from app.modules.discovery.services import DiscoveryService


def get_discovery_service(
    session: AsyncSession = Depends(get_db),
    actor: UserContext = Depends(get_current_user),
) -> DiscoveryService:
    """Build the discovery service for a signed-in request.

    Args:
        session: Request-scoped database session.
        actor: Signed-in user making the request.

    Returns:
        Discovery service bound to the session and the user.
    """
    return DiscoveryService(session, actor)
