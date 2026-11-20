"""Object identities over time: joins tracks the tracker split and marks moving and static objects."""

from __future__ import annotations

from dataclasses import dataclass, field

from app.rules.geometry import Point, distance, iou
from app.rules.model import VEHICLES, Box, Detection, Frame, Tuning

STATIC_MEMORY_SECONDS = 3600.0
STATIC_MEMORY_IOU = 0.5
HOME_SAMPLES = 5
STATIC_SHARE = 0.2
RESUME_GAP_SECONDS = 15.0
MOVE_FRAMES = 3


@dataclass
class Identity:
    """One real object as the rules engine sees it, possibly across several tracker ids.

    Attributes:
        id: Stable identity, the first tracker id the object had.
        label: Canonical label.
        first_seen: Time the object was first seen.
        last_seen: Time the object was last seen.
        first_foot: Foot point when first seen.
        home: Median foot point of the first sightings, where movement is measured from.
        samples: Foot points collected until the home point is known.
        away: Consecutive frames the object has been beyond the move distance from home.
        foot: Latest foot point.
        box: Latest box.
        confidence: Latest confidence.
        initial: True when the object was already there while the view warmed up.
        moved: True once the object stayed beyond the move distance from home for several frames. The distance is
            the move threshold or a share of the object's height, whichever is larger, so box jitter on a large or
            partly visible object never counts as movement.
        rest_point: Where the object has been staying since rest_since.
        rest_since: Time it arrived at the rest point.
        static: True while the object has stayed in place long enough to count as part of the scene. Leaving the
            rest point ends it, and the object then has to move away from that point like a new one before it
            counts again, so box jitter on a parked car never wakes it up.
        tracks: Every tracker id joined into this identity.
        hits: Recent times the detector found the object, until it is confirmed.
        confirmed: True once the detector found the object often enough; the tracker alone keeps a box for a few
            seconds after a single detection, which would let a one-frame false detection pass the dwell.
    """

    id: int
    label: str
    first_seen: float
    last_seen: float
    first_foot: Point
    home: Point | None = None
    samples: list[Point] = field(default_factory=list)
    away: int = 0
    foot: Point = (0.0, 0.0)
    box: Box = Box(0.0, 0.0, 0.0, 0.0)
    confidence: float = 0.0
    initial: bool = False
    moved: bool = False
    rest_point: Point = (0.0, 0.0)
    rest_since: float = 0.0
    static: bool = False
    tracks: set[int] = field(default_factory=set)
    hits: list[float] = field(default_factory=list)
    confirmed: bool = False

    @property
    def counts(self) -> bool:
        """bool: True when the object may trigger zone rules.

        Static objects never count. Vehicles and objects present at start count only once they moved, so parked
        cars and anything standing in the picture when the service starts stay silent.
        """
        if self.static or not self.confirmed:
            return False
        if self.label in VEHICLES or self.initial:
            return self.moved
        return True


@dataclass
class StaticMemory:
    """A place where a static object stood, remembered after its track ended.

    Attributes:
        label: Label of the object.
        box: Its last box.
        until: Time the memory expires.
    """

    label: str
    box: Box
    until: float


