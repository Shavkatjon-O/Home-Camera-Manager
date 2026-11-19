from datetime import datetime
from uuid import UUID

from sqlalchemy import DateTime, Index, String, Uuid
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel

__all__ = ["Event"]


class Event(BaseModel):
    __tablename__ = "events"
    __table_args__ = (Index("ix_events_camera_uuid_started_at", "camera_uuid", "started_at"),)

    camera_uuid: Mapped[UUID] = mapped_column(Uuid(as_uuid=True), nullable=False)
    kind: Mapped[str] = mapped_column(String(20), nullable=False)
    source_topic: Mapped[str] = mapped_column(String(255), nullable=False)

    started_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, index=True)
    ended_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    camera_time: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)

    snapshot_path: Mapped[str | None] = mapped_column(String(255), nullable=True)
    thumbnail_path: Mapped[str | None] = mapped_column(String(255), nullable=True)

    details: Mapped[dict] = mapped_column(JSONB, nullable=False, default=dict)
