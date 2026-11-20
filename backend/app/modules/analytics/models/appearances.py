"""Analytics appearance: the averaged look of one person track, for linking tracks across cameras."""

from datetime import datetime
from uuid import UUID

from sqlalchemy import BigInteger, DateTime, Integer, LargeBinary, UniqueConstraint, Uuid
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel

__all__ = ["AnalyticsAppearance"]


class AnalyticsAppearance(BaseModel):
    """The appearance of one person track on one view.

    Attributes:
        view_uuid: View the track was on.
        camera_uuid: Camera of that view.
        track_id: Tracker id of the track.
        started_at: First sighting.
        ended_at: Last sighting.
        samples: Crops averaged into the appearance.
        embedding: The 512 float32 values of the unit appearance vector as 2048 bytes.
        box: Best person box in normalized view coordinates.
        journey_uuid: Journey the track belongs to, if linked.
    """

    __tablename__ = "analytics_appearances"
    __table_args__ = (UniqueConstraint("view_uuid", "track_id", "started_at"),)

    view_uuid: Mapped[UUID] = mapped_column(Uuid(as_uuid=True), nullable=False, index=True)
    camera_uuid: Mapped[UUID] = mapped_column(Uuid(as_uuid=True), nullable=False)
    track_id: Mapped[int] = mapped_column(BigInteger, nullable=False)
    started_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, index=True)
    ended_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    samples: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    embedding: Mapped[bytes] = mapped_column(LargeBinary(2048), nullable=False)
    box: Mapped[list] = mapped_column(JSONB, nullable=False, default=list)
    journey_uuid: Mapped[UUID | None] = mapped_column(Uuid(as_uuid=True), nullable=True, index=True)
