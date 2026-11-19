from uuid import UUID

from pydantic import BaseModel

__all__ = ["TvConfig", "TvTile", "TvWall"]


class TvWall(BaseModel):
    url: str
    cols: int
    rows: int


class TvTile(BaseModel):
    index: int
    label: str
    camera_uuid: UUID
    camera_name: str
    lens: int | None
    ptz: bool
    url: str


class TvConfig(BaseModel):
    wall: TvWall
    tiles: list[TvTile]
