"""Evaluates zones and lines on tracked objects and produces analytics events.

Zone events are episodes: an intrusion opens when a qualifying object has stayed inside for the zone's dwell and
closes once no qualifying object has been inside for the close delay. Each zone keeps one episode per label, and
vehicles open vehicle episodes instead of intrusions. Loitering and line crossings are instant events, fired at
most once per object and rule within the cooldown. Crowding is an episode that opens while enough objects are
inside at once.
"""

from __future__ import annotations

import uuid
from collections import Counter
from collections.abc import Callable
from dataclasses import dataclass, field
from datetime import datetime, tzinfo

from app.rules.geometry import point_in_polygon, segments_intersect, side_of_line
from app.rules.model import VEHICLES, ArmMode, EventKind, Frame, Line, ViewRules, Zone, label_matches
from app.rules.tracks import Identity, TrackBook

MAX_BOXES = 8
LINE_TOLERANCE = 0.05
FIRED_MEMORY_SECONDS = 3600.0


@dataclass
class Event:
    """An analytics event, open while its episode lasts.

    Attributes:
        id: Unique event id.
        view: View the event happened in.
        kind: Event kind.
        label: Label of the objects involved.
        started_at: Time the event started, seconds since the epoch.
        ended_at: Time it ended, None while open.
        zone: Zone id, for zone events.
        zone_name: Zone name, for zone events.
        line: Line id, for line crossings.
        line_name: Line name, for line crossings.
        direction: in or out, for line crossings.
        objects: Identities involved.
        boxes: Box of each involved object when it joined, up to eight.
        count: Largest number of objects inside at once.
        alert: True when the event raises an alert.
    """

    id: str
    view: str
    kind: EventKind
    label: str
    started_at: float
    ended_at: float | None = None
    zone: str | None = None
    zone_name: str | None = None
    line: str | None = None
    line_name: str | None = None
    direction: str | None = None
    objects: list[int] = field(default_factory=list)
    boxes: list[dict] = field(default_factory=list)
    count: int = 0
    alert: bool = False

    def add(self, identity: Identity, at: float) -> bool:
        """Add an object to the event.

        Args:
            identity: The object.
            at: Time it joined.

        Returns:
            True when the object was new to the event.
        """
        if identity.id in self.objects:
            return False
        self.objects.append(identity.id)
        if len(self.boxes) < MAX_BOXES:
            self.boxes.append(
                {"object": identity.id, "label": identity.label, "box": identity.box.rounded(), "at": round(at, 3)}
            )
        return True

    def as_dict(self) -> dict:
        """Return the event as plain data for logs, the status endpoint and the backend.

        Returns:
            The event fields.
        """
        return {
            "id": self.id,
            "view": self.view,
            "kind": self.kind.value,
            "label": self.label,
            "started_at": self.started_at,
            "ended_at": self.ended_at,
            "zone": self.zone,
            "zone_name": self.zone_name,
            "line": self.line,
            "line_name": self.line_name,
            "direction": self.direction,
            "objects": list(self.objects),
            "boxes": list(self.boxes),
            "count": self.count,
            "alert": self.alert,
        }


@dataclass(frozen=True)
class Update:
    """A change to an event the caller must store or announce.

    Attributes:
        action: open, update, close or instant; an instant event opens and closes at once.
        event: The event after the change.
    """

    action: str
    event: Event


@dataclass
class Episode:
    """State of an open zone episode.

    Attributes:
        event: The open event.
        last_active: Last time a qualifying object was inside.
    """

    event: Event
    last_active: float


