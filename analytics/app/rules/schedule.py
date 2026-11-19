"""Weekly schedules that decide when a rule is active or alerts."""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, time, timedelta

ALL_DAYS = frozenset(range(7))


def parse_clock(value: str) -> time:
    """Parse a 24 hour clock time written as HH:MM.

    Args:
        value: The time, such as 23:00.

    Returns:
        The parsed time.

    Raises:
        ValueError: If the value is not a valid HH:MM time.
    """
    hours, minutes = value.strip().split(":")
    return time(int(hours), int(minutes))


@dataclass(frozen=True)
class Window:
    """One weekly time window.

    A window whose end is not after its start runs past midnight into the next day, and its days name the day it
    starts on, so Friday 23:00 to 06:00 covers Saturday until 06:00.

    Attributes:
        start: Start time of day.
        end: End time of day.
        days: Weekdays the window starts on, Monday is 0.
    """

    start: time
    end: time
    days: frozenset[int] = ALL_DAYS

    @classmethod
    def from_dict(cls, data: dict) -> Window:
        """Build a window from its configuration.

        Args:
            data: Mapping with start and end as HH:MM and optional days as weekday numbers.

        Returns:
            The window.
        """
        days = data.get("days")
        return cls(
            start=parse_clock(data["start"]),
            end=parse_clock(data["end"]),
            days=frozenset(int(day) for day in days) if days else ALL_DAYS,
        )

    def contains(self, moment: datetime) -> bool:
        """Tell whether a local time falls inside the window.

        Args:
            moment: Local wall clock time.

        Returns:
            True when the window covers the moment.
        """
        clock = moment.time()
        if self.start < self.end:
            return moment.weekday() in self.days and self.start <= clock < self.end
        if clock >= self.start:
            return moment.weekday() in self.days
        if clock < self.end:
            return (moment - timedelta(days=1)).weekday() in self.days
        return False


@dataclass(frozen=True)
class Schedule:
    """A set of weekly windows; an empty schedule is always active.

    Attributes:
        windows: The windows; the schedule is active inside any of them.
    """

    windows: tuple[Window, ...] = field(default_factory=tuple)

    @classmethod
    def from_list(cls, data: list[dict] | None) -> Schedule:
        """Build a schedule from a list of window configurations.

        Args:
            data: Window mappings, or None for an always active schedule.

        Returns:
            The schedule.
        """
        return cls(tuple(Window.from_dict(item) for item in data or []))

    @property
    def always(self) -> bool:
        """bool: True when the schedule has no windows and is therefore always active."""
        return not self.windows

    def active(self, moment: datetime) -> bool:
        """Tell whether the schedule is active at a local time.

        Args:
            moment: Local wall clock time.

        Returns:
            True when the schedule has no windows or any window contains the moment.
        """
        return self.always or any(window.contains(moment) for window in self.windows)
