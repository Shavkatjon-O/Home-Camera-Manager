"""In-memory tracking of camera events that have started and not yet ended."""

from dataclasses import dataclass, field
from datetime import datetime, timedelta
from uuid import UUID, uuid4

MERGE_WINDOW = timedelta(seconds=5)
OPEN_CAP = timedelta(minutes=10)


@dataclass
class OpenEvent:
    """Camera event that has started and has not been closed yet.

    Attributes:
        camera_uuid: Public id of the camera the event belongs to.
        kind: Kind of the event.
        topic: ONVIF topic that opened the event.
        started_at: Time the event started.
        uuid: Public id of the event.
        topics: Topics that are still reporting the event as active.
        seen: Every topic that reported the event while it was open.
        stop_at: Time the last active topic stopped, or None while any topic is still active.
    """

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
    """Open event that is due to be closed.

    Attributes:
        event: The event to close.
        ended_at: Time to record as the end of the event.
        capped: Whether the event ended because it reached the open time cap rather than because it stopped.
    """

    event: OpenEvent
    ended_at: datetime
    capped: bool


class EventTracker:
    """Track open events per camera and kind, merging brief gaps and capping long events.

    An event is closed once every topic that kept it open has stopped for the merge window, or once it has been
    open for the cap.

    Attributes:
        merge: How long all topics must stay stopped before the event is closed.
        cap: Longest time an event may stay open.
        open: Open events by camera and kind.
    """

    def __init__(self, merge: timedelta = MERGE_WINDOW, cap: timedelta = OPEN_CAP):
        """Create an empty tracker.

        Args:
            merge: How long all topics must stay stopped before an event is closed.
            cap: Longest time an event may stay open.
        """
        self.merge = merge
        self.cap = cap
        self.open: dict[tuple[UUID, str], OpenEvent] = {}

    def get(self, camera_uuid: UUID, kind: str) -> OpenEvent | None:
        """Return the open event of a camera and kind.

        Args:
            camera_uuid: Public id of the camera.
            kind: Kind of the event.

        Returns:
            The open event, or None when there is none.
        """
        return self.open.get((camera_uuid, kind))

    def start(self, camera_uuid: UUID, kind: str, topic: str, now: datetime) -> OpenEvent | None:
        """Record an active state for a camera and kind, opening an event if none is open.

        When an event is already open it is extended with the topic and any pending stop is cancelled.

        Args:
            camera_uuid: Public id of the camera.
            kind: Kind of the event.
            topic: ONVIF topic that reported the state.
            now: Current time, used as the start of a new event.

        Returns:
            The new event, or None when an open event was extended instead.
        """
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
        """Extend an open event with a topic without ever opening a new one.

        Args:
            camera_uuid: Public id of the camera.
            kind: Kind of the event.
            topic: ONVIF topic that reported the state.

        Returns:
            True when an event was open and extended, False when there is none.
        """
        event = self.open.get((camera_uuid, kind))
        if event is None:
            return False
        event.topics.add(topic)
        event.seen.add(topic)
        event.stop_at = None
        return True

    def stop(self, camera_uuid: UUID, topic: str, now: datetime) -> None:
        """Record that a topic is no longer active on a camera.

        An event that has no active topic left is marked to stop at the current time.

        Args:
            camera_uuid: Public id of the camera.
            topic: ONVIF topic that reported the end of the state.
            now: Current time, used as the stop time.
        """
        for event in self.open.values():
            if event.camera_uuid != camera_uuid or topic not in event.topics:
                continue
            event.topics.discard(topic)
            if not event.topics and event.stop_at is None:
                event.stop_at = now

    def due(self, now: datetime) -> list[Closing]:
        """Remove and return the events that are due to be closed.

        Args:
            now: Current time.

        Returns:
            The events whose merge window has passed, ended at their stop time, and the events that reached the cap,
            ended at the cap.
        """
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
        """Remove and return every open event of a camera.

        Args:
            camera_uuid: Public id of the camera.
            now: Current time, used as the end of events that have not stopped.

        Returns:
            The removed events, each ended at its stop time or at the current time limited to the cap.
        """
        closing = []
        for key, event in list(self.open.items()):
            if event.camera_uuid != camera_uuid:
                continue
            ended = event.stop_at or min(now, event.started_at + self.cap)
            closing.append(Closing(event=event, ended_at=ended, capped=False))
            del self.open[key]
        return closing

    def open_events(self, camera_uuid: UUID | None = None) -> list[OpenEvent]:
        """List the open events.

        Args:
            camera_uuid: Public id of a camera to limit the list to, or None for every camera.

        Returns:
            The matching open events.
        """
        return [event for event in self.open.values() if camera_uuid is None or event.camera_uuid == camera_uuid]
