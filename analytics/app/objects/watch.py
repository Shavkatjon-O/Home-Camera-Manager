"""Objects left and taken in zones, from the tracked detections of a view.

The tracker loses and renews the ids of objects that stand still, and night pictures make detections flicker, so
an object is followed as a place: a label group and a box. A detection joins the place that carries its track id,
or else the place of the same group whose box it overlaps; brief gaps never reset a place.

- Left: an object that arrived while the view was watched and stays still inside a zone for the zone's left time
  raises one object_left event. Objects in the picture when the view starts are the baseline and never count as
  left, and a place remembered from earlier keeps that status, so parked bicycles and boxes stay silent.
- Taken: an object that was present for the zone's taken time and then stays missing for the grace while frames
  keep arriving raises one object_taken event, but only when someone was near it shortly before it went missing or
  it was seen moving away. Detections that fade at night or during an infrared switch therefore never count as
  taken. A person standing over the place postpones the decision, and the object coming back cancels it.
"""

from __future__ import annotations

import itertools
import uuid
from dataclasses import dataclass, field
from datetime import datetime, tzinfo

from app.objects.zones import ObjectZone, object_zones
from app.rules.engine import Event, Update
from app.rules.geometry import iou, point_in_polygon
from app.rules.kinds import ExtraKind
from app.rules.model import ArmMode, Box, Detection, Frame

GROUPS = {"backpack": "bag", "handbag": "bag", "suitcase": "bag", "truck": "vehicle", "car": "vehicle"}
PERSON = "person"

MATCH_IOU = 0.4
STILL_IOU = 0.6
AWAY_IOU = 0.3
OCCLUSION_SHARE = 0.3
BOX_SMOOTHING = 0.2

WARMUP_SECONDS = 30.0
RESUME_GAP_SECONDS = 15.0
PRESENCE = 0.3
NEAR_SECONDS = 30.0
NEAR_MARGIN = 0.5
TRANSIENT_SECONDS = 20.0
FORGET_SECONDS = 600.0
MEMORY_SECONDS = 86400.0


def group_of(label: str) -> str:
    """Return the group a label is matched in, because the detector swaps similar labels on one object.

    Args:
        label: Canonical label.

    Returns:
        The group, the label itself when it has none.
    """
    return GROUPS.get(label, label)


def overlap_share(box: Box, other: Box) -> float:
    """Return the share of a box covered by another box.

    Args:
        box: The covered box.
        other: The covering box.

    Returns:
        Covered area over the box's area, 0 for an empty box.
    """
    width = max(0.0, min(box.right, other.right) - max(box.left, other.left))
    height = max(0.0, min(box.bottom, other.bottom) - max(box.top, other.top))
    area = (box.right - box.left) * (box.bottom - box.top)
    return width * height / area if area > 0 else 0.0


def grown(box: Box, margin: float) -> Box:
    """Return a box grown by a share of its size on every side.

    Args:
        box: The box.
        margin: Share of the width and height added on each side.

    Returns:
        The grown box.
    """
    width, height = box.right - box.left, box.bottom - box.top
    return Box(
        box.left - width * margin, box.top - height * margin, box.right + width * margin, box.bottom + height * margin
    )


@dataclass
class Place:
    """An object followed by where it is.

    Attributes:
        id: Stable id, used as the object id of its events.
        label: Latest label.
        group: Label group used for matching.
        box: Smoothed latest box.
        anchor: Box where the object came to rest.
        first_seen: Time the place was created.
        last_seen: Time it was last detected.
        still_since: Time it came to rest at the anchor.
        first_frame: Frame number at creation, for its presence.
        hits: Frames it was detected in.
        baseline: True for objects already there when the view started or remembered from earlier.
        left_fired: True once it raised left.
        missing_since: Time it was last missed after being seen, None while it is seen.
        moved_away: True when its latest detection was away from where it rested longest.
        near_at: Last time a person was near it.
        settled: Box of an earlier rest that lasted longer than the current one, None when there was none.
        settled_for: Seconds that earlier rest lasted.
        tracks: Tracker ids it carried.
    """

    id: int
    label: str
    group: str
    box: Box
    anchor: Box
    first_seen: float
    last_seen: float
    still_since: float
    first_frame: int
    hits: int = 1
    baseline: bool = False
    left_fired: bool = False
    missing_since: float | None = None
    moved_away: bool = False
    near_at: float = float("-inf")
    settled: Box | None = None
    settled_for: float = 0.0
    tracks: set[int] = field(default_factory=set)

    def presence(self, frames: int) -> float:
        """Return the share of frames the place was detected in since it was created.

        Args:
            frames: Current frame number of the view.

        Returns:
            A share from 0 to 1.
        """
        return self.hits / max(1, frames - self.first_frame + 1)

    def observe(self, detection: Detection, now: float) -> None:
        """Fold in a detection of the place's object.

        Args:
            detection: The detection.
            now: Frame time.
        """
        box = detection.box
        rate = BOX_SMOOTHING
        self.box = Box(
            (1 - rate) * self.box.left + rate * box.left,
            (1 - rate) * self.box.top + rate * box.top,
            (1 - rate) * self.box.right + rate * box.right,
            (1 - rate) * self.box.bottom + rate * box.bottom,
        )
        self.label = detection.label
        self.last_seen = now
        self.hits += 1
        self.missing_since = None
        self.tracks.add(detection.track_id)
        if iou(box.as_tuple(), self.anchor.as_tuple()) < STILL_IOU:
            rested = now - self.still_since
            if rested > self.settled_for:
                self.settled, self.settled_for = self.anchor, rested
            self.anchor = box
            self.box = box
            self.still_since = now
        self.moved_away = iou(box.as_tuple(), self.rest()[0].as_tuple()) < AWAY_IOU

    def rest(self) -> tuple[Box, float]:
        """Return where the object rested longest and for how long.

        Returns:
            The box and the seconds of the longer of the current rest and the earlier one.
        """
        current = self.last_seen - self.still_since
        if self.settled is not None and self.settled_for > current:
            return self.settled, self.settled_for
        return self.anchor, current


