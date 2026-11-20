"""Analytics count: line crossings of one minute, as one boot of the analytics service counted them."""

from datetime import datetime
from uuid import UUID

from sqlalchemy import DateTime, Integer, String, UniqueConstraint, Uuid
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel

__all__ = ["AnalyticsCount"]


class AnalyticsCount(BaseModel):
    """Crossings of a line in one minute, direction and label, counted by one boot of the analytics service.

    The analytics service reports the absolute total of each minute it counted, so a row is replaced rather than
    added to, and the totals of several boots add up.

    Attributes:
        boot: Identifier of the analytics service run that counted.
        view_uuid: View the line is drawn on.
        line_uuid: The line.
        start: Start of the minute.
        direction: in or out.
        label: Object label.
        count: Crossings.
    """

    __tablename__ = "analytics_counts"
    __table_args__ = (UniqueConstraint("boot", "line_uuid", "start", "direction", "label"),)

    boot: Mapped[str] = mapped_column(String(36), nullable=False)
    view_uuid: Mapped[UUID] = mapped_column(Uuid(as_uuid=True), nullable=False)
    line_uuid: Mapped[UUID] = mapped_column(Uuid(as_uuid=True), nullable=False, index=True)
    start: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, index=True)
    direction: Mapped[str] = mapped_column(String(3), nullable=False)
    label: Mapped[str] = mapped_column(String(20), nullable=False)
    count: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
