"""Hourly ledger of line crossings.

Every crossing counts into the bucket of the hour it happened in, per view, line, direction and label. A report
carries the absolute total of each bucket that changed since the previous report, together with the ledger's boot
id. The backend stores one row per boot and bucket and replaces its count on every report, so a lost report is
repaired by the next one and a repeated report never counts twice; totals over boots add up because each boot
counts only its own crossings.
"""

from __future__ import annotations

import uuid
from dataclasses import dataclass, field

HOUR_SECONDS = 3600
RETENTION_SECONDS = 48 * 3600

DIRECTIONS = ("in", "out")


def hour_start(at: float) -> int:
    """Return the start of the UTC hour that contains a time.

    Args:
        at: Seconds since the epoch.

    Returns:
        Seconds since the epoch at the start of that hour.
    """
    return int(at // HOUR_SECONDS) * HOUR_SECONDS


BucketKey = tuple[str, str, int, str, str]


@dataclass
class CountLedger:
    """Crossing counts by hour since the service started.

    Attributes:
        retention: Seconds after which a reported bucket is dropped.
        boot: Identifier of this ledger, new on every start of the service.
        counts: Count per view, line, hour, direction and label.
        changed: Buckets changed since the previous report.
    """

    retention: float = RETENTION_SECONDS
    boot: str = field(default_factory=lambda: str(uuid.uuid4()))
    counts: dict[BucketKey, int] = field(default_factory=dict)
    changed: set[BucketKey] = field(default_factory=set)

    def add(self, view: str, line: str, direction: str, label: str, at: float, count: int = 1) -> None:
        """Count crossings.

        Args:
            view: View id.
            line: Line id.
            direction: in or out.
            label: Canonical label of the object.
            at: Time of the crossing, seconds since the epoch.
            count: Number of crossings to add.

        Raises:
            ValueError: If the direction is neither in nor out.
        """
        if direction not in DIRECTIONS:
            raise ValueError(f"Direction must be in or out, not {direction!r}")
        key = (view, line, hour_start(at), direction, label)
        self.counts[key] = self.counts.get(key, 0) + count
        self.changed.add(key)

    def report(self, now: float) -> dict | None:
        """Return the buckets changed since the previous report and forget old ones.

        Args:
            now: Current time.

        Returns:
            The boot id and the changed buckets with their absolute counts, or None when nothing changed.
        """
        items = []
        for key in sorted(self.changed, key=lambda item: (item[2], item[0], item[1], item[3], item[4])):
            view, line, hour, direction, label = key
            items.append(
                {
                    "view": view,
                    "line": line,
                    "hour": hour,
                    "direction": direction,
                    "label": label,
                    "count": self.counts[key],
                }
            )
        self.changed.clear()
        cutoff = hour_start(now) - self.retention
        self.counts = {key: value for key, value in self.counts.items() if key[2] >= cutoff}
        if not items:
            return None
        return {"boot": self.boot, "at": now, "buckets": items}

    def restore(self, report: dict) -> None:
        """Mark the buckets of a report that could not be delivered as changed again.

        Args:
            report: A report this ledger returned.
        """
        for item in report.get("buckets", []):
            key = (item["view"], item["line"], item["hour"], item["direction"], item["label"])
            if key in self.counts:
                self.changed.add(key)

    def totals(self, view: str, line: str) -> dict[str, dict[str, int]]:
        """Return the counts of a line since the service started.

        Args:
            view: View id.
            line: Line id.

        Returns:
            Direction to label to crossings.
        """
        result: dict[str, dict[str, int]] = {direction: {} for direction in DIRECTIONS}
        for (key_view, key_line, hour, direction, label), value in self.counts.items():
            if key_view == view and key_line == line:
                result[direction][label] = result[direction].get(label, 0) + value
        return result
