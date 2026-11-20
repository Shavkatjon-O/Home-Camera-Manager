"""Which vehicle pictures to read for which event, and the plate details each event carries.

A vehicle event on a view with plates enabled is followed while it lasts: every analysed frame offers the boxes of
the event's vehicles, and at most one box per interval becomes a reading job, up to a number of reads per event.
A job waits a few seconds so the recording buffer holds its moment, then the media thread cuts the picture, reads
it and records the read here, which returns the event's updated plate details.
"""

from __future__ import annotations

from dataclasses import dataclass, field

from app.plates.reader import PlateRead, PlateSettings, PlateVotes
from app.rules.model import VEHICLES, Box

FORGET_SECONDS = 600.0


@dataclass(frozen=True)
class WatchSettings:
    """How often vehicles are read.

    Attributes:
        enabled: Whether the view reads plates.
        interval: Seconds between two reads of one event.
        max_reads: Most reads per event.
        delay: Seconds a job waits for the recording buffer.
        min_width: Narrowest vehicle box, as a share of the view width, worth reading.
        reading: Thresholds of the reader.
    """

    enabled: bool = False
    interval: float = 1.0
    max_reads: int = 6
    delay: float = 4.0
    min_width: float = 0.06
    reading: PlateSettings = field(default_factory=PlateSettings)

    @classmethod
    def from_view(cls, raw: dict | None) -> WatchSettings:
        """Read the plate settings of a view from its configuration key plates.

        Args:
            raw: The view's configuration.

        Returns:
            The settings, disabled when the view has none.
        """
        data = (raw or {}).get("plates") or {}
        return cls(
            enabled=bool(data.get("enabled", False)),
            interval=float(data.get("interval", 1.0)),
            max_reads=int(data.get("max_reads", 6)),
            delay=float(data.get("delay", 4.0)),
            min_width=float(data.get("min_width", 0.06)),
            reading=PlateSettings.from_dict(data),
        )


@dataclass(frozen=True)
class PlateJob:
    """A vehicle picture to read.

    Attributes:
        event: Event id.
        view: View id.
        at: Moment of the picture.
        box: Vehicle box in normalized view coordinates.
        due: Time from which the buffer holds the moment.
    """

    event: str
    view: str
    at: float
    box: Box
    due: float


@dataclass
class Followed:
    """A vehicle event being read.

    Attributes:
        event: Event id.
        view: View id.
        objects: Object ids of the event's vehicles.
        started_at: Event start.
        ended_at: Event end, None while open.
        last_job: Moment of the latest job.
        jobs: Jobs created.
        votes: The reads so far.
    """

    event: str
    view: str
    objects: set[int]
    started_at: float
    ended_at: float | None = None
    last_job: float = float("-inf")
    jobs: int = 0
    votes: PlateVotes = field(default_factory=PlateVotes)


class PlateWatch:
    """Plans plate reads for the vehicle events of the views that read plates.

    Attributes:
        settings: Plate settings per view id.
        followed: Followed events by event id.
        queue: Jobs waiting for the buffer.
    """

    def __init__(self):
        """Create an empty watch."""
        self.settings: dict[str, WatchSettings] = {}
        self.followed: dict[str, Followed] = {}
        self.queue: list[PlateJob] = []

    def configure(self, view: str, raw: dict | None) -> None:
        """Set a view's plate settings from its configuration.

        Args:
            view: View id.
            raw: The view's configuration.
        """
        self.settings[view] = WatchSettings.from_view(raw)

    def follow(self, event: dict) -> bool:
        """Start or update following a vehicle event.

        Args:
            event: The event as Event.as_dict returns it.

        Returns:
            True when the event is followed.
        """
        settings = self.settings.get(event["view"])
        if settings is None or not settings.enabled or event.get("label") not in VEHICLES:
            return False
        followed = self.followed.get(event["id"])
        if followed is None:
            followed = Followed(event["id"], event["view"], set(), event["started_at"])
            self.followed[event["id"]] = followed
        followed.objects |= {int(item) for item in event.get("objects") or []}
        followed.ended_at = event.get("ended_at")
        return True

    def observe(self, view: str, at: float, objects: list[tuple[int, Box]]) -> None:
        """Offer the vehicle boxes of an analysed frame.

        Args:
            view: View id.
            at: Frame time.
            objects: Object id and box of each vehicle in the frame.
        """
        settings = self.settings.get(view)
        if settings is None or not settings.enabled:
            return
        for followed in self.followed.values():
            if followed.view != view or followed.jobs >= settings.max_reads:
                continue
            if followed.ended_at is not None and at > followed.ended_at:
                continue
            if at - followed.last_job < settings.interval:
                continue
            boxes = [box for object_id, box in objects if object_id in followed.objects]
            boxes = [box for box in boxes if box.right - box.left >= settings.min_width]
            if not boxes:
                continue
            box = max(boxes, key=lambda item: (item.right - item.left) * (item.bottom - item.top))
            followed.last_job = at
            followed.jobs += 1
            self.queue.append(PlateJob(followed.event, view, at, box, at + settings.delay))

    def due(self, now: float) -> list[PlateJob]:
        """Take the jobs whose moment the buffer now holds.

        Args:
            now: Current time.

        Returns:
            The jobs, oldest first.
        """
        ready = [job for job in self.queue if job.due <= now]
        self.queue = [job for job in self.queue if job.due > now]
        horizon = now - FORGET_SECONDS
        for event_id in [key for key, item in self.followed.items() if (item.ended_at or now) < horizon]:
            del self.followed[event_id]
        return sorted(ready, key=lambda job: job.at)

    def reading(self, view: str) -> PlateSettings:
        """Return the reader thresholds of a view.

        Args:
            view: View id.

        Returns:
            The thresholds, the defaults for an unknown view.
        """
        settings = self.settings.get(view)
        return settings.reading if settings else PlateSettings()

    def record(self, job: PlateJob, read: PlateRead) -> dict | None:
        """Count a read and return the event's plate details.

        Args:
            job: The job that was read.
            read: The read.

        Returns:
            Details with plates, the candidates strongest first, and plate_status; None for a forgotten event.
        """
        followed = self.followed.get(job.event)
        if followed is None:
            return None
        followed.votes.add(read)
        return {"plates": followed.votes.candidates(), "plate_status": followed.votes.status}
