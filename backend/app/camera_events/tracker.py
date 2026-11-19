from dataclasses import dataclass, field
from datetime import datetime, timedelta
from uuid import UUID, uuid4

MERGE_WINDOW = timedelta(seconds=5)
OPEN_CAP = timedelta(minutes=10)


@dataclass
class OpenEvent:
    camera_uuid: UUID
    kind: str
    topic: str
    started_at: datetime
    uuid: UUID = field(default_factory=uuid4)
    topics: set[str] = field(default_factory=set)
    seen: set[str] = field(default_factory=set)
    stop_at: datetime | None = None


@dataclass(frozen=True)
class Closing:
    event: OpenEvent
    ended_at: datetime
    capped: bool


class EventTracker:
    def __init__(self, merge: timedelta = MERGE_WINDOW, cap: timedelta = OPEN_CAP):
        self.merge = merge
        self.cap = cap
        self.open: dict[tuple[UUID, str], OpenEvent] = {}

    def get(self, camera_uuid: UUID, kind: str) -> OpenEvent | None:
        return self.open.get((camera_uuid, kind))

    def start(self, camera_uuid: UUID, kind: str, topic: str, now: datetime) -> OpenEvent | None:
        event = self.open.get((camera_uuid, kind))
        if event is not None:
            event.topics.add(topic)
            event.seen.add(topic)
            event.stop_at = None
            return None
        event = OpenEvent(camera_uuid=camera_uuid, kind=kind, topic=topic, started_at=now, topics={topic}, seen={topic})
        self.open[(camera_uuid, kind)] = event
        return event

    def keep(self, camera_uuid: UUID, kind: str, topic: str) -> bool:
        event = self.open.get((camera_uuid, kind))
        if event is None:
            return False
        event.topics.add(topic)
        event.seen.add(topic)
        event.stop_at = None
        return True

    def stop(self, camera_uuid: UUID, topic: str, now: datetime) -> None:
        for event in self.open.values():
            if event.camera_uuid != camera_uuid or topic not in event.topics:
                continue
            event.topics.discard(topic)
            if not event.topics and event.stop_at is None:
                event.stop_at = now

    def due(self, now: datetime) -> list[Closing]:
        closing = []
        for key, event in list(self.open.items()):
            if event.stop_at is not None and now - event.stop_at >= self.merge:
                closing.append(Closing(event=event, ended_at=event.stop_at, capped=False))
            elif now - event.started_at >= self.cap:
                closing.append(Closing(event=event, ended_at=event.started_at + self.cap, capped=True))
            else:
                continue
            del self.open[key]
        return closing

    def drop(self, camera_uuid: UUID, now: datetime) -> list[Closing]:
        closing = []
        for key, event in list(self.open.items()):
            if event.camera_uuid != camera_uuid:
                continue
            ended = event.stop_at or min(now, event.started_at + self.cap)
            closing.append(Closing(event=event, ended_at=ended, capped=False))
            del self.open[key]
        return closing

    def open_events(self, camera_uuid: UUID | None = None) -> list[OpenEvent]:
        return [event for event in self.open.values() if camera_uuid is None or event.camera_uuid == camera_uuid]
