"""Database model of an hourly usage rollup."""

from datetime import datetime

from sqlalchemy import BigInteger, DateTime, Float, ForeignKey, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel
from app.models.ownership import OrganisationOwned

__all__ = ["UsageRollup"]


class UsageRollup(OrganisationOwned, BaseModel):
    """How much of one metric an organisation's site used in one hour, for billing later.

    Attributes:
        site_id: Site the usage belongs to, None for usage of the organisation as a whole.
        hour: Start of the hour.
        metric: A UsageMetric value.
        value: Amount: hours for the hour metrics, a count for events and notifications, bytes for clips.
    """

    __tablename__ = "usage_rollups"
    __table_args__ = (
        UniqueConstraint(
            "organisation_id", "site_id", "hour", "metric", name="uq_usage_rollup", postgresql_nulls_not_distinct=True
        ),
    )

    site_id: Mapped[int | None] = mapped_column(
        BigInteger, ForeignKey("sites.id", ondelete="CASCADE"), nullable=True, index=True
    )
    hour: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, index=True)
    metric: Mapped[str] = mapped_column(String(20), nullable=False)
    value: Mapped[float] = mapped_column(Float, nullable=False, default=0.0, server_default="0")
