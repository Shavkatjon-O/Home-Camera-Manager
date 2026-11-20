"""Database model of a token sent by email."""

from datetime import datetime

from sqlalchemy import BigInteger, DateTime, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel

__all__ = ["EmailToken"]


class EmailToken(BaseModel):
    """A single-use token mailed to confirm an address or to reset a password.

    Attributes:
        user_id: User the token was sent to.
        purpose: verify or reset.
        token_hash: SHA-256 of the token.
        expires_at: When the token stops working.
        used_at: When it was used.
    """

    __tablename__ = "email_tokens"

    user_id: Mapped[int] = mapped_column(
        BigInteger, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    purpose: Mapped[str] = mapped_column(String(10), nullable=False)
    token_hash: Mapped[str] = mapped_column(String(64), unique=True, nullable=False)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    used_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
