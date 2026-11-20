from datetime import UTC, datetime, timedelta
from uuid import uuid4

import jwt
import pytest
from cryptography.hazmat.primitives.asymmetric import ec

from app.core import tokens
from app.core.config import APP_NAME, settings
from app.core.tokens import (
    create_access_token,
    decode_access_token,
    derive_key,
    jwks,
    key_id,
    signing_key,
)


@pytest.fixture(autouse=True)
def secret(monkeypatch):
    monkeypatch.setattr(settings, "secret_key", "test-secret")
    monkeypatch.setattr(settings, "access_token_key", "")
    signing_key.cache_clear()
    yield
    signing_key.cache_clear()


def claims(**changes):
    now = datetime.now(UTC)
    data = {
        "iss": APP_NAME,
        "typ": "access",
        "sub": str(uuid4()),
        "sid": str(uuid4()),
        "iat": now,
        "exp": now + timedelta(minutes=5),
    }
    data.update(changes)
    return data


def test_derive_key_is_deterministic_per_secret():
    first = derive_key("one").private_numbers().private_value
    assert derive_key("one").private_numbers().private_value == first


def test_derive_key_differs_between_secrets():
    assert derive_key("one").private_numbers().private_value != derive_key("two").private_numbers().private_value


def test_access_token_round_trips_user_and_session():
    user, session = uuid4(), uuid4()
    token, lifetime = create_access_token(user, session)
    decoded = decode_access_token(token)
    assert decoded.user_uuid == user
    assert decoded.session_uuid == session
    assert lifetime == settings.access_token_minutes * 60


def test_token_header_names_the_signing_key():
    token, _ = create_access_token(uuid4(), uuid4())
    assert jwt.get_unverified_header(token)["kid"] == key_id(signing_key())


def test_token_with_another_type_is_refused():
    token = jwt.encode(claims(typ="refresh"), signing_key(), algorithm="ES256")
    with pytest.raises(jwt.InvalidTokenError):
        decode_access_token(token)


def test_expired_token_is_refused():
    token, _ = create_access_token(uuid4(), uuid4(), now=datetime(2020, 1, 1, tzinfo=UTC))
    with pytest.raises(jwt.ExpiredSignatureError):
        decode_access_token(token)


def test_token_signed_by_another_key_is_refused():
    token = jwt.encode(claims(), derive_key("other"), algorithm="ES256")
    with pytest.raises(jwt.InvalidSignatureError):
        decode_access_token(token)


def test_hs256_token_is_refused():
    token = jwt.encode(claims(), "test-secret-" * 4, algorithm="HS256")
    with pytest.raises(jwt.PyJWTError):
        decode_access_token(token)


def test_token_of_another_issuer_is_refused():
    token = jwt.encode(claims(iss="someone"), signing_key(), algorithm="ES256")
    with pytest.raises(jwt.InvalidIssuerError):
        decode_access_token(token)


def test_jwks_holds_one_p256_key_named_by_its_thumbprint():
    keys = jwks()["keys"]
    assert len(keys) == 1
    entry = keys[0]
    assert entry["kty"] == "EC"
    assert entry["crv"] == "P-256"
    assert entry["alg"] == "ES256"
    assert entry["use"] == "sig"
    assert entry["kid"] == key_id(signing_key())


def test_signing_key_is_cached():
    assert signing_key() is signing_key()


def test_signing_key_follows_the_secret_after_the_cache_is_cleared(monkeypatch):
    first = key_id(signing_key())
    monkeypatch.setattr(settings, "secret_key", "another")
    signing_key.cache_clear()
    assert key_id(signing_key()) != first


def test_signing_key_without_a_secret_fails(monkeypatch):
    monkeypatch.setattr(settings, "secret_key", "")
    signing_key.cache_clear()
    with pytest.raises(RuntimeError):
        signing_key()


def test_signing_key_refuses_a_key_of_another_curve(monkeypatch):
    from cryptography.hazmat.primitives import serialization

    other = ec.generate_private_key(ec.SECP384R1())
    pem = other.private_bytes(
        serialization.Encoding.PEM, serialization.PrivateFormat.PKCS8, serialization.NoEncryption()
    ).decode()
    monkeypatch.setattr(settings, "access_token_key", pem)
    signing_key.cache_clear()
    with pytest.raises(ValueError):
        signing_key()


def test_signing_key_loads_a_configured_p256_pem(monkeypatch):
    from cryptography.hazmat.primitives import serialization

    own = ec.generate_private_key(ec.SECP256R1())
    pem = own.private_bytes(
        serialization.Encoding.PEM, serialization.PrivateFormat.PKCS8, serialization.NoEncryption()
    ).decode()
    monkeypatch.setattr(settings, "access_token_key", pem)
    signing_key.cache_clear()
    assert key_id(signing_key()) == key_id(own)
    assert tokens.ACCESS_ALGORITHM == "ES256"
