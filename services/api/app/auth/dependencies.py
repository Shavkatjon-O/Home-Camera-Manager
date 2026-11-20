"""FastAPI dependencies that resolve the signed-in user from a bearer access token or the web session cookie."""

from datetime import UTC, datetime

import jwt
from fastapi import Depends
from fastapi.security import APIKeyCookie, HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.core.database import async_session_maker, get_db
from app.core.exceptions import Unauthorized
from app.core.security import SESSION_COOKIE, decode_session_token
from app.core.tokens import decode_access_token
from app.models import AuthSession, User

session_cookie = APIKeyCookie(name=SESSION_COOKIE, auto_error=False)
access_bearer = HTTPBearer(auto_error=False)


def not_authenticated() -> Unauthorized:
    """Build the error returned when a request has no valid session.

    Returns:
        Error with the not_authenticated code.
    """
    return Unauthorized("not_authenticated", "Sign in to continue")


async def user_from_token(token: str | None, session: AsyncSession) -> UserContext:
    """Resolve a web session token to the live user it was issued for.

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


async def user_from_access_token(token: str, session: AsyncSession) -> UserContext:
    """Resolve a bearer access token to its live user and device session.

    The session is checked on every request, so a revoked session or a deleted account stops working at once
    rather than when the token expires.

    Args:
        token: The access token.
        session: Database session used to load the user and the device session.

    Returns:
        Identity of the user with the device session.

    Raises:
        Unauthorized: The token is invalid or expired, or its session or user is gone.
    """
    try:
        claims = decode_access_token(token)
    except (jwt.PyJWTError, ValueError):
        raise Unauthorized("invalid_token", "The access token is invalid or expired")
    row = (
        await session.execute(
            select(User, AuthSession)
            .join(AuthSession, AuthSession.user_id == User.id)
            .where(
                User.uuid == claims.user_uuid,
                User.deleted_at.is_(None),
                AuthSession.uuid == claims.session_uuid,
                AuthSession.revoked_at.is_(None),
                AuthSession.expires_at > datetime.now(UTC),
            )
        )
    ).first()
    if row is None:
        raise Unauthorized("invalid_token", "The session has ended")
    user, device = row
    return UserContext(
        id=user.id, uuid=user.uuid, username=user.username, session_id=device.id, session_uuid=device.uuid
    )


async def authenticate(
    cookie: str | None, credentials: HTTPAuthorizationCredentials | None, session: AsyncSession
) -> UserContext:
    """Resolve the bearer token, or else the session cookie, of a request.

    Args:
        cookie: Web session token, if any.
        credentials: Bearer credentials, if any.
        session: Database session.

    Returns:
        Identity of the signed-in user.

    Raises:
        Unauthorized: Neither credential is valid.
    """
    if credentials is not None and credentials.credentials:
        return await user_from_access_token(credentials.credentials, session)
    return await user_from_token(cookie, session)


async def get_current_user(
    token: str | None = Depends(session_cookie),
    credentials: HTTPAuthorizationCredentials | None = Depends(access_bearer),
    session: AsyncSession = Depends(get_db),
) -> UserContext:
    """Require a signed-in user, checked against the request's database session.

    Args:
        token: Web session token from the cookie, if any.
        credentials: Bearer access token, if any.
        session: Request-scoped database session.

    Returns:
        Identity of the signed-in user.

    Raises:
        Unauthorized: The request has no valid session.
    """
    return await authenticate(token, credentials, session)


async def get_stream_user(
    token: str | None = Depends(session_cookie),
    credentials: HTTPAuthorizationCredentials | None = Depends(access_bearer),
) -> UserContext:
    """Require a signed-in user for a long-lived streaming response.

    The user is checked in a short session of its own, so the stream does not hold a database
    connection for as long as it stays open.

    Args:
        token: Web session token from the cookie, if any.
        credentials: Bearer access token, if any.

    Returns:
        Identity of the signed-in user.

    Raises:
        Unauthorized: The request has no valid session.
    """
    async with async_session_maker() as session:
        return await authenticate(token, credentials, session)
