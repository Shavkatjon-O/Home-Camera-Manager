"""Data the rules engine consumes and the configuration of zones and lines."""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime
from enum import StrEnum

from app.rules.geometry import Point
from app.rules.schedule import Schedule

VEHICLES = frozenset({"car", "truck", "bus", "motorcycle"})
ANIMALS = frozenset({"dog", "cat"})
GROUPS = {"vehicle": VEHICLES, "animal": ANIMALS}
WHOLE_VIEW_AREA = 0.95


class ArmMode(StrEnum):
    """Global arm mode that decides which events raise an alert."""

    DISARMED = "disarmed"
    HOME = "home"
    AWAY = "away"
    SCHEDULE = "schedule"


class EventKind(StrEnum):
    """Kinds of events the rules engine produces."""

    INTRUSION = "intrusion"
    VEHICLE = "vehicle"
    LOITERING = "loitering"
    CROWD = "crowd"
    LINE_CROSSING = "line_crossing"
    TAMPER = "tamper"


class AlertMode(StrEnum):
    """When the events of a zone or line raise an alert, below the arm mode."""

    OFF = "off"
    ALWAYS = "always"
    SCHEDULE = "schedule"


def expand_labels(values: list[str] | None) -> frozenset[str]:
    """Expand label groups such as vehicle into their labels.

    Args:
        values: Labels and group names, or None for any label.

    Returns:
        The set of labels; an empty set means any label.
    """
    result: set[str] = set()
    for value in values or []:
        result |= GROUPS.get(value, {value})
    return frozenset(result)


def label_matches(labels: frozenset[str], label: str) -> bool:
    """Tell whether a label passes a class filter.

    Args:
        labels: The filter; an empty filter passes every label.
        label: The detected label.

    Returns:
        True when the label passes.
    """
    return not labels or label in labels


@dataclass(frozen=True)
class Box:
    """An axis aligned box in normalized view coordinates.

    Attributes:
        left: Left edge.
        top: Top edge.
        right: Right edge.
        bottom: Bottom edge.
    """

    left: float
    top: float
    right: float
    bottom: float

    @property
    def foot(self) -> Point:
        """Point: The bottom centre, where a person or vehicle touches the ground."""
        return ((self.left + self.right) / 2, self.bottom)

    @property
    def centre(self) -> Point:
        """Point: The centre of the box."""
        return ((self.left + self.right) / 2, (self.top + self.bottom) / 2)

    def as_tuple(self) -> tuple[float, float, float, float]:
        """Return the box as left, top, right and bottom.

        Returns:
            The four edges.
        """
        return (self.left, self.top, self.right, self.bottom)

    def rounded(self) -> list[float]:
        """Return the box rounded for storage.

        Returns:
            The four edges rounded to four decimals.
        """
        return [round(value, 4) for value in self.as_tuple()]


@dataclass(frozen=True)
class Detection:
    """One tracked object in one frame.

    Attributes:
        track_id: Tracker id, unique within the view while the track lives.
        label: Canonical label such as person or car.
        confidence: Detector or tracker confidence.
        box: Position in normalized view coordinates.
    """

    track_id: int
    label: str
    confidence: float
    box: Box


@dataclass(frozen=True)
class Frame:
    """All tracked objects of one analysed frame of a view.

    Attributes:
        time: Wall clock time of the frame in seconds since the epoch.
        objects: The tracked objects.
    """

    time: float
    objects: tuple[Detection, ...] = ()


