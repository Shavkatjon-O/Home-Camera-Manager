import base64
import hashlib
import hmac
from datetime import UTC, datetime, timedelta
from functools import lru_cache
from uuid import UUID

import bcrypt
import jwt
from cryptography.fernet import Fernet, InvalidToken
from starlette.responses import Response

from app.core.config import APP_NAME, settings

ALGORITHM = "HS256"
SESSION_KEY_LABEL = b"home-cameras session"

SESSION_COOKIE = "hc_session"
SESSION_COOKIE_PATH = "/"
SESSION_COOKIE_SAMESITE = "lax"

BCRYPT_MAX_BYTES = 72


def require_secret_key() -> str:
    if not settings.secret_key:
        raise RuntimeError("HC_SECRET_KEY is not set")
    return settings.secret_key


def hash_password(password: str) -> str:
    raw = password.encode()
    if len(raw) > BCRYPT_MAX_BYTES:
        raise ValueError("The password is longer than 72 bytes")
    return bcrypt.hashpw(raw, bcrypt.gensalt()).decode()


def verify_password(password_hash: str, password: str) -> bool:
    raw = password.encode()
    if len(raw) > BCRYPT_MAX_BYTES:
        return False
    try:
        return bcrypt.checkpw(raw, password_hash.encode())
    except ValueError:
        return False


@lru_cache
def placeholder_hash() -> str:
    return hash_password("placeholder-password")


@lru_cache
def session_key() -> bytes:
    return hmac.new(require_secret_key().encode(), SESSION_KEY_LABEL, hashlib.sha256).digest()


def session_lifetime() -> timedelta:
    return timedelta(hours=settings.session_hours)


def create_session_token(user_uuid: UUID) -> str:
    now = datetime.now(UTC)
    claims = {
        "iss": APP_NAME,
        "sub": str(user_uuid),
        "iat": now,
        "exp": now + session_lifetime(),
    }
    return jwt.encode(claims, session_key(), algorithm=ALGORITHM)


def decode_session_token(token: str) -> UUID:
    claims = jwt.decode(
        token,
        session_key(),
        algorithms=[ALGORITHM],
        issuer=APP_NAME,
        options={"require": ["exp", "iat", "sub", "iss"]},
    )
    return UUID(str(claims["sub"]))


def set_session_cookie(response: Response, token: str) -> None:
    response.set_cookie(
        SESSION_COOKIE,
        token,
        max_age=int(session_lifetime().total_seconds()),
        path=SESSION_COOKIE_PATH,
        httponly=True,
        samesite=SESSION_COOKIE_SAMESITE,
        secure=False,
    )


def clear_session_cookie(response: Response) -> None:
    response.delete_cookie(
        SESSION_COOKIE,
        path=SESSION_COOKIE_PATH,
        httponly=True,
        samesite=SESSION_COOKIE_SAMESITE,
        secure=False,
    )


@lru_cache
def fernet() -> Fernet:
    digest = hashlib.sha256(require_secret_key().encode()).digest()
    return Fernet(base64.urlsafe_b64encode(digest))


def encrypt_secret(value: str) -> str:
    return fernet().encrypt(value.encode()).decode()


def decrypt_secret(value: str | None) -> str | None:
    if not value:
        return None
    try:
        return fernet().decrypt(value.encode()).decode()
    except InvalidToken:
        return None
