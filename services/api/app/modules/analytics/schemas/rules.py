"""Schemas of zones, lines, schedules and alert policies."""

from typing import Annotated
from uuid import UUID

from pydantic import BaseModel, Field, field_validator

from app.modules.analytics.enums import LABEL_GROUPS, LABELS, AlertMode, AnimalMode, LineDirection

__all__ = ["AlertPolicy", "LineInput", "LineRead", "RulesUpdate", "Window", "ZoneInput", "ZoneRead"]

Coordinate = Annotated[float, Field(ge=0.0, le=1.0)]
Point = tuple[Coordinate, Coordinate]
CLOCK = r"^([01]\d|2[0-3]):[0-5]\d$"
REFERENCE = r"^analytics/references/[0-9a-f-]{36}/\d+\.jpg$"
ALLOWED_LABELS = set(LABELS) | set(LABEL_GROUPS)


def check_labels(values: list[str]) -> list[str]:
    """Reject unknown labels and drop duplicates.

    Args:
        values: Labels and label groups.

    Returns:
        The labels in their original order.

    Raises:
        ValueError: A label is unknown.
    """
    unknown = [value for value in values if value not in ALLOWED_LABELS]
    if unknown:
        raise ValueError(f"Unknown labels: {', '.join(unknown)}")
    return list(dict.fromkeys(values))


class Window(BaseModel):
    """A weekly time window; an end not after the start runs past midnight.

    Attributes:
        start: Start as HH:MM.
        end: End as HH:MM.
        days: Weekdays the window starts on, 0 is Monday; empty for every day.
    """

    start: str = Field(pattern=CLOCK)
    end: str = Field(pattern=CLOCK)
    days: list[Annotated[int, Field(ge=0, le=6)]] = Field(default_factory=list, max_length=7)


class AlertPolicy(BaseModel):
    """When the events of a zone or line raise an alert.

    Attributes:
        mode: off, always or schedule.
        schedule: Alert windows of the schedule mode.
        labels: Labels that alert, empty for any label.
    """

    mode: AlertMode = AlertMode.OFF
    schedule: list[Window] = Field(default_factory=list, max_length=14)
    labels: list[str] = Field(default_factory=list, max_length=10)

    @field_validator("labels")
    @classmethod
    def known_labels(cls, values: list[str]) -> list[str]:
        """Reject unknown labels.

        Args:
            values: The labels.

        Returns:
            The labels.
        """
        return check_labels(values)


class ZoneInput(BaseModel):
    """A zone as the editor saves it.

    Attributes:
        uuid: Id to keep, None for a new zone.
        name: Display name.
        polygon: Vertices in normalized view coordinates.
        whole_view: The zone covers the whole picture.
        labels: Labels and label groups the zone reacts to.
        min_dwell: Seconds inside before an intrusion opens.
        loiter_seconds: Seconds inside before a loitering event, 0 for off.
        crowd_count: Objects inside at once that make a crowd, 0 for off.
        schedule: When the zone produces events.
        alert: Alert policy.
        enabled: Whether the zone produces events.
        reference: Snapshot the zone was drawn on.
        left_seconds: Seconds a carried object stays still before it counts as left, 0 for off.
        taken_seconds: Seconds an object must have been present before its going counts as taken, 0 for off.
        object_labels: Labels watched for left and taken, empty for the default carried objects.
        background: Also find unclassed objects by comparing with the empty scene.
        animals: What dogs, cats and birds do in the zone.
    """

    uuid: UUID | None = None
    name: str = Field(min_length=1, max_length=60)
    polygon: list[Point] = Field(default_factory=list, max_length=64)
    whole_view: bool = False
    labels: list[str] = Field(default_factory=list, max_length=10)
    min_dwell: float = Field(1.0, ge=0.0, le=600.0)
    loiter_seconds: float = Field(0.0, ge=0.0, le=3600.0)
    crowd_count: int = Field(0, ge=0, le=100)
    schedule: list[Window] = Field(default_factory=list, max_length=14)
    alert: AlertPolicy = Field(default_factory=AlertPolicy)
    enabled: bool = True
    reference: str | None = Field(None, pattern=REFERENCE)
    left_seconds: float = Field(0.0, ge=0.0, le=86400.0)
    taken_seconds: float = Field(0.0, ge=0.0, le=86400.0)
    object_labels: list[str] = Field(default_factory=list, max_length=10)
    background: bool = False
    animals: AnimalMode = AnimalMode.RECORD

    @field_validator("labels", "object_labels")
    @classmethod
    def known_labels(cls, values: list[str]) -> list[str]:
        """Reject unknown labels.

        Args:
            values: The labels.

        Returns:
            The labels.
        """
        return check_labels(values)

    def full_polygon(self) -> list[list[float]]:
        """Return the polygon to store, the full picture for a whole-view zone.

        Returns:
            The vertices.

        Raises:
            ValueError: A zone that is not whole-view has fewer than three vertices.
        """
        if self.whole_view:
            return [[0.0, 0.0], [1.0, 0.0], [1.0, 1.0], [0.0, 1.0]]
        if len(self.polygon) < 3:
            raise ValueError(f"Zone {self.name} needs at least three points")
        return [[round(x, 4), round(y, 4)] for x, y in self.polygon]