@dataclass(frozen=True)
class AlertPolicy:
    """When the events of a zone or line raise an alert.

    Attributes:
        mode: off, always, or schedule for alerts only inside the windows.
        schedule: Alert windows used by the schedule mode.
        labels: Labels that alert; an empty set means any label.
    """

    mode: AlertMode = AlertMode.OFF
    schedule: Schedule = field(default_factory=Schedule)
    labels: frozenset[str] = frozenset()

    @classmethod
    def from_dict(cls, data: dict | None) -> AlertPolicy:
        """Build a policy from its configuration.

        Args:
            data: Mapping with mode, schedule and labels, or None for no alerts.

        Returns:
            The policy.
        """
        data = data or {}
        return cls(
            mode=AlertMode(data.get("mode", AlertMode.OFF)),
            schedule=Schedule.from_list(data.get("schedule")),
            labels=expand_labels(data.get("labels")),
        )

    def alerts(self, arm: ArmMode, label: str, moment: datetime) -> bool:
        """Decide whether an event raises an alert.

        Disarmed never alerts and away alerts for everything. Home alerts only for policies that always alert, and
        schedule adds policies whose windows contain the moment.

        Args:
            arm: The global arm mode.
            label: Label of the event.
            moment: Local time the event started.

        Returns:
            True when the event raises an alert.
        """
        if arm == ArmMode.DISARMED:
            return False
        if arm == ArmMode.AWAY:
            return True
        if not label_matches(self.labels, label):
            return False
        if self.mode == AlertMode.ALWAYS:
            return True
        return arm == ArmMode.SCHEDULE and self.mode == AlertMode.SCHEDULE and self.schedule.active(moment)


@dataclass(frozen=True)
class Zone:
    """A polygon zone and the rules evaluated on it.

    Attributes:
        id: Stable identifier.
        name: Display name.
        polygon: Vertices in normalized view coordinates.
        labels: Labels the zone reacts to; an empty set means any label.
        min_dwell: Seconds an object stays inside before an intrusion opens.
        loiter_seconds: Seconds inside before a loitering event, 0 turns loitering off.
        crowd_count: Objects inside at once that make a crowd, 0 turns crowding off.
        schedule: When the zone produces events.
        alert: When its events alert.
        enabled: False keeps the zone configured but silent.
        suspended: True while the view no longer matches the scene the zone was drawn on.
        reference: Snapshot the zone was drawn on, relative to the events folder, for lenses that move.
    """

    id: str
    name: str
    polygon: tuple[Point, ...]
    labels: frozenset[str] = frozenset()
    min_dwell: float = 1.0
    loiter_seconds: float = 0.0
    crowd_count: int = 0
    schedule: Schedule = field(default_factory=Schedule)
    alert: AlertPolicy = field(default_factory=AlertPolicy)
    enabled: bool = True
    suspended: bool = False
    reference: str | None = None

    @property
    def whole_view(self) -> bool:
        """bool: True when the polygon covers nearly the whole picture, so it stays valid wherever a lens points."""
        area = 0.0
        points = self.polygon
        for index, (x1, y1) in enumerate(points):
            x2, y2 = points[(index + 1) % len(points)]
            area += x1 * y2 - x2 * y1
        return abs(area) / 2 >= WHOLE_VIEW_AREA

    @classmethod
    def from_dict(cls, data: dict) -> Zone:
        """Build a zone from its configuration.

        Args:
            data: Mapping as stored by the backend.

        Returns:
            The zone.
        """
        return cls(
            id=str(data["id"]),
            name=str(data.get("name") or data["id"]),
            polygon=tuple((float(x), float(y)) for x, y in data["polygon"]),
            labels=expand_labels(data.get("labels")),
            min_dwell=float(data.get("min_dwell", 1.0)),
            loiter_seconds=float(data.get("loiter_seconds") or 0.0),
            crowd_count=int(data.get("crowd_count") or 0),
            schedule=Schedule.from_list(data.get("schedule")),
            alert=AlertPolicy.from_dict(data.get("alert")),
            enabled=bool(data.get("enabled", True)),
            suspended=bool(data.get("suspended", False)),
            reference=data.get("reference") or None,
        )


