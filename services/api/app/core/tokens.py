"""Access tokens of the apps: ES256 JWTs that name only the user and the device session."""

import base64
import hashlib
import json
from dataclasses import dataclass
from datetime import UTC, datetime, timedelta
from functools import lru_cache
from uuid import UUID

import jwt
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.primitives.kdf.hkdf import HKDF

from app.core.config import APP_NAME, settings
from app.core.security import require_secret_key

__all__ = [
    "ACCESS_ALGORITHM",
    "AccessClaims",
    "create_access_token",
    "decode_access_token",
    "derive_key",
    "jwks",
    "key_id",
    "signing_key",
]

ACCESS_ALGORITHM = "ES256"
ACCESS_TYPE = "access"
KEY_LABEL = b"smart-surveillance-system access token key"
P256_ORDER = 0xFFFFFFFF00000000FFFFFFFFFFFFFFFFBCE6FAADA7179E84F3B9CAC2FC632551


@dataclass(frozen=True)
class AccessClaims:
    """What a verified access token says.

    Attributes:
        user_uuid: Public id of the user.
        session_uuid: Public id of the device session.
    """

    user_uuid: UUID
    session_uuid: UUID


def derive_key(secret: str) -> ec.EllipticCurvePrivateKey:
    """Derive a P-256 signing key from a secret.

    Args:
        secret: Secret text.

    Returns:
        The key, the same for the same secret.
    """
    material = HKDF(algorithm=hashes.SHA256(), length=48, salt=None, info=KEY_LABEL).derive(secret.encode())
    scalar = int.from_bytes(material, "big") % (P256_ORDER - 1) + 1
    return ec.derive_private_key(scalar, ec.SECP256R1())


@lru_cache
def signing_key() -> ec.EllipticCurvePrivateKey:
    """Return the key that signs access tokens.

    Returns:
        The key from SSS_ACCESS_TOKEN_KEY, or one derived from the secret key when that is empty.

    Raises:
        ValueError: SSS_ACCESS_TOKEN_KEY is not a P-256 private key.
    """
    if settings.access_token_key.strip():
        key = serialization.load_pem_private_key(settings.access_token_key.encode(), password=None)
        if not isinstance(key, ec.EllipticCurvePrivateKey) or key.curve.name != "secp256r1":
            raise ValueError("SSS_ACCESS_TOKEN_KEY must be a P-256 private key")
        return key
    return derive_key(require_secret_key())


def b64url(value: bytes) -> str:
    """Encode bytes as unpadded base64url.

    Args:
        value: Bytes.

    Returns:
        The text.
    """
    return base64.urlsafe_b64encode(value).rstrip(b"=").decode()


def public_jwk(key: ec.EllipticCurvePrivateKey) -> dict:
    """Describe the public half of a key as a JSON Web Key.

    Args:
        key: The private key.

    Returns:
        The JWK members kty, crv, x and y.
    """
    numbers = key.public_key().public_numbers()
    return {
        "kty": "EC",
        "crv": "P-256",
        "x": b64url(numbers.x.to_bytes(32, "big")),
        "y": b64url(numbers.y.to_bytes(32, "big")),
    }


def key_id(key: ec.EllipticCurvePrivateKey) -> str:
    """Compute the RFC 7638 thumbprint that names a key.

    Args:
        key: The private key.

    Returns:
        The thumbprint as base64url.
    """
    canonical = json.dumps(public_jwk(key), sort_keys=True, separators=(",", ":")).encode()
    return b64url(hashlib.sha256(canonical).digest())


def jwks() -> dict:
    """Return the public key set that verifies access tokens.

    Returns:
        A JWK set with the signing key's public half.
    """
    key = signing_key()
    return {"keys": [{**public_jwk(key), "kid": key_id(key), "use": "sig", "alg": ACCESS_ALGORITHM}]}


def access_lifetime() -> timedelta:
    """Return how long an access token is valid.

    Returns:
        The configured lifetime.
    """
    return timedelta(minutes=settings.access_token_minutes)


def create_access_token(user_uuid: UUID, session_uuid: UUID, now: datetime | None = None) -> tuple[str, int]:
    """Sign an access token for a device session.

    Args:
        user_uuid: Public id of the user.
        session_uuid: Public id of the session.
        now: Issue time, the current time when omitted.

    Returns:
        The token and its lifetime in seconds.
    """
    issued = now or datetime.now(UTC)
    lifetime = access_lifetime()
    claims = {
        "iss": APP_NAME,
        "typ": ACCESS_TYPE,
        "sub": str(user_uuid),
        "sid": str(session_uuid),
        "iat": issued,
        "exp": issued + lifetime,
    }
    key = signing_key()
    token = jwt.encode(claims, key, algorithm=ACCESS_ALGORITHM, headers={"kid": key_id(key)})
    return token, int(lifetime.total_seconds())


def decode_access_token(token: str) -> AccessClaims:
    """Verify an access token.

    Args:
        token: The bearer token.

    Returns:
        The user and session it names.

    Raises:
        jwt.PyJWTError: The token is malformed, wrongly signed, expired, from another issuer or not an access token.
        ValueError: A subject or session id is not a UUID.
    """
    claims = jwt.decode(
        token,
        signing_key().public_key(),
        algorithms=[ACCESS_ALGORITHM],
        issuer=APP_NAME,
        options={"require": ["exp", "iat", "sub", "sid", "iss"]},
    )
    if claims.get("typ") != ACCESS_TYPE:
        raise jwt.InvalidTokenError("not an access token")
    return AccessClaims(user_uuid=UUID(str(claims["sub"])), session_uuid=UUID(str(claims["sid"])))