class LineInput(BaseModel):
    """A line as the editor saves it.

    Attributes:
        uuid: Id to keep, None for a new line.
        name: Display name.
        points: Start and end point.
        labels: Labels and label groups the line counts.
        direction: Crossings that produce events.
        schedule: When the line produces events.
        alert: Alert policy.
        enabled: Whether the line produces events.
        reference: Snapshot the line was drawn on.
        animals: What dogs, cats and birds crossing the line do.
    """

    uuid: UUID | None = None
    name: str = Field(min_length=1, max_length=60)
    points: tuple[Point, Point]
    labels: list[str] = Field(default_factory=list, max_length=10)
    direction: LineDirection = LineDirection.BOTH
    schedule: list[Window] = Field(default_factory=list, max_length=14)
    alert: AlertPolicy = Field(default_factory=AlertPolicy)
    enabled: bool = True
    reference: str | None = Field(None, pattern=REFERENCE)
    animals: AnimalMode = AnimalMode.RECORD

    @field_validator("labels")
    @classmethod
    def known_labels(cls, values: list[str]) -> list[str]:
        """Reject unknown labels.

        Args:
            values: The labels.

        Returns:
            The labels.
        """
        return check_labels(values)

    @field_validator("points")
    @classmethod
    def distinct_points(cls, points: tuple[Point, Point]) -> tuple[Point, Point]:
        """Reject a line whose ends coincide.

        Args:
            points: The two ends.

        Returns:
            The ends.

        Raises:
            ValueError: The ends are the same point.
        """
        if abs(points[0][0] - points[1][0]) + abs(points[0][1] - points[1][1]) < 0.01:
            raise ValueError("A line needs two distinct points")
        return points


class RulesUpdate(BaseModel):
    """Every zone and line of a view, replacing the stored ones.

    Attributes:
        zones: The zones.
        lines: The lines.
    """

    zones: list[ZoneInput] = Field(default_factory=list, max_length=20)
    lines: list[LineInput] = Field(default_factory=list, max_length=20)


class ZoneRead(BaseModel):
    """A stored zone.

    Attributes:
        uuid: Zone id.
        name: Display name.
        polygon: Vertices.
        whole_view: Covers the whole picture.
        labels: Labels and label groups.
        min_dwell: Seconds before an intrusion.
        loiter_seconds: Seconds before loitering, 0 for off.
        crowd_count: Crowd size, 0 for off.
        schedule: When the zone produces events.
        alert: Alert policy.
        enabled: Whether the zone produces events.
        reference: Snapshot the zone was drawn on.
        suspended: True while a moving lens no longer shows that scene.
        left_seconds: Seconds before a carried object counts as left, 0 for off.
        taken_seconds: Seconds of presence before a disappearance counts as taken, 0 for off.
        object_labels: Labels watched for left and taken.
        background: Also finds unclassed objects by comparing with the empty scene.
        animals: What dogs, cats and birds do in the zone.
    """

    uuid: UUID
    name: str
    polygon: list[list[float]]
    whole_view: bool
    labels: list[str]
    min_dwell: float
    loiter_seconds: float
    crowd_count: int
    schedule: list[dict]
    alert: dict
    enabled: bool
    reference: str | None
    suspended: bool
    left_seconds: float = 0.0
    taken_seconds: float = 0.0
    object_labels: list[str] = []
    background: bool = False
    animals: AnimalMode = AnimalMode.RECORD


class LineRead(BaseModel):
    """A stored line.

    Attributes:
        uuid: Line id.
        name: Display name.
        points: Start and end point.
        labels: Labels and label groups.
        direction: Crossings that produce events.
        schedule: When the line produces events.
        alert: Alert policy.
        enabled: Whether the line produces events.
        reference: Snapshot the line was drawn on.
        suspended: True while a moving lens no longer shows that scene.
        animals: What dogs, cats and birds crossing the line do.
    """

    uuid: UUID
    name: str
    points: list[list[float]]
    labels: list[str]
    direction: LineDirection
    schedule: list[dict]
    alert: dict
    enabled: bool
    reference: str | None
    suspended: bool
    animals: AnimalMode = AnimalMode.RECORD