@dataclass(frozen=True)
class Line:
    """A counting line and the crossing rule evaluated on it.

    Crossing from the negative to the positive side counts as in. For a line drawn from left to right the positive
    side is below the line, so in means moving down the picture.

    Attributes:
        id: Stable identifier.
        name: Display name.
        start: First point in normalized view coordinates.
        end: Second point.
        labels: Labels the line counts; an empty set means any label.
        direction: in, out or both, the crossings that produce events.
        schedule: When the line produces events.
        alert: When its events alert.
        enabled: False keeps the line configured but silent.
        suspended: True while the view no longer matches the scene the line was drawn on.
        reference: Snapshot the line was drawn on, relative to the events folder, for lenses that move.
    """

    id: str
    name: str
    start: Point
    end: Point
    labels: frozenset[str] = frozenset()
    direction: str = "both"
    schedule: Schedule = field(default_factory=Schedule)
    alert: AlertPolicy = field(default_factory=AlertPolicy)
    enabled: bool = True
    suspended: bool = False
    reference: str | None = None

    @classmethod
    def from_dict(cls, data: dict) -> Line:
        """Build a line from its configuration.

        Args:
            data: Mapping as stored by the backend.

        Returns:
            The line.
        """
        start, end = data["points"]
        direction = str(data.get("direction", "both"))
        if direction not in ("in", "out", "both"):
            raise ValueError(f"Line direction must be in, out or both, not {direction!r}")
        return cls(
            id=str(data["id"]),
            name=str(data.get("name") or data["id"]),
            start=(float(start[0]), float(start[1])),
            end=(float(end[0]), float(end[1])),
            labels=expand_labels(data.get("labels")),
            direction=direction,
            schedule=Schedule.from_list(data.get("schedule")),
            alert=AlertPolicy.from_dict(data.get("alert")),
            enabled=bool(data.get("enabled", True)),
            suspended=bool(data.get("suspended", False)),
            reference=data.get("reference") or None,
        )


@dataclass(frozen=True)
class Tuning:
    """Timing and distance settings shared by every rule of a view.

    Attributes:
        close_after: Seconds without a qualifying object before an open event closes.
        cooldown: Seconds before the same zone opens a new event of the same kind, and before the same object
            fires the same instant rule again.
        reid_gap: Seconds a lost track may stay away and still be taken as the same object.
        reid_distance: Largest jump of the foot point, in normalized units, that still joins a lost track.
        move_threshold: Smallest displacement that marks an object as moving; vehicles and objects present at
            start must move before they count.
        move_ratio: Displacement, as a share of the object's own height, that marks it as moving when that is
            larger than the threshold.
        static_seconds: Seconds an object may stay in place before it is treated as part of the scene.
        static_radius: Largest wander, in normalized units, that still counts as staying in place.
        warmup: Seconds after a view starts during which objects found are taken as already present.
        line_margin: Distance from a line an object must reach on each side before a crossing counts.
        min_confidence: Detections below this confidence are ignored.
    """

    close_after: float = 6.0
    cooldown: float = 20.0
    reid_gap: float = 4.0
    reid_distance: float = 0.08
    move_threshold: float = 0.03
    move_ratio: float = 0.75
    static_seconds: float = 180.0
    static_radius: float = 0.015
    warmup: float = 8.0
    line_margin: float = 0.008
    min_confidence: float = 0.0

    @classmethod
    def from_dict(cls, data: dict | None) -> Tuning:
        """Build the tuning from its configuration, keeping defaults for missing keys.

        Args:
            data: Mapping of setting names to numbers, or None.

        Returns:
            The tuning.
        """
        data = data or {}
        known = {name: float(data[name]) for name in cls.__dataclass_fields__ if name in data}
        return cls(**known)


@dataclass(frozen=True)
class ViewRules:
    """Every zone and line of one analytics view.

    Attributes:
        zones: The zones.
        lines: The lines.
        tuning: Shared timing and distance settings.
    """

    zones: tuple[Zone, ...] = ()
    lines: tuple[Line, ...] = ()
    tuning: Tuning = field(default_factory=Tuning)

    @classmethod
    def from_dict(cls, data: dict | None) -> ViewRules:
        """Build the rules of a view from its configuration.

        Args:
            data: Mapping with zones, lines and tuning, or None for no rules.

        Returns:
            The rules.
        """
        data = data or {}
        return cls(
            zones=tuple(Zone.from_dict(item) for item in data.get("zones") or []),
            lines=tuple(Line.from_dict(item) for item in data.get("lines") or []),
            tuning=Tuning.from_dict(data.get("tuning")),
        )
