"""Schemas of analytics views."""

from uuid import UUID

from pydantic import BaseModel, Field

from app.modules.analytics.enums import Profile
from app.modules.analytics.schemas.rules import LineRead, ZoneRead

__all__ = ["ViewList", "ViewRead", "ViewUpdate"]


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
        moving: Whether the lens moves.
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
    moving: bool
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
        moving: Whether the lens moves.
    """

    name: str | None = Field(None, min_length=1, max_length=100)
    profile: Profile | None = None
    enabled: bool | None = None
    fps: float | None = Field(None, ge=1.0, le=15.0)
    tamper: bool | None = None
    moving: bool | None = None