class RulesEngine:
    """Rules of one view applied to its tracked objects frame by frame.

    Attributes:
        view: View name.
        rules: Zones, lines and tuning.
        timezone: Time zone of the schedules.
        arm: Callable returning the current arm mode.
        book: Object identities.
        inside: Zone id to identity id to the time the object entered.
        sides: Line id to identity id to the last side the object was clearly on.
        positions: Line id to identity id to the foot point where that side was last confirmed.
        episodes: Open zone episodes by zone id, kind and label.
        closed_at: Last close time of each zone episode key, for the cooldown.
        fired: Instant rule key to the last time it fired for an object.
        line_counts: Line id to direction to label to crossings since start.
        zone_entries: Zone id to label to objects that entered since start.
    """

    def __init__(
        self,
        view: str,
        rules: ViewRules,
        started_at: float,
        timezone: tzinfo,
        arm: Callable[[], ArmMode] = lambda: ArmMode.DISARMED,
    ):
        """Create the engine for one view.

        Args:
            view: View name.
            rules: Zones, lines and tuning.
            started_at: Time the view started, which ends the warm up.
            timezone: Time zone of the schedules.
            arm: Callable returning the current arm mode.
        """
        self.view = view
        self.rules = rules
        self.timezone = timezone
        self.arm = arm
        self.book = TrackBook(rules.tuning, started_at)
        self.inside: dict[str, dict[int, float]] = {}
        self.sides: dict[str, dict[int, int]] = {}
        self.positions: dict[str, dict[int, tuple[float, float]]] = {}
        self.episodes: dict[tuple[str, EventKind, str], Episode] = {}
        self.closed_at: dict[tuple[str, EventKind, str], float] = {}
        self.fired: dict[tuple, float] = {}
        self.line_counts: dict[str, dict[str, Counter]] = {}
        self.zone_entries: dict[str, Counter] = {}
        self.occupancy: dict[str, Counter] = {}
        self.last_time = started_at

    def configure(self, rules: ViewRules) -> list[Update]:
        """Replace the zones and lines while keeping object identities.

        Episodes of zones that were removed, disabled or suspended close at once.

        Args:
            rules: The new rules.

        Returns:
            Updates for the episodes that closed.
        """
        self.rules = rules
        self.book.tuning = rules.tuning
        live = {zone.id for zone in rules.zones if zone.enabled and not zone.suspended}
        updates = []
        for key in [key for key in self.episodes if key[0] not in live]:
            updates.append(self.close(key, self.last_time))
        lines = {line.id for line in rules.lines}
        self.sides = {line_id: sides for line_id, sides in self.sides.items() if line_id in lines}
        self.positions = {line_id: items for line_id, items in self.positions.items() if line_id in lines}
        self.inside = {zone_id: inside for zone_id, inside in self.inside.items() if zone_id in live}
        return updates

    def local(self, moment: float) -> datetime:
        """Convert an epoch time to local wall clock time.

        Args:
            moment: Seconds since the epoch.

        Returns:
            The local time in the configured time zone.
        """
        return datetime.fromtimestamp(moment, self.timezone)

    def process(self, frame: Frame) -> list[Update]:
        """Apply every rule to one frame.

        Args:
            frame: Tracked objects of the frame.

        Returns:
            Event changes caused by the frame, in order.
        """
        now = frame.time
        self.last_time = now
        seen = self.book.update(frame)
        identities = [identity for identity, _ in seen]
        updates: list[Update] = []
        moment = self.local(now)
        for zone in self.rules.zones:
            if zone.enabled and not zone.suspended:
                updates += self.evaluate_zone(zone, identities, now, moment)
        for line in self.rules.lines:
            if line.enabled and not line.suspended:
                updates += self.evaluate_line(line, identities, now, moment)
        updates += self.tick(now)
        return updates

    def tick(self, now: float) -> list[Update]:
        """Close episodes whose objects have been gone for the close delay.

        Called for every frame and on a timer, so episodes close even when a camera stops sending frames.

        Args:
            now: Current time.

        Returns:
            Updates for the episodes that closed.
        """
        delay = self.rules.tuning.close_after
        due = [key for key, episode in self.episodes.items() if now - episode.last_active >= delay]
        return [self.close(key, self.episodes[key].last_active) for key in due]

    def close(self, key: tuple[str, EventKind, str], ended_at: float) -> Update:
        """Close an episode.

        Args:
            key: Zone id, kind and label of the episode.
            ended_at: Time the episode ended.

        Returns:
            The close update.
        """
        episode = self.episodes.pop(key)
        episode.event.ended_at = max(ended_at, episode.event.started_at)
        self.closed_at[key] = episode.event.ended_at
        return Update("close", episode.event)

    def evaluate_zone(self, zone: Zone, identities: list[Identity], now: float, moment: datetime) -> list[Update]:
        """Apply the intrusion, vehicle, loitering and crowd rules of a zone.

        Args:
            zone: The zone.
            identities: Objects seen in the frame.
            now: Frame time.
            moment: Frame time in local time.

        Returns:
            Event changes.
        """
        tuning = self.rules.tuning
        entered = self.inside.setdefault(zone.id, {})
        present: list[Identity] = []
        for identity in identities:
            if not label_matches(zone.labels, identity.label) or not identity.counts:
                continue
            if not point_in_polygon(identity.foot, zone.polygon):
                continue
            present.append(identity)
            if identity.id not in entered:
                entered[identity.id] = now
                self.zone_entries.setdefault(zone.id, Counter())[identity.label] += 1
        current = {identity.id for identity in present}
        for identity_id in [key for key in entered if key not in current]:
            identity = self.book.identities.get(identity_id)
            if identity is None or now - identity.last_seen > tuning.reid_gap or identity.last_seen == now:
                del entered[identity_id]
        self.occupancy[zone.id] = Counter(identity.label for identity in present)
        active = zone.schedule.active(moment)
        updates: list[Update] = []
        dwelled = [identity for identity in present if now - entered[identity.id] >= zone.min_dwell]
        for identity in dwelled:
            kind = EventKind.VEHICLE if identity.label in VEHICLES else EventKind.INTRUSION
            updates += self.join_episode(zone, kind, identity.label, [identity], now, moment, active)
            loiters = zone.loiter_seconds and identity.label not in VEHICLES
            if loiters and now - entered[identity.id] >= zone.loiter_seconds and active:
                updates += self.instant(
                    ("loiter", zone.id, identity.id),
                    EventKind.LOITERING,
                    identity,
                    now,
                    moment,
                    zone=zone,
                )
        if zone.crowd_count and len(dwelled) >= zone.crowd_count:
            label = Counter(identity.label for identity in dwelled).most_common(1)[0][0]
            updates += self.join_episode(zone, EventKind.CROWD, label, dwelled, now, moment, active)
        for key, episode in self.episodes.items():
            if key[0] == zone.id and key[1] != EventKind.CROWD:
                episode.event.count = max(episode.event.count, sum(1 for item in dwelled if item.label == key[2]))
        return updates

    def join_episode(
        self,
        zone: Zone,
        kind: EventKind,
        label: str,
        members: list[Identity],
        now: float,
        moment: datetime,
        active: bool,
    ) -> list[Update]:
        """Keep a zone episode alive with its current members, opening it when needed.

        Args:
            zone: The zone.
            kind: Episode kind.
            label: Episode label.
            members: Objects that keep the episode alive.
            now: Frame time.
            moment: Frame time in local time.
            active: Whether the zone's schedule is active.

        Returns:
            The open update for a new episode, or an update when a new object joined.
        """
        key = (zone.id, kind, label)
        episode = self.episodes.get(key)
        if episode is None:
            if not active:
                return []
            if now - self.closed_at.get(key, float("-inf")) < self.rules.tuning.cooldown:
                return []
            event = Event(
                id=str(uuid.uuid4()),
                view=self.view,
                kind=kind,
                label=label,
                started_at=now,
                zone=zone.id,
                zone_name=zone.name,
                alert=zone.alert.alerts(self.arm(), label, moment),
            )
            for identity in members:
                event.add(identity, now)
            event.count = len(members)
            self.episodes[key] = Episode(event, now)
            return [Update("open", event)]
        episode.last_active = now
        if kind == EventKind.CROWD:
            episode.event.count = max(episode.event.count, len(members))
        changed = [identity for identity in members if episode.event.add(identity, now)]
        return [Update("update", episode.event)] if changed else []

    def evaluate_line(self, line: Line, identities: list[Identity], now: float, moment: datetime) -> list[Update]:
        """Detect crossings of a line and count them.

        An object must be at least the line margin away on one side and then on the other, and its path between
        the two positions must cross the drawn segment, so jitter on the line never counts.

        Args:
            line: The line.
            identities: Objects seen in the frame.
            now: Frame time.
            moment: Frame time in local time.

        Returns:
            Instant events for the crossings that match the line's direction.
        """
        margin = self.rules.tuning.line_margin
        sides = self.sides.setdefault(line.id, {})
        positions = self.positions.setdefault(line.id, {})
        updates: list[Update] = []
        for identity in identities:
            if not label_matches(line.labels, identity.label) or identity.static:
                continue
            offset = side_of_line(identity.foot, line.start, line.end)
            if abs(offset) < margin:
                continue
            side = 1 if offset > 0 else -1
            previous = sides.get(identity.id)
            last_point = positions.get(identity.id)
            sides[identity.id] = side
            positions[identity.id] = identity.foot
            if previous is None or previous == side or last_point is None:
                continue
            if not segments_intersect(last_point, identity.foot, line.start, line.end, LINE_TOLERANCE):
                continue
            direction = "in" if side > 0 else "out"
            counts = self.line_counts.setdefault(line.id, {"in": Counter(), "out": Counter()})
            counts[direction][identity.label] += 1
            if line.direction not in ("both", direction) or not line.schedule.active(moment):
                continue
            updates += self.instant(
                ("line", line.id, identity.id, direction),
                EventKind.LINE_CROSSING,
                identity,
                now,
                moment,
                line=line,
                direction=direction,
            )
        alive = set(self.book.identities)
        for identity_id in [key for key in sides if key not in alive]:
            sides.pop(identity_id, None)
            positions.pop(identity_id, None)
        return updates

    def instant(
        self,
        key: tuple,
        kind: EventKind,
        identity: Identity,
        now: float,
        moment: datetime,
        zone: Zone | None = None,
        line: Line | None = None,
        direction: str | None = None,
    ) -> list[Update]:
        """Fire an instant event unless the same rule fired for the same object within the cooldown.

        Loitering refreshes its debounce time on every frame the object keeps loitering, so it fires once per stay
        and again only after the object was away for the cooldown.

        Args:
            key: Debounce key of the rule and object.
            kind: Event kind.
            identity: The object.
            now: Frame time.
            moment: Frame time in local time.
            zone: Zone of a loitering event.
            line: Line of a crossing.
            direction: Direction of a crossing.

        Returns:
            The instant update, or nothing when debounced.
        """
        last = self.fired.get(key)
        self.fired[key] = now if kind == EventKind.LOITERING or last is None else last
        if last is not None and now - last < self.rules.tuning.cooldown:
            return []
        self.fired[key] = now
        self.fired = {item: at for item, at in self.fired.items() if now - at < FIRED_MEMORY_SECONDS}
        policy = zone.alert if zone is not None else line.alert
        event = Event(
            id=str(uuid.uuid4()),
            view=self.view,
            kind=kind,
            label=identity.label,
            started_at=now,
            ended_at=now,
            zone=zone.id if zone else None,
            zone_name=zone.name if zone else None,
            line=line.id if line else None,
            line_name=line.name if line else None,
            direction=direction,
            count=1,
            alert=policy.alerts(self.arm(), identity.label, moment),
        )
        event.add(identity, now)
        return [Update("instant", event)]

    def snapshot(self) -> dict:
        """Return counts and open events for the status endpoint.

        Returns:
            Occupancy and entries per zone, crossings per line and the open events.
        """
        return {
            "occupancy": {zone_id: dict(counts) for zone_id, counts in self.occupancy.items()},
            "entries": {zone_id: dict(counts) for zone_id, counts in self.zone_entries.items()},
            "crossings": {
                line_id: {direction: dict(counts) for direction, counts in item.items()}
                for line_id, item in self.line_counts.items()
            },
            "open": [episode.event.as_dict() for episode in self.episodes.values()],
            "objects": len(self.book.identities),
            "identities": [
                {
                    "id": identity.id,
                    "label": identity.label,
                    "counts": identity.counts,
                    "initial": identity.initial,
                    "moved": identity.moved,
                    "static": identity.static,
                    "tracks": sorted(identity.tracks),
                    "home": [round(value, 3) for value in identity.home] if identity.home else None,
                    "foot": [round(value, 3) for value in identity.foot],
                }
                for identity in self.book.identities.values()
            ],
        }
