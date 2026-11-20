"""Database model of an organisation."""

from datetime import datetime

from sqlalchemy import BigInteger, Boolean, DateTime, ForeignKey, String, false
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel

__all__ = ["Organisation"]


class Organisation(BaseModel):
    """A household, shop or company: the top of the tenancy tree, holding sites, members and the face gallery.

    Attributes:
        name: Display name.
        faces_enabled: Whether face recognition runs for the organisation's cameras.
        faces_consent_at: When a member last accepted the face recognition consent text.
        faces_consent_by_id: User who accepted it.
        faces_consent_version: Version of the consent text that was accepted.
    """

    __tablename__ = "organisations"

    name: Mapped[str] = mapped_column(String(100), nullable=False)
    faces_enabled: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False, server_default=false())
    faces_consent_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    faces_consent_by_id: Mapped[int | None] = mapped_column(BigInteger, ForeignKey("users.id"), nullable=True)
    faces_consent_version: Mapped[str | None] = mapped_column(String(20), nullable=True)
