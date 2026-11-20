"""Database model of a refresh token."""

from datetime import datetime

from sqlalchemy import BigInteger, DateTime, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel

__all__ = ["RefreshToken"]


class RefreshToken(BaseModel):
    """A refresh token of a session; only the newest unused one of a session may be exchanged.

    Attributes:
        session_id: Session the token belongs to.
        token_hash: SHA-256 of the 32 random bytes of the token; the token itself is never stored.
        expires_at: Idle limit of the token.
        used_at: When the token was exchanged for a new pair, or None while it is the live one.
    """

    __tablename__ = "refresh_tokens"

    session_id: Mapped[int] = mapped_column(
        BigInteger, ForeignKey("auth_sessions.id", ondelete="CASCADE"), nullable=False, index=True
    )
    token_hash: Mapped[str] = mapped_column(String(64), unique=True, nullable=False)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    used_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
