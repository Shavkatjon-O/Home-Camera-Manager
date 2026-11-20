"""Analytics area: a place bounded by counting lines, whose occupancy is crossings in minus crossings out."""

from datetime import datetime

from sqlalchemy import DateTime, Integer, String
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel
from app.models.ownership import SiteOwned

__all__ = ["AnalyticsArea"]


class AnalyticsArea(SiteOwned, BaseModel):
    """An area and the lines that bound it.

    Attributes:
        name: Display name.
        lines: Bounding lines as objects with line_uuid and entering, the crossing direction that enters the area.
        labels: Labels counted, empty for every label.
        reset_at: Local time of day, as HH:MM, at which occupancy restarts from zero, or None for never.
        since: When the occupancy was last set by hand, or the area created.
        base: Occupancy set by hand at that time.
    """

    __tablename__ = "analytics_areas"

    name: Mapped[str] = mapped_column(String(60), nullable=False)
    lines: Mapped[list] = mapped_column(JSONB, nullable=False, default=list)
    labels: Mapped[list] = mapped_column(JSONB, nullable=False, default=list)
    reset_at: Mapped[str | None] = mapped_column(String(5), nullable=True)
    since: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    base: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
