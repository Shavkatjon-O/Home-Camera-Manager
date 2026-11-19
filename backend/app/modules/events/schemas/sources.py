from datetime import datetime
from uuid import UUID

from pydantic import BaseModel

from app.modules.events.enums import EventKind, SourceMode, SourceState

__all__ = ["EventSourceList", "EventSourceRead"]


class EventSourceRead(BaseModel):
    camera_uuid: UUID
    camera_name: str
    state: SourceState
    mode: SourceMode
    endpoint: str | None
    topics: list[str]
    kinds: list[EventKind]
    conditions: dict[str, bool]
    connected_at: datetime | None
    last_message_at: datetime | None
    error: str | None


class EventSourceList(BaseModel):
    items: list[EventSourceRead]