@dataclass(frozen=True)
class Memory:
    """A place that was forgotten, remembered so its object keeps its status when it is found again.

    Attributes:
        group: Label group.
        box: Its anchor.
        until: Time the memory expires.
    """

    group: str
    box: Box
    until: float


class ObjectWatch:
    """Objects left and taken in the zones of one view.

    Attributes:
        view: View id.
        started_at: Time the view's frames started, or resumed after a gap.
        last_frame: Time of the latest frame.
        frames: Frames seen.
        places: Followed objects by place id.
        memories: Forgotten places.
        ids: Source of place ids.
    """

    def __init__(self, view: str):
        """Create the watch of a view.

        Args:
            view: View id.
        """
        self.view = view
        self.started_at: float | None = None
        self.last_frame: float | None = None
        self.frames = 0
        self.places: dict[int, Place] = {}
        self.memories: list[Memory] = []
        self.ids = itertools.count(1)

    def update(self, frame: Frame, zones: list[dict], arm: ArmMode, timezone: tzinfo) -> list[Update]:
        """Fold one frame in and return the left and taken events it causes.

        Args:
            frame: Tracked objects of the frame, of every label.
            zones: The view's zone mappings.
            arm: Current arm mode.
            timezone: Time zone of the schedules.

        Returns:
            Instant updates for objects left and taken.
        """
        now = frame.time
        if self.last_frame is None:
            self.started_at = now
        elif now - self.last_frame > RESUME_GAP_SECONDS:
            for place in self.places.values():
                place.missing_since = None
        self.last_frame = now
        self.frames += 1
        rules = object_zones(zones)
        if not rules:
            return []
        watched = frozenset().union(*(rule.labels for rule in rules))
        people = [item.box for item in frame.objects if item.label == PERSON]
        self.match([item for item in frame.objects if item.label in watched], now)
        for place in self.places.values():
            if any(overlap_share(grown(place.box, NEAR_MARGIN), person) > 0 for person in people):
                place.near_at = now
            if place.last_seen == now:
                continue
            if place.missing_since is None or any(
                overlap_share(place.box, person) > OCCLUSION_SHARE for person in people
            ):
                place.missing_since = now
        moment = datetime.fromtimestamp(now, timezone)
        updates = self.left(rules, now, moment, arm) + self.taken(rules, now, moment, arm)
        self.forget(now)
        return updates

    def match(self, detections: list[Detection], now: float) -> None:
        """Join detections to places, creating places for new objects.

        Args:
            detections: Detections of watched labels.
            now: Frame time.
        """
        claimed: set[int] = set()
        rest = []
        for detection in detections:
            place = next(
                (item for item in self.places.values() if detection.track_id in item.tracks and item.id not in claimed),
                None,
            )
            if place is None:
                rest.append(detection)
                continue
            claimed.add(place.id)
            place.observe(detection, now)
        for detection in rest:
            group = group_of(detection.label)
            best, best_overlap = None, MATCH_IOU
            for place in self.places.values():
                if place.id in claimed or place.group != group:
                    continue
                overlap = iou(detection.box.as_tuple(), place.box.as_tuple())
                if overlap >= best_overlap:
                    best, best_overlap = place, overlap
            if best is None:
                best = self.create(detection, now)
            else:
                best.observe(detection, now)
            claimed.add(best.id)

    def create(self, detection: Detection, now: float) -> Place:
        """Start a place for an object no place explains.

        Args:
            detection: Its first detection.
            now: Frame time.

        Returns:
            The new place.
        """
        group = group_of(detection.label)
        remembered = any(
            memory.group == group and iou(memory.box.as_tuple(), detection.box.as_tuple()) >= MATCH_IOU
            for memory in self.memories
        )
        place = Place(
            id=next(self.ids),
            label=detection.label,
            group=group,
            box=detection.box,
            anchor=detection.box,
            first_seen=now,
            last_seen=now,
            still_since=now,
            first_frame=self.frames,
            baseline=remembered or now - self.started_at < WARMUP_SECONDS,
            tracks={detection.track_id},
        )
        self.places[place.id] = place
        return place

    @staticmethod
    def inside(place: Place, box: Box, rule: ObjectZone) -> bool:
        """Tell whether a place's box is inside a zone and the zone watches its label.

        Args:
            place: The place.
            box: The box to test, its current rest or its longest rest.
            rule: The object zone.

        Returns:
            True when the box's foot point is inside and the label is watched.
        """
        return place.label in rule.labels and point_in_polygon(box.foot, rule.zone.polygon)

    def left(self, rules: list[ObjectZone], now: float, moment: datetime, arm: ArmMode) -> list[Update]:
        """Raise left for objects that arrived and stayed still long enough.

        Args:
            rules: Object zones.
            now: Frame time.
            moment: Local frame time.
            arm: Current arm mode.

        Returns:
            Instant updates.
        """
        updates = []
        for place in self.places.values():
            if place.baseline or place.left_fired or place.last_seen != now:
                continue
            if place.presence(self.frames) < PRESENCE:
                continue
            for rule in rules:
                if not rule.left_seconds or now - place.still_since < rule.left_seconds:
                    continue
                if not self.inside(place, place.anchor, rule) or not rule.zone.schedule.active(moment):
                    continue
                place.left_fired = True
                updates.append(self.event(ExtraKind.OBJECT_LEFT, place, rule, now, moment, arm))
                break
        return updates

    def taken(self, rules: list[ObjectZone], now: float, moment: datetime, arm: ArmMode) -> list[Update]:
        """Raise taken for long present objects that went missing after someone came near.

        Args:
            rules: Object zones.
            now: Frame time.
            moment: Local frame time.
            arm: Current arm mode.

        Returns:
            Instant updates.
        """
        updates = []
        for place in list(self.places.values()):
            if place.missing_since is None:
                continue
            home, rested = place.rest()
            for rule in rules:
                if not rule.taken_seconds or rested < rule.taken_seconds:
                    continue
                if now - place.missing_since < rule.taken_grace or place.presence(self.frames) < PRESENCE / 2:
                    continue
                touched = place.last_seen - place.near_at <= NEAR_SECONDS or place.moved_away
                if not touched or not self.inside(place, home, rule) or not rule.zone.schedule.active(moment):
                    continue
                updates.append(self.event(ExtraKind.OBJECT_TAKEN, place, rule, now, moment, arm, home))
                del self.places[place.id]
                self.memories.append(Memory(place.group, home, now + MEMORY_SECONDS))
                break
        return updates

    def forget(self, now: float) -> None:
        """Drop places missing for long and transient detections, remembering real objects.

        Args:
            now: Current time.
        """
        for place_id, place in list(self.places.items()):
            missing = now - place.last_seen
            if missing > TRANSIENT_SECONDS and place.last_seen - place.first_seen < TRANSIENT_SECONDS:
                del self.places[place_id]
            elif missing > FORGET_SECONDS:
                del self.places[place_id]
                self.memories.append(Memory(place.group, place.anchor, now + MEMORY_SECONDS))
        self.memories = [memory for memory in self.memories if memory.until > now]

    def event(
        self,
        kind: ExtraKind,
        place: Place,
        rule: ObjectZone,
        now: float,
        moment: datetime,
        arm: ArmMode,
        box: Box | None = None,
    ) -> Update:
        """Build the instant event of a place.

        Args:
            kind: object_left or object_taken.
            place: The place.
            rule: The zone it happened in.
            now: Event time.
            moment: Local event time.
            arm: Current arm mode.
            box: Box to report, the place's current rest when None.

        Returns:
            The instant update.
        """
        box = box or place.anchor
        event = Event(
            id=str(uuid.uuid4()),
            view=self.view,
            kind=kind,
            label=place.label,
            started_at=now,
            ended_at=now,
            zone=rule.zone.id,
            zone_name=rule.zone.name,
            objects=[place.id],
            boxes=[{"object": place.id, "label": place.label, "box": box.rounded(), "at": round(now, 3)}],
            count=1,
            alert=rule.zone.alert.alerts(arm, place.label, moment),
        )
        return Update("instant", event)

    def snapshot(self) -> dict:
        """Return the followed objects for the status endpoint.

        Returns:
            Places with their state.
        """
        return {
            "places": [
                {
                    "id": place.id,
                    "label": place.label,
                    "box": place.anchor.rounded(),
                    "baseline": place.baseline,
                    "left": place.left_fired,
                    "missing_since": place.missing_since,
                    "presence": round(place.presence(self.frames), 2),
                }
                for place in self.places.values()
            ],
            "memories": len(self.memories),
        }
