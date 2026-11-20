"""Database model of a push target."""

from datetime import datetime

from sqlalchemy import BigInteger, Boolean, DateTime, ForeignKey, Integer, String, Text, UniqueConstraint, true
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel

__all__ = ["PushTarget"]


class PushTarget(BaseModel):
    """Where a device session receives push notifications.

    Attributes:
        session_id: Device session the target belongs to; ending the session removes it.
        user_id: User of that session.
        provider: fcm or ntfy.
        token: FCM registration token, or the ntfy topic URL.
        enabled: Whether notifications are sent to it.
        failures: Consecutive failed deliveries.
        last_success_at: When a delivery last succeeded.
        last_error: Reason of the last failure.
    """

    __tablename__ = "push_targets"
    __table_args__ = (UniqueConstraint("session_id", "provider", "token"),)

    session_id: Mapped[int] = mapped_column(
        BigInteger, ForeignKey("auth_sessions.id", ondelete="CASCADE"), nullable=False, index=True
    )
    user_id: Mapped[int] = mapped_column(
        BigInteger, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    provider: Mapped[str] = mapped_column(String(10), nullable=False)
    token: Mapped[str] = mapped_column(Text, nullable=False)
    enabled: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True, server_default=true())
    failures: Mapped[int] = mapped_column(Integer, nullable=False, default=0, server_default="0")
    last_success_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    last_error: Mapped[str | None] = mapped_column(String(200), nullable=True)
