"""Analytics journey: person tracks on several views linked by appearance into one walk through the house."""

from datetime import datetime

from sqlalchemy import DateTime, Integer
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel
from app.models.ownership import SiteOwned

__all__ = ["AnalyticsJourney"]


class AnalyticsJourney(SiteOwned, BaseModel):
    """A journey and its steps in time order.

    Attributes:
        steps: Objects with view, camera, track, start and end as epoch seconds, and similarity to the step before.
        started_at: Start of the first step.
        ended_at: End of the last step.
        views: Distinct views the journey passed.
    """

    __tablename__ = "analytics_journeys"

    steps: Mapped[list] = mapped_column(JSONB, nullable=False, default=list)
    started_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, index=True)
    ended_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    views: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
