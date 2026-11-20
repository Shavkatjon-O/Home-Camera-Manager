"""Schemas of line counts and area occupancy."""

from datetime import datetime
from typing import Literal
from uuid import UUID

from pydantic import BaseModel, Field, field_validator

__all__ = [
    "AreaCreate",
    "AreaLineInput",
    "AreaLineRead",
    "AreaList",
    "AreaRead",
    "AreaReset",
    "AreaUpdate",
    "CountBucketIn",
    "CountBucketRead",
    "CountLineRead",
    "CountReportIn",
    "CountTotalRead",
    "CountsRead",
]

CLOCK = r"^([01][0-9]|2[0-3]):[0-5][0-9]$"
LABEL_MAX = 20


class CountBucketIn(BaseModel):
    """Crossings of one minute as the analytics service reports them.

    Attributes:
        view: View id.
        line: Line id.
        start: Start of the minute, seconds since the epoch.
        direction: in or out.
        label: Object label.
        count: Absolute total of the minute since the service started.
    """

    view: UUID
    line: UUID
    start: int
    direction: Literal["in", "out"]
    label: str = Field(max_length=LABEL_MAX)
    count: int = Field(ge=0)


class CountReportIn(BaseModel):
    """A report of changed minutes from one run of the analytics service.

    Attributes:
        boot: Identifier of the analytics service run.
        at: Time of the report, seconds since the epoch.
        buckets: The changed minutes.
    """

    boot: str = Field(min_length=1, max_length=36)
    at: float
    buckets: list[CountBucketIn] = Field(default_factory=list, max_length=5000)


class CountLineRead(BaseModel):
    """A counting line.

    Attributes:
        uuid: Line id.
        name: Line name.
        view_uuid: View the line is drawn on.
        view_name: Name of that view.
        camera_uuid: Camera of the view.
        camera_name: Name of that camera.
        direction: Crossings that produce events: in, out or both.
        enabled: Whether the line is on.
    """

    uuid: UUID
    name: str
    view_uuid: UUID
    view_name: str
    camera_uuid: UUID
    camera_name: str | None
    direction: str
    enabled: bool


class CountBucketRead(BaseModel):
    """Crossings of a line in one hour or day for one label.

    Attributes:
        line_uuid: The line.
        at: Local start of the hour or day.
        label: Object label.
        in_: Crossings in, sent as in.
        out: Crossings out.
    """

    model_config = {"populate_by_name": True}

    line_uuid: UUID
    at: datetime
    label: str
    in_: int = Field(alias="in", serialization_alias="in")
    out: int


class CountTotalRead(BaseModel):
    """Crossings of a line over the whole range.

    Attributes:
        line_uuid: The line.
        in_: Crossings in, sent as in.
        out: Crossings out.
        labels: Label to crossings in and out.
    """

    model_config = {"populate_by_name": True}

    line_uuid: UUID
    in_: int = Field(alias="in", serialization_alias="in")
    out: int
    labels: dict[str, dict[str, int]]


class CountsRead(BaseModel):
    """Line counts over a range.

    Attributes:
        start: Start of the range, inclusive.
        end: End of the range, exclusive.
        bucket: hour or day.
        timezone: Time zone the buckets are local to.
        lines: Every counting line.
        buckets: Crossings per line, bucket and label, only where there were any.
        totals: Crossings per line over the range.
    """

    start: datetime
    end: datetime
    bucket: Literal["hour", "day"]
    timezone: str
    lines: list[CountLineRead]
    buckets: list[CountBucketRead]
    totals: list[CountTotalRead]


class AreaLineInput(BaseModel):
    """A line that bounds an area.

    Attributes:
        line_uuid: The line.
        entering: The crossing direction that enters the area.
    """

    line_uuid: UUID
    entering: Literal["in", "out"]


def check_labels(value: list[str]) -> list[str]:
    """Check a label list for length and duplicates.

    Args:
        value: The labels.

    Returns:
        The labels without duplicates, in order.

    Raises:
        ValueError: If a label is too long.
    """
    result = []
    for label in value:
        if not label or len(label) > LABEL_MAX:
            raise ValueError("Labels must be 1 to 20 characters")
        if label not in result:
            result.append(label)
    return result


class AreaCreate(BaseModel):
    """A new area.

    Attributes:
        name: Display name.
        lines: Bounding lines, at least one.
        labels: Labels counted, empty for every label.
        reset_at: Daily reset time as HH:MM, or None for never.
    """

    name: str = Field(min_length=1, max_length=60)
    lines: list[AreaLineInput] = Field(min_length=1, max_length=20)
    labels: list[str] = Field(default_factory=list, max_length=20)
    reset_at: str | None = Field(None, pattern=CLOCK)

    @field_validator("labels")
    @classmethod
    def unique_labels(cls, value: list[str]) -> list[str]:
        """Check the labels.

        Args:
            value: The labels.

        Returns:
            The labels without duplicates.
        """
        return check_labels(value)


class AreaUpdate(BaseModel):
    """Changes to an area; fields left out keep their value.

    Attributes:
        name: Display name.
        lines: Bounding lines.
        labels: Labels counted.
        reset_at: Daily reset time as HH:MM, or None for never.
    """

    name: str | None = Field(None, min_length=1, max_length=60)
    lines: list[AreaLineInput] | None = Field(None, min_length=1, max_length=20)
    labels: list[str] | None = Field(None, max_length=20)
    reset_at: str | None = Field(None, pattern=CLOCK)

    @field_validator("labels")
    @classmethod
    def unique_labels(cls, value: list[str] | None) -> list[str] | None:
        """Check the labels.

        Args:
            value: The labels, or None.

        Returns:
            The labels without duplicates, or None.
        """
        return None if value is None else check_labels(value)


class AreaReset(BaseModel):
    """The occupancy to count on from now.

    Attributes:
        occupancy: Objects in the area now.
    """

    occupancy: int = Field(0, ge=0, le=1000)


class AreaLineRead(BaseModel):
    """A bounding line as the API returns it.

    Attributes:
        line_uuid: The line.
        line_name: Its name, None when the line was deleted.
        view_name: Name of its view, None when the line was deleted.
        entering: The crossing direction that enters the area.
    """

    line_uuid: UUID
    line_name: str | None
    view_name: str | None
    entering: str


class AreaRead(BaseModel):
    """An area with its current occupancy.

    Attributes:
        uuid: Area id.
        name: Display name.
        occupancy: Objects in the area now, never below zero.
        entered: Crossings into the area since the count began.
        exited: Crossings out of the area since then.
        since: When the current count began.
        reset_at: Daily reset time, or None.
        labels: Labels counted, empty for every label.
        lines: Bounding lines.
        updated_at: When the area last changed.
    """

    uuid: UUID
    name: str
    occupancy: int
    entered: int
    exited: int
    since: datetime
    reset_at: str | None
    labels: list[str]
    lines: list[AreaLineRead]
    updated_at: datetime


class AreaList(BaseModel):
    """Every area.

    Attributes:
        items: The areas in creation order.
    """

    items: list[AreaRead]
