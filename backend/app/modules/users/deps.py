"""FastAPI dependencies of the users module."""

from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.modules.users.services import UserService


def get_user_service(session: AsyncSession = Depends(get_db)) -> UserService:
    """Build the user service for a request that is not signed in yet.

    Args:
        session: Request-scoped database session.

    Returns:
        User service bound to the session.
    """
    return UserService(session)
