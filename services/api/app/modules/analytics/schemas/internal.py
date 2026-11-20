"""Schemas of the internal endpoints the analytics service calls."""

from uuid import UUID

from pydantic import BaseModel, Field

from app.modules.events.enums import EventKind

__all__ = ["AnalyticsEventIn", "ObservationReport"]

MEDIA = r"^analytics/\d{4}/\d{2}/\d{2}/[0-9a-f-]{36}(\.thumb)?\.(jpg|mp4)$"


class AnalyticsEventIn(BaseModel):
    """An event change sent by the analytics service.

    Attributes:
        id: Event id, shared by every change of the same event.
        action: open, update, close, instant or media.
        camera: Camera id.
        view: View id.
        view_name: View name.
        profile: Profile of the view.
        kind: Event kind.
        label: Object label or tamper condition.
        started_at: Start, seconds since the epoch.
        ended_at: End, None while open.
        zone: Zone id, if any.
        zone_name: Zone name, if any.
        line: Line id, if any.
        line_name: Line name, if any.
        direction: in or out for crossings.
        objects: Object ids involved.
        boxes: Boxes of the objects when they joined.
        count: Largest number of objects at once.
        alert: Whether the event raises an alert.
        plates: Number plate candidates of a vehicle event, strongest first, None when not read.
        plate_status: read, infrared, no_plate, too_small, unreadable or pending, None when not read.
        snapshot_path: Snapshot relative to the events folder.
        thumbnail_path: Thumbnail relative to the events folder.
        clip_path: Clip relative to the events folder.
    """

    id: UUID
    action: str = Field(max_length=10)
    camera: UUID
    view: UUID
    view_name: str = Field("", max_length=100)
    profile: str = Field("", max_length=20)
    kind: EventKind
    label: str = Field(max_length=20)
    started_at: float
    ended_at: float | None = None
    zone: str | None = Field(None, max_length=64)
    zone_name: str | None = Field(None, max_length=60)
    line: str | None = Field(None, max_length=64)
    line_name: str | None = Field(None, max_length=60)
    direction: str | None = Field(None, max_length=5)
    objects: list[int] = Field(default_factory=list, max_length=200)
    boxes: list[dict] = Field(default_factory=list, max_length=20)
    count: int = 0
    alert: bool = False
    plates: list[dict] | None = Field(None, max_length=5)
    plate_status: str | None = Field(None, max_length=20)
    snapshot_path: str | None = Field(None, pattern=MEDIA)
    thumbnail_path: str | None = Field(None, pattern=MEDIA)
    clip_path: str | None = Field(None, pattern=MEDIA)


class ObservationReport(BaseModel):
    """Periodic report of the analytics service.

    Attributes:
        at: Time of the report, seconds since the epoch.
        pipeline: Pipeline state.
        gpu: GPU reading.
        views: Status of every view.
    """

    at: float
    pipeline: dict | None = None
    gpu: dict = Field(default_factory=dict)
    views: list[dict] = Field(default_factory=list)
