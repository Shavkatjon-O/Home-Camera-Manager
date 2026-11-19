"""Model of a paired TV device."""

from datetime import datetime

from sqlalchemy import Boolean, DateTime, String
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel

__all__ = ["TvDevice"]


class TvDevice(BaseModel):
    """TV that has been paired and authenticates with its own device token.

    Attributes:
        name: Name the TV was paired under.
        token_hash: Hash of the device token; the token itself is never stored.
        last_seen_at: Time of the last authenticated request, if any.
        revoked: Whether the device has been revoked.
    """

    __tablename__ = "tv_devices"

    name: Mapped[str] = mapped_column(String(100), nullable=False)
    token_hash: Mapped[str] = mapped_column(String(128), unique=True, nullable=False)

    last_seen_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    revoked: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
