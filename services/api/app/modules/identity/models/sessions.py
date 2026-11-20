"""Database model of a signed-in device session."""

from datetime import datetime

from sqlalchemy import BigInteger, DateTime, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel

__all__ = ["AuthSession"]


class AuthSession(BaseModel):
    """One sign-in of an app on a device: the family of refresh tokens issued to it.

    Attributes:
        user_id: User who signed in.
        name: Device name the app sent, such as the phone model.
        platform: Platform the app runs on, such as android or ios.
        last_used_at: When a token of the session was last refreshed.
        expires_at: Absolute end of the session, whatever its refreshes.
        revoked_at: When the session was ended, or None while it is live.
        revoke_reason: Why it ended: signed_out, revoked, reuse, password_changed or account_deleted.
    """

    __tablename__ = "auth_sessions"

    user_id: Mapped[int] = mapped_column(
        BigInteger, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    platform: Mapped[str] = mapped_column(String(20), nullable=False)
    last_used_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    revoked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    revoke_reason: Mapped[str | None] = mapped_column(String(20), nullable=True)
