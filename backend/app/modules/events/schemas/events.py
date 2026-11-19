from datetime import datetime
from uuid import UUID

from pydantic import BaseModel

from app.modules.events.enums import EventKind

__all__ = ["EventList", "EventRead", "event_read"]


class EventRead(BaseModel):
    uuid: UUID
    camera_uuid: UUID
    camera_name: str | None
    kind: EventKind
    source_topic: str
    started_at: datetime
    ended_at: datetime | None
    ongoing: bool
    duration_seconds: float
    camera_time: datetime | None
    has_snapshot: bool
    has_thumbnail: bool
    details: dict
    created_at: datetime
    updated_at: datetime


class EventList(BaseModel):
    items: list[EventRead]
    total: int
    page: int
    page_size: int


def event_read(event, camera_name: str | None, until: datetime) -> EventRead:
    end = event.ended_at or until
    return EventRead(
        uuid=event.uuid,
        camera_uuid=event.camera_uuid,
        camera_name=camera_name,
        kind=EventKind(event.kind),
        source_topic=event.source_topic,
        started_at=event.started_at,
        ended_at=event.ended_at,
        ongoing=event.ended_at is None,
        duration_seconds=max(0.0, (end - event.started_at).total_seconds()),
        camera_time=event.camera_time,
        has_snapshot=bool(event.snapshot_path),
        has_thumbnail=bool(event.thumbnail_path),
        details=event.details or {},
        created_at=event.created_at,
        updated_at=event.updated_at,
    )
