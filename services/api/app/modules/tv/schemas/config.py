"""Schemas of the configuration a paired TV reads."""

from uuid import UUID

from pydantic import BaseModel

__all__ = ["TvConfig", "TvTile", "TvWall"]


class TvWall(BaseModel):
    """Combined stream that shows every camera in a grid.

    Attributes:
        url: RTSP URL of the wall stream, empty when no camera is shown.
        cols: Number of grid columns.
        rows: Number of grid rows.
    """

    url: str
    cols: int
    rows: int


class TvTile(BaseModel):
    """Single camera view of the wall.

    Attributes:
        index: Position of the tile in the wall.
        label: Text shown for the tile.
        camera_uuid: Public id of the camera.
        camera_name: Name of the camera.
        lens: Zero-based lens number for a multi-lens camera, or None.
        ptz: Whether the camera can pan, tilt and zoom.
        url: RTSP URL of the tile stream.
    """

    index: int
    label: str
    camera_uuid: UUID
    camera_name: str
    lens: int | None
    ptz: bool
    url: str


class TvConfig(BaseModel):
    """Streams a paired TV plays.

    Attributes:
        wall: Combined wall stream.
        tiles: Single camera streams.
    """

    wall: TvWall
    tiles: list[TvTile]
