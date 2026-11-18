from uuid import uuid4

import jwt
import pytest

from app.core import security
from app.core.config import settings


@pytest.fixture
def secret(monkeypatch):
    monkeypatch.setattr(settings, "secret_key", "test-secret")
    security.session_key.cache_clear()
    security.fernet.cache_clear()
    yield
    security.session_key.cache_clear()
    security.fernet.cache_clear()


def test_session_token_round_trip(secret):
    user_uuid = uuid4()
    token = security.create_session_token(user_uuid)
    assert security.decode_session_token(token) == user_uuid


def test_session_token_with_another_key_is_rejected(secret):
    token = jwt.encode({"sub": str(uuid4())}, "another-key-that-is-long-enough-for-hs256", algorithm="HS256")
    with pytest.raises(jwt.PyJWTError):
        security.decode_session_token(token)


def test_camera_passwords_are_encrypted(secret):
    stored = security.encrypt_secret("p@ss:word")
    assert "p@ss" not in stored
    assert security.decrypt_secret(stored) == "p@ss:word"
    assert security.decrypt_secret("not-a-fernet-token") is None
    assert security.decrypt_secret(None) is None


def test_password_hashes_verify():
    stored = security.hash_password("example-password")
    assert security.verify_password(stored, "example-password")
    assert not security.verify_password(stored, "example-password5")
    assert not security.verify_password(stored, "x" * 100)


def test_missing_secret_key_is_refused(monkeypatch):
    monkeypatch.setattr(settings, "secret_key", "")
    with pytest.raises(RuntimeError):
        security.require_secret_key()
