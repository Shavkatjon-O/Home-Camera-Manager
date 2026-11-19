"""Passwords, session tokens and cookies, secret encryption and device tokens."""

import base64
import hashlib
import hmac
import secrets
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

TOKEN_BYTES = 32


def require_secret_key() -> str:
    """Return the secret key that signs sessions and encrypts stored secrets.

    Returns:
        The configured secret key.

    Raises:
        RuntimeError: HC_SECRET_KEY is not set.
    """
    if not settings.secret_key:
        raise RuntimeError("HC_SECRET_KEY is not set")
    return settings.secret_key


def hash_password(password: str) -> str:
    """Hash a password with bcrypt and a fresh salt.

    Args:
        password: Plain password.

    Returns:
        The bcrypt hash.

    Raises:
        ValueError: The password is longer than the 72 bytes bcrypt reads.
    """
    raw = password.encode()
    if len(raw) > BCRYPT_MAX_BYTES:
        raise ValueError("The password is longer than 72 bytes")
    return bcrypt.hashpw(raw, bcrypt.gensalt()).decode()


def verify_password(password_hash: str, password: str) -> bool:
    """Check a password against its bcrypt hash.

    Args:
        password_hash: Stored bcrypt hash.
        password: Plain password to check.

    Returns:
        True when the password matches, False when it does not, is longer than 72 bytes or the
        hash is malformed.
    """
    raw = password.encode()
    if len(raw) > BCRYPT_MAX_BYTES:
        return False
    try:
        return bcrypt.checkpw(raw, password_hash.encode())
    except ValueError:
        return False


@lru_cache
def placeholder_hash() -> str:
    """Return a hash to check passwords against when the username is unknown.

    Checking a password for an unknown user costs as much as for a real one, so response times
    do not reveal which usernames exist.

    Returns:
        Bcrypt hash of a fixed placeholder password, computed once.
    """
    return hash_password("placeholder-password")


@lru_cache
def session_key() -> bytes:
    """Derive the session signing key from the secret key.

    Returns:
        HMAC-SHA256 of the session key label under the secret key, computed once.
    """
    return hmac.new(require_secret_key().encode(), SESSION_KEY_LABEL, hashlib.sha256).digest()


def session_lifetime() -> timedelta:
    """Return how long a session stays valid.

    Returns:
        The configured session length.
    """
    return timedelta(hours=settings.session_hours)


def create_session_token(user_uuid: UUID) -> str:
    """Sign a session token for a user.

    Args:
        user_uuid: Public id of the user.

    Returns:
        HS256 JWT naming the user, issued now and expiring after the session lifetime.
    """
    now = datetime.now(UTC)
    claims = {
        "iss": APP_NAME,
        "sub": str(user_uuid),
        "iat": now,
        "exp": now + session_lifetime(),
    }
    return jwt.encode(claims, session_key(), algorithm=ALGORITHM)


def decode_session_token(token: str) -> UUID:
    """Verify a session token and return the user it names.

    Args:
        token: Session token from the cookie.

    Returns:
        Public id of the user.

    Raises:
        jwt.PyJWTError: The token is malformed, wrongly signed, from another issuer, expired or
            missing a required claim.
        ValueError: The subject is not a UUID.
    """
    claims = jwt.decode(
        token,
        session_key(),
        algorithms=[ALGORITHM],
        issuer=APP_NAME,
        options={"require": ["exp", "iat", "sub", "iss"]},
    )
    return UUID(str(claims["sub"]))


def set_session_cookie(response: Response, token: str) -> None:
    """Store a session token in an HTTP-only cookie that lasts as long as the session.

    Args:
        response: Response to set the cookie on.
        token: Session token to store.
    """
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
    """Remove the session cookie.

    Args:
        response: Response to clear the cookie on.
    """
    response.delete_cookie(
        SESSION_COOKIE,
        path=SESSION_COOKIE_PATH,
        httponly=True,
        samesite=SESSION_COOKIE_SAMESITE,
        secure=False,
    )


@lru_cache
def fernet() -> Fernet:
    """Build the cipher that encrypts stored secrets such as camera passwords.

    Returns:
        Fernet keyed by the SHA-256 digest of the secret key, built once.
    """
    digest = hashlib.sha256(require_secret_key().encode()).digest()
    return Fernet(base64.urlsafe_b64encode(digest))


def encrypt_secret(value: str) -> str:
    """Encrypt a secret for storage.

    Args:
        value: Plain secret.

    Returns:
        Fernet token as text.
    """
    return fernet().encrypt(value.encode()).decode()


def decrypt_secret(value: str | None) -> str | None:
    """Decrypt a stored secret.

    Args:
        value: Fernet token as text, if any.

    Returns:
        The plain secret, or None when there is none or it cannot be decrypted with the current key.
    """
    if not value:
        return None
    try:
        return fernet().decrypt(value.encode()).decode()
    except InvalidToken:
        return None


def new_token() -> str:
    """Generate a random URL-safe token, such as a TV device token.

    Returns:
        Token carrying 32 random bytes.
    """
    return secrets.token_urlsafe(TOKEN_BYTES)


def hash_token(token: str) -> str:
    """Hash a token for storage and lookup.

    Args:
        token: Plain token.

    Returns:
        Hex SHA-256 digest of the token.
    """
    return hashlib.sha256(token.encode()).hexdigest()
