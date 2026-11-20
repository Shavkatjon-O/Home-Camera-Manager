"""Schemas of the event search: its filters, its results and their pages."""

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field

from app.modules.people.schemas import FaceRead

__all__ = ["EventFilters", "ResultPage", "SearchResult"]


class EventFilters(BaseModel):
    """Filters of an event search; every filter that is set must match.

    Attributes:
        start: Earliest start time, inclusive, if any.
        end: Latest start time, exclusive, if any.
        cameras: Cameras to keep, any of them.
        kinds: Event kinds to keep, any of them.
        views: Camera views to keep, any of them.
        labels: Object labels to keep, any of them.
        zones: Zones to keep, any of them.
        lines: Lines to keep, any of them.
        person: Person whose face events to keep, if any.
        cluster: Unknown cluster whose face events to keep, if any.
        alert: Whether to keep alerting events only.
    """

    start: datetime | None = None
    end: datetime | None = None
    cameras: list[UUID] = Field(default_factory=list)
    kinds: list[str] = Field(default_factory=list)
    views: list[str] = Field(default_factory=list)
    labels: list[str] = Field(default_factory=list)
    zones: list[str] = Field(default_factory=list)
    lines: list[str] = Field(default_factory=list)
    person: UUID | None = None
    cluster: UUID | None = None
    alert: bool = False


class SearchResult(BaseModel):
    """Event as the events list returns it, with the face it shows.

    The kind is plain text so face and analytics kinds pass through as they are stored.

    Attributes:
        uuid: Public id of the event.
        camera_uuid: Camera of the event.
        camera_name: Name of the camera, if it still exists.
        kind: Kind of the event.
        source: camera or analytics.
        source_topic: Topic the event came from.
        label: Object label of an analytics event, if any.
        alert: Whether the event raised an alert.
        view_uuid: Analytics view of the event, if any.
        started_at: When the event started.
        ended_at: When the event ended, if it has.
        ongoing: Whether the event is still open.
        duration_seconds: Duration so far.
        camera_time: The camera's own time of the event, if known.
        has_snapshot: Whether a snapshot is stored.
        has_thumbnail: Whether a thumbnail is stored.
        has_clip: Whether a clip is stored.
        details: Further facts about the event.
        created_at: When the event was stored.
        updated_at: When the event last changed.
        face: Who a face event shows, or None for other events.
    """

    uuid: UUID
    camera_uuid: UUID
    camera_name: str | None
    kind: str
    source: str = "camera"
    source_topic: str
    label: str | None = None
    alert: bool = False
    view_uuid: UUID | None = None
    started_at: datetime
    ended_at: datetime | None
    ongoing: bool
    duration_seconds: float
    camera_time: datetime | None
    has_snapshot: bool
    has_thumbnail: bool
    has_clip: bool = False
    details: dict
    created_at: datetime
    updated_at: datetime
    face: FaceRead | None


class ResultPage(BaseModel):
    """One page of search results.

    Attributes:
        items: Results on the page, newest first.
        total: Number of results across all pages.
        page: One-based page number.
        page_size: Number of results per page.
    """

    items: list[SearchResult]
    total: int
    page: int
    page_size: int
