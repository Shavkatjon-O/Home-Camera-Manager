import jwt
from fastapi import Depends
from fastapi.security import APIKeyCookie
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.core.database import get_db
from app.core.exceptions import Unauthorized
from app.core.security import SESSION_COOKIE, decode_session_token
from app.models import User

session_cookie = APIKeyCookie(name=SESSION_COOKIE, auto_error=False)


def not_authenticated() -> Unauthorized:
    return Unauthorized("not_authenticated", "Sign in to continue")


async def get_current_user(
    token: str | None = Depends(session_cookie),
    session: AsyncSession = Depends(get_db),
) -> UserContext:
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
