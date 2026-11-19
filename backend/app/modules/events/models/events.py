"""Event: one thing a camera reported or the analytics service detected."""

from datetime import datetime
from uuid import UUID

from sqlalchemy import Boolean, DateTime, Index, String, Uuid, false
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel

__all__ = ["Event"]


class Event(BaseModel):
    """A camera or analytics event.

    Attributes:
        camera_uuid: Camera the event belongs to.
        kind: Event kind.
        source: camera for ONVIF notifications, analytics for the analytics service.
        source_topic: ONVIF topic, or analytics with the kind for analytics events.
        label: Object label of an analytics event, or the condition of a tamper event.
        alert: Whether the event raises an alert.
        view_uuid: Analytics view the event happened in.
        started_at: When the event started, by this computer's clock.
        ended_at: When it ended, None while it is open.
        camera_time: The camera's own time of the event, if it sent one.
        snapshot_path: Snapshot relative to the events folder.
        thumbnail_path: Thumbnail relative to the events folder.
        clip_path: Clip relative to the events folder.
        details: Raw messages for camera events; zone, line, direction, objects and boxes for analytics events.
    """

    __tablename__ = "events"
    __table_args__ = (Index("ix_events_camera_uuid_started_at", "camera_uuid", "started_at"),)

    camera_uuid: Mapped[UUID] = mapped_column(Uuid(as_uuid=True), nullable=False)
    kind: Mapped[str] = mapped_column(String(20), nullable=False)
    source: Mapped[str] = mapped_column(String(20), nullable=False, default="camera", server_default="camera")
    source_topic: Mapped[str] = mapped_column(String(255), nullable=False)
    label: Mapped[str | None] = mapped_column(String(20), nullable=True)
    alert: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False, server_default=false())
    view_uuid: Mapped[UUID | None] = mapped_column(Uuid(as_uuid=True), nullable=True)

    started_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, index=True)
    ended_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    camera_time: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)

    snapshot_path: Mapped[str | None] = mapped_column(String(255), nullable=True)
    thumbnail_path: Mapped[str | None] = mapped_column(String(255), nullable=True)
    clip_path: Mapped[str | None] = mapped_column(String(255), nullable=True)

    details: Mapped[dict] = mapped_column(JSONB, nullable=False, default=dict)
