"""Analytics zone: a polygon on a view and the rules evaluated on it."""

from sqlalchemy import BigInteger, Boolean, Float, ForeignKey, Integer, String, false, text
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel

__all__ = ["AnalyticsZone"]


class AnalyticsZone(BaseModel):
    """A zone of an analytics view.

    Attributes:
        view_id: View the zone is drawn on.
        position: Order of the zone in the view.
        name: Display name.
        polygon: Vertices in normalized view coordinates.
        whole_view: The zone covers the whole picture and stays valid wherever a moving lens points.
        labels: Labels and label groups the zone reacts to, empty for any label.
        min_dwell: Seconds an object stays inside before an intrusion opens.
        loiter_seconds: Seconds inside before a loitering event, 0 turns loitering off.
        crowd_count: Objects inside at once that make a crowd, 0 turns crowding off.
        schedule: Weekly windows in which the zone produces events, empty for always.
        alert: Alert policy with mode, schedule and labels.
        enabled: Whether the zone produces events.
        reference: Snapshot the zone was drawn on, relative to the events folder.
        left_seconds: Seconds a carried object stays still before it counts as left, 0 turns it off.
        taken_seconds: Seconds an object must have been present before its going counts as taken, 0 turns it off.
        object_labels: Labels watched for left and taken, empty for the default carried objects.
        background: Also find unclassed objects by comparing with the empty scene.
        animals: include, record or exclude, what dogs, cats and birds do in the zone.
    """

    __tablename__ = "analytics_zones"

    view_id: Mapped[int] = mapped_column(
        BigInteger, ForeignKey("analytics_views.id", ondelete="CASCADE"), nullable=False, index=True
    )
    position: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    name: Mapped[str] = mapped_column(String(60), nullable=False)
    polygon: Mapped[list] = mapped_column(JSONB, nullable=False, default=list)
    whole_view: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    labels: Mapped[list] = mapped_column(JSONB, nullable=False, default=list)
    min_dwell: Mapped[float] = mapped_column(Float, nullable=False, default=1.0)
    loiter_seconds: Mapped[float] = mapped_column(Float, nullable=False, default=0.0)
    crowd_count: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    schedule: Mapped[list] = mapped_column(JSONB, nullable=False, default=list)
    alert: Mapped[dict] = mapped_column(JSONB, nullable=False, default=dict)
    enabled: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
    reference: Mapped[str | None] = mapped_column(String(255), nullable=True)

    left_seconds: Mapped[float] = mapped_column(Float, nullable=False, default=0.0, server_default=text("0"))
    taken_seconds: Mapped[float] = mapped_column(Float, nullable=False, default=0.0, server_default=text("0"))
    object_labels: Mapped[list] = mapped_column(JSONB, nullable=False, default=list, server_default=text("'[]'"))
    background: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False, server_default=false())
    animals: Mapped[str] = mapped_column(String(10), nullable=False, default="record", server_default="record")