class TrackBook:
    """Turns tracker output into identities.

    A track that disappears and a new track of the same label that appears near its last foot point within the
    re-identification gap are joined, so one walker who is briefly lost is still one object for dwell, loitering and
    line crossing. A static object that is lost and found again in the same place stays static.

    Attributes:
        tuning: Timing and distance settings.
        started_at: Time the view's frames started, or resumed after a gap, which starts the warm up.
        last_frame: Time of the latest frame.
        identities: Live and recently lost identities by identity id.
        by_track: Tracker id to identity id for tracks seen recently.
        memories: Places of static objects whose tracks ended.
    """

    def __init__(self, tuning: Tuning, started_at: float):
        """Create an empty book.

        Args:
            tuning: Timing and distance settings.
            started_at: Time the view started.
        """
        self.tuning = tuning
        self.started_at = started_at
        self.identities: dict[int, Identity] = {}
        self.by_track: dict[int, int] = {}
        self.memories: list[StaticMemory] = []
        self.last_frame: float | None = None

    def update(self, frame: Frame) -> list[tuple[Identity, Detection]]:
        """Fold one frame into the book.

        Args:
            frame: The tracked objects of the frame.

        Returns:
            The identity and detection of every object in the frame that passed the confidence floor.
        """
        now = frame.time
        if self.last_frame is None or now - self.last_frame > RESUME_GAP_SECONDS:
            self.started_at = now
        self.last_frame = now
        self.expire(now)
        result: list[tuple[Identity, Detection]] = []
        claimed: set[int] = set()
        fresh: list[Detection] = []
        for detection in frame.objects:
            if detection.confidence < self.tuning.min_confidence:
                continue
            identity_id = self.by_track.get(detection.track_id)
            if identity_id is not None and identity_id in self.identities and identity_id not in claimed:
                claimed.add(identity_id)
                identity = self.identities[identity_id]
                self.observe(identity, detection, now)
                result.append((identity, detection))
            else:
                fresh.append(detection)
        for detection in fresh:
            identity = self.rejoin(detection, now, claimed) or self.create(detection, now)
            claimed.add(identity.id)
            identity.tracks.add(detection.track_id)
            self.by_track[detection.track_id] = identity.id
            self.observe(identity, detection, now)
            result.append((identity, detection))
        return result

    def rejoin(self, detection: Detection, now: float, claimed: set[int]) -> Identity | None:
        """Find a recently lost identity a new track continues.

        Args:
            detection: First detection of the new track.
            now: Frame time.
            claimed: Identities already matched in this frame.

        Returns:
            The nearest lost identity of the same label within the gap and distance, or None.
        """
        foot = detection.box.foot
        best: Identity | None = None
        best_distance = self.tuning.reid_distance
        for identity in self.identities.values():
            if identity.id in claimed or identity.label != detection.label:
                continue
            if identity.last_seen >= now or now - identity.last_seen > self.tuning.reid_gap:
                continue
            gap = distance(identity.foot, foot)
            if gap <= best_distance:
                best, best_distance = identity, gap
        return best

    def create(self, detection: Detection, now: float) -> Identity:
        """Start a new identity for a track that continues nothing.

        Args:
            detection: First detection of the track.
            now: Frame time.

        Returns:
            The new identity.
        """
        foot = detection.box.foot
        identity = Identity(
            id=detection.track_id,
            label=detection.label,
            first_seen=now,
            last_seen=now,
            first_foot=foot,
            foot=foot,
            box=detection.box,
            confidence=detection.confidence,
            initial=now - self.started_at < self.tuning.warmup,
            rest_point=foot,
            rest_since=now,
        )
        for memory in self.memories:
            if (
                memory.label == detection.label
                and iou(memory.box.as_tuple(), detection.box.as_tuple()) >= STATIC_MEMORY_IOU
            ):
                identity.static = True
                identity.initial = True
                identity.rest_since = now - self.tuning.static_seconds
                break
        self.identities[identity.id] = identity
        return identity

    def observe(self, identity: Identity, detection: Detection, now: float) -> None:
        """Update an identity with its latest detection.

        Args:
            identity: The identity.
            detection: Its detection in the current frame.
            now: Frame time.
        """
        foot = detection.box.foot
        if not identity.confirmed and detection.detected:
            window = self.tuning.confirm_window
            identity.hits = [hit for hit in identity.hits if now - hit <= window] + [now]
            identity.confirmed = len(identity.hits) >= self.tuning.confirm_hits
        identity.last_seen = now
        identity.foot = foot
        identity.box = detection.box
        identity.confidence = detection.confidence
        if identity.home is None:
            identity.samples.append(foot)
            if len(identity.samples) >= HOME_SAMPLES:
                xs = sorted(point[0] for point in identity.samples)
                ys = sorted(point[1] for point in identity.samples)
                identity.home = (xs[len(xs) // 2], ys[len(ys) // 2])
                identity.samples = []
        height = detection.box.bottom - detection.box.top
        if identity.home is not None and not identity.moved:
            limit = max(self.tuning.move_threshold, self.tuning.move_ratio * height)
            identity.away = identity.away + 1 if distance(identity.home, foot) >= limit else 0
            identity.moved = identity.away >= MOVE_FRAMES
        if distance(identity.rest_point, foot) > max(self.tuning.static_radius, STATIC_SHARE * height):
            if identity.static:
                identity.static = False
                identity.home = identity.rest_point
                identity.moved = False
                identity.away = 0
            identity.rest_point = foot
            identity.rest_since = now
        elif now - identity.rest_since >= self.tuning.static_seconds:
            identity.static = True

    def expire(self, now: float) -> None:
        """Forget identities lost for longer than the gap and remember where static ones stood.

        Args:
            now: Current time.
        """
        for identity_id, identity in list(self.identities.items()):
            if now - identity.last_seen <= self.tuning.reid_gap:
                continue
            if identity.static:
                self.memories.append(StaticMemory(identity.label, identity.box, now + STATIC_MEMORY_SECONDS))
            del self.identities[identity_id]
            for track_id in identity.tracks:
                self.by_track.pop(track_id, None)
        self.memories = [memory for memory in self.memories if memory.until > now]

    def lost(self, now: float) -> list[Identity]:
        """Return identities not seen in the frame at the given time.

        Args:
            now: Time of the latest frame.

        Returns:
            Identities whose last sighting is older than now.
        """
        return [identity for identity in self.identities.values() if identity.last_seen < now]
