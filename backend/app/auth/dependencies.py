"""FastAPI dependencies that resolve the signed-in user from the session cookie."""

import jwt
from fastapi import Depends
from fastapi.security import APIKeyCookie
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.core.database import async_session_maker, get_db
from app.core.exceptions import Unauthorized
from app.core.security import SESSION_COOKIE, decode_session_token
from app.models import User

session_cookie = APIKeyCookie(name=SESSION_COOKIE, auto_error=False)


def not_authenticated() -> Unauthorized:
    """Build the error returned when a request has no valid session.

    Returns:
        Error with the not_authenticated code.
    """
    return Unauthorized("not_authenticated", "Sign in to continue")


async def user_from_token(token: str | None, session: AsyncSession) -> UserContext:
    """Resolve a session token to the live user it was issued for.

    Args:
        token: Session token from the cookie, if any.
        session: Database session used to load the user.

    Returns:
        Identity of the user named by the token.

    Raises:
        Unauthorized: The token is missing, invalid or expired, or its user is gone or deleted.
    """
    if not token:
        raise not_authenticated()
    try:
        user_uuid = decode_session_token(token)
    except (jwt.PyJWTError, KeyError, ValueError):
        raise not_authenticated()
    user = await session.scalar(select(User).where(User.uuid == user_uuid, User.deleted_at.is_(None)))
    if user is None:
        raise not_authenticated()
    return UserContext(id=user.id, uuid=user.uuid, username=user.username)


async def get_current_user(
    token: str | None = Depends(session_cookie),
    session: AsyncSession = Depends(get_db),
) -> UserContext:
    """Require a signed-in user, checked against the request's database session.

    Args:
        token: Session token from the cookie, if any.
        session: Request-scoped database session.

    Returns:
        Identity of the signed-in user.

    Raises:
        Unauthorized: The request has no valid session.
    """
    return await user_from_token(token, session)


async def get_stream_user(token: str | None = Depends(session_cookie)) -> UserContext:
    """Require a signed-in user for a long-lived streaming response.

    The user is checked in a short session of its own, so the stream does not hold a database
    connection for as long as it stays open.

    Args:
        token: Session token from the cookie, if any.

    Returns:
        Identity of the signed-in user.

    Raises:
        Unauthorized: The request has no valid session.
    """
    async with async_session_maker() as session:
        return await user_from_token(token, session)
