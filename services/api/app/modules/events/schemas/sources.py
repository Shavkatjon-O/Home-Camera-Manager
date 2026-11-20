"""Response schemas of the camera event sources."""

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel

from app.modules.events.enums import EventKind, SourceMode, SourceState

__all__ = ["EventSourceList", "EventSourceRead"]


class EventSourceRead(BaseModel):
    """State of one camera's event subscription.

    Attributes:
        camera_uuid: The camera.
        camera_name: Its name.
        state: Connection state.
        mode: How notifications arrive.
        endpoint: Event service address, if any.
        topics: Topics the camera offers.
        kinds: Event kinds those topics map to.
        conditions: Latest value of the camera's condition topics.
        connected_at: When the subscription last connected.
        last_message_at: When the last notification arrived.
        error: Latest problem, if any.
    """

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
    """Every camera's event subscription.

    Attributes:
        items: The subscriptions.
    """

    items: list[EventSourceRead]
