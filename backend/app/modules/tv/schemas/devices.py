from datetime import datetime
from uuid import UUID

from pydantic import BaseModel

__all__ = ["TvDeviceList", "TvDeviceRead"]


class TvDeviceRead(BaseModel):
    uuid: UUID
    name: str
    created_at: datetime
    last_seen_at: datetime | None


class TvDeviceList(BaseModel):
    items: list[TvDeviceRead]
