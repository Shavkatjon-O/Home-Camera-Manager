from datetime import UTC, datetime
from uuid import uuid4

from app.models import AuthSession
from app.modules.identity.services.tokens import session_read

NOW = datetime(2026, 11, 20, 12, 0, tzinfo=UTC)


def auth_session(id=7):
    return AuthSession(
        id=id,
        uuid=uuid4(),
        name="Pixel",
        platform="android",
        created_at=NOW,
        last_used_at=NOW,
        expires_at=NOW,
    )


def test_session_read_marks_the_current_session():
    assert session_read(auth_session(7), 7).current is True


def test_session_read_does_not_mark_another_session():
    assert session_read(auth_session(7), 8).current is False


def test_session_read_without_a_current_session_marks_none():
    read = session_read(auth_session(7))
    assert read.current is False
    assert read.name == "Pixel"
    assert read.platform == "android"
