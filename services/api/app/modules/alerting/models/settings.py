"""Analytics settings: the row of each site holding its arm mode."""

from sqlalchemy import String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel
from app.models.ownership import SiteOwned

__all__ = ["AnalyticsSettings"]


class AnalyticsSettings(SiteOwned, BaseModel):
    """Analytics settings of one site, stored in one row per site.

    Attributes:
        arm_mode: disarmed, home, away or schedule.
    """

    __tablename__ = "analytics_settings"
    __table_args__ = (UniqueConstraint("site_id"),)

    arm_mode: Mapped[str] = mapped_column(String(20), nullable=False, default="disarmed")
