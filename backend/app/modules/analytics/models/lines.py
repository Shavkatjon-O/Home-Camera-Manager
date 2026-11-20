"""Analytics line: a counting line on a view and the crossing rule evaluated on it."""

from sqlalchemy import BigInteger, Boolean, ForeignKey, Integer, String
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel

__all__ = ["AnalyticsLine"]


class AnalyticsLine(BaseModel):
    """A line of an analytics view.

    Attributes:
        view_id: View the line is drawn on.
        position: Order of the line in the view.
        name: Display name.
        points: Start and end point in normalized view coordinates.
        labels: Labels and label groups the line counts, empty for any label.
        direction: in, out or both, the crossings that produce events.
        schedule: Weekly windows in which the line produces events, empty for always.
        alert: Alert policy with mode, schedule and labels.
        enabled: Whether the line produces events.
        reference: Snapshot the line was drawn on, relative to the events folder.
        animals: include, record or exclude, what dogs, cats and birds crossing the line do.
    """

    __tablename__ = "analytics_lines"

    view_id: Mapped[int] = mapped_column(
        BigInteger, ForeignKey("analytics_views.id", ondelete="CASCADE"), nullable=False, index=True
    )
    position: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    name: Mapped[str] = mapped_column(String(60), nullable=False)
    points: Mapped[list] = mapped_column(JSONB, nullable=False, default=list)
    labels: Mapped[list] = mapped_column(JSONB, nullable=False, default=list)
    direction: Mapped[str] = mapped_column(String(5), nullable=False, default="both")
    schedule: Mapped[list] = mapped_column(JSONB, nullable=False, default=list)
    alert: Mapped[dict] = mapped_column(JSONB, nullable=False, default=dict)
    enabled: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
    reference: Mapped[str | None] = mapped_column(String(255), nullable=True)

    animals: Mapped[str] = mapped_column(String(10), nullable=False, default="record", server_default="record")
