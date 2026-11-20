"""Database model of an organisation."""

from datetime import datetime

from sqlalchemy import BigInteger, Boolean, DateTime, ForeignKey, String, false, text
from sqlalchemy.dialects.postgresql import JSONB
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
        plan_id: Plan of the organisation; None is the default plan.
        plan_overrides: Limits and features that differ from the plan for this organisation, as
            {"limits": {...}, "features": {"name": true or false}}.
        suspended_at: When a platform admin suspended the organisation; its members cannot use it meanwhile.
        suspended_reason: Why it was suspended.
    """

    __tablename__ = "organisations"

    name: Mapped[str] = mapped_column(String(100), nullable=False)
    faces_enabled: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False, server_default=false())
    faces_consent_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    faces_consent_by_id: Mapped[int | None] = mapped_column(BigInteger, ForeignKey("users.id"), nullable=True)
    faces_consent_version: Mapped[str | None] = mapped_column(String(20), nullable=True)

    plan_id: Mapped[int | None] = mapped_column(BigInteger, ForeignKey("plans.id"), nullable=True, index=True)
    plan_overrides: Mapped[dict] = mapped_column(
        JSONB, nullable=False, default=dict, server_default=text("'{}'::jsonb")
    )

    suspended_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    suspended_reason: Mapped[str | None] = mapped_column(String(200), nullable=True)
