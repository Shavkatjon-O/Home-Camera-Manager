"""Response schemas of events."""

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel

from app.modules.events.enums import EventKind, EventSource
from app.modules.people.schemas.faces import FaceRead

__all__ = ["EventCounts", "EventList", "EventRead", "event_read"]


class EventRead(BaseModel):
    """An event as the API returns it.

    Attributes:
        uuid: Event id.
        camera_uuid: Camera the event belongs to.
        camera_name: Name of that camera, None when it was removed.
        kind: Event kind.
        source: camera or analytics.
        source_topic: ONVIF topic or analytics kind.
        label: Object label or tamper condition.
        alert: Whether the event raises an alert.
        view_uuid: Analytics view, if any.
        started_at: Start time.
        ended_at: End time, None while open.
        ongoing: True while the event is open.
        duration_seconds: Length so far.
        camera_time: The camera's own time, if any.
        has_snapshot: Whether a snapshot exists.
        has_thumbnail: Whether a thumbnail exists.
        has_clip: Whether a clip exists.
        details: Kind specific details.
        created_at: When the row was inserted.
        updated_at: When the row last changed.
        face: Who a face event shows, None for other events.
    """

    uuid: UUID
    camera_uuid: UUID
    camera_name: str | None
    kind: EventKind
    source: EventSource
    source_topic: str
    label: str | None
    alert: bool
    view_uuid: UUID | None
    started_at: datetime
    ended_at: datetime | None
    ongoing: bool
    duration_seconds: float
    camera_time: datetime | None
    has_snapshot: bool
    has_thumbnail: bool
    has_clip: bool
    details: dict
    created_at: datetime
    updated_at: datetime
    face: FaceRead | None = None


class EventList(BaseModel):
    """One page of events.

    Attributes:
        items: Events on the page, newest first.
        total: Events matching the filters.
        page: Page number from 1.
        page_size: Events per page.
    """

    items: list[EventRead]
    total: int
    page: int
    page_size: int


class EventCounts(BaseModel):
    """Event counts for a set of filters.

    Attributes:
        total: Events matching the filters.
        kinds: Events per kind.
        labels: Events per label.
        alerts: Events that raised an alert.
    """

    total: int
    kinds: dict[str, int]
    labels: dict[str, int]
    alerts: int


def event_read(event, camera_name: str | None, until: datetime, face: FaceRead | None = None) -> EventRead:
    """Build the API form of an event row.

    Args:
        event: The event row.
        camera_name: Name of its camera, None when the camera was removed.
        until: Time used as the end of an open event for its duration.
        face: Who a face event shows, if it is one.

    Returns:
        The event as the API returns it.
    """
    end = event.ended_at or until
    return EventRead(
        uuid=event.uuid,
        camera_uuid=event.camera_uuid,
        camera_name=camera_name,
        kind=EventKind(event.kind),
        source=EventSource(event.source or EventSource.CAMERA),
        source_topic=event.source_topic,
        label=event.label,
        alert=bool(event.alert),
        view_uuid=event.view_uuid,
        started_at=event.started_at,
        ended_at=event.ended_at,
        ongoing=event.ended_at is None,
        duration_seconds=max(0.0, (end - event.started_at).total_seconds()),
        camera_time=event.camera_time,
        has_snapshot=bool(event.snapshot_path),
        has_thumbnail=bool(event.thumbnail_path),
        has_clip=bool(event.clip_path),
        details=event.details or {},
        created_at=event.created_at,
        updated_at=event.updated_at,
        face=face,
    )
