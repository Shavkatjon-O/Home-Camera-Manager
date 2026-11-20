"""Schemas of analytics views."""

from uuid import UUID

from pydantic import BaseModel, Field

from app.modules.analytics.enums import Profile, ViewStream
from app.modules.analytics.schemas.rules import LineRead, ZoneRead

__all__ = ["LiveObject", "LiveObjects", "ViewList", "ViewRead", "ViewUpdate"]


class ViewRead(BaseModel):
    """An analytics view with its zones, lines and live status.

    Attributes:
        uuid: View id.
        camera_uuid: Camera of the view.
        camera_name: Name of that camera.
        lens: 0 for the whole frame, otherwise the lens band from 1 at the top.
        lenses: Lens bands of the camera.
        name: Display name.
        profile: Pipeline profile.
        enabled: Whether the view is analysed.
        fps: Analysis rate.
        tamper: Tamper watch on or off, None for the profile default.
        faces: Face recognition on or off, None for the profile default.
        moving: Whether the lens moves.
        appearance: Whether people get appearance vectors for journeys across cameras.
        falls: Whether the view watches for falls.
        plates: Whether vehicle events read number plates.
        follow: Whether a moving lens follows a person.
        stream: Camera stream the view is analysed on.
        zones: The zones.
        lines: The lines.
        status: Latest status from the analytics service, None before its first report.
    """

    uuid: UUID
    camera_uuid: UUID
    camera_name: str
    lens: int
    lenses: int
    name: str
    profile: Profile
    enabled: bool
    fps: float
    tamper: bool | None
    faces: bool | None
    moving: bool
    appearance: bool
    falls: bool
    plates: bool
    follow: bool
    stream: ViewStream
    zones: list[ZoneRead]
    lines: list[LineRead]
    status: dict | None


class ViewList(BaseModel):
    """A list of views.

    Attributes:
        items: The views in camera and lens order.
    """

    items: list[ViewRead]


class ViewUpdate(BaseModel):
    """Changes to a view; fields left out stay as they are.

    Attributes:
        name: Display name.
        profile: Pipeline profile.
        enabled: Whether the view is analysed.
        fps: Analysis rate from 1 to 15.
        tamper: Tamper watch on or off, None for the profile default.
        faces: Face recognition on or off, None for the profile default.
        moving: Whether the lens moves.
        appearance: Whether people get appearance vectors for journeys across cameras.
        falls: Whether the view watches for falls.
        plates: Whether vehicle events read number plates.
        follow: Whether a moving lens follows a person.
        stream: Camera stream to analyse; the sub stream needs a camera with one.
    """

    name: str | None = Field(None, min_length=1, max_length=100)
    profile: Profile | None = None
    enabled: bool | None = None
    fps: float | None = Field(None, ge=1.0, le=15.0)
    tamper: bool | None = None
    faces: bool | None = None
    moving: bool | None = None
    appearance: bool | None = None
    falls: bool | None = None
    plates: bool | None = None
    follow: bool | None = None
    stream: ViewStream | None = None


class LiveObject(BaseModel):
    """An object the analytics service tracks in a view's latest frame.

    Attributes:
        track: Tracker id.
        label: Object label.
        confidence: Detector confidence.
        box: Left, top, right and bottom in normalized view coordinates.
    """

    track: int
    label: str
    confidence: float
    box: list[float]


class LiveObjects(BaseModel):
    """The tracked objects of a view's latest frame.

    Attributes:
        view: View id.
        at: Time of the frame as epoch seconds, None before the first frame.
        objects: The objects.
    """

    view: str
    at: float | None
    objects: list[LiveObject]
