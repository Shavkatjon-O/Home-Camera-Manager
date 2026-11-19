"""Analytics settings: the single row holding the global arm mode."""

from sqlalchemy import String
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel

__all__ = ["AnalyticsSettings"]


class AnalyticsSettings(BaseModel):
    """Global analytics settings, stored in one row.

    Attributes:
        arm_mode: disarmed, home, away or schedule.
    """

    __tablename__ = "analytics_settings"

    arm_mode: Mapped[str] = mapped_column(String(20), nullable=False, default="disarmed")
