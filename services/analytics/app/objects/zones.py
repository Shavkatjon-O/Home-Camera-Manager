"""Zone settings for objects left and taken, read from a zone's configuration next to its other rules."""

from __future__ import annotations

from dataclasses import dataclass

from app.rules.model import Zone, expand_labels

DEFAULT_LABELS = frozenset({"backpack", "handbag", "suitcase", "bicycle", "motorcycle"})
DEFAULT_TAKEN_GRACE = 60.0


@dataclass(frozen=True)
class ObjectZone:
    """A zone with its object rules.

    Attributes:
        zone: The zone with its polygon, schedule and alert policy.
        left_seconds: Seconds an object that arrived must stay still inside before it is left, 0 turns left off.
        taken_seconds: Seconds an object must have been present before its disappearance counts as taken, 0 turns
            taken off.
        taken_grace: Seconds an object must stay missing, while frames keep arriving, before it is taken.
        labels: Labels watched; cars and other vehicles only when listed.
        background: Also look for unclassed objects by background difference.
    """

    zone: Zone
    left_seconds: float = 0.0
    taken_seconds: float = 0.0
    taken_grace: float = DEFAULT_TAKEN_GRACE
    labels: frozenset[str] = DEFAULT_LABELS
    background: bool = False

    @property
    def id(self) -> str:
        """str: Id of the zone."""
        return self.zone.id

    @property
    def active(self) -> bool:
        """bool: True when the zone watches objects at all."""
        return self.zone.enabled and not self.zone.suspended and (self.left_seconds > 0 or self.taken_seconds > 0)

    @classmethod
    def from_dict(cls, data: dict) -> ObjectZone:
        """Build the object rules of a zone from its configuration.

        Args:
            data: The zone mapping as the backend sends it, with left_seconds, taken_seconds, taken_grace,
                object_labels and background next to the usual zone keys.

        Returns:
            The object zone.
        """
        labels = expand_labels(data.get("object_labels")) or DEFAULT_LABELS
        return cls(
            zone=Zone.from_dict(data),
            left_seconds=float(data.get("left_seconds") or 0.0),
            taken_seconds=float(data.get("taken_seconds") or 0.0),
            taken_grace=float(data.get("taken_grace") or DEFAULT_TAKEN_GRACE),
            labels=labels,
            background=bool(data.get("background", False)),
        )


def object_zones(zones: list[dict] | None) -> list[ObjectZone]:
    """Return the zones of a view that watch objects.

    Args:
        zones: The view's zone mappings.

    Returns:
        Object zones that are enabled and have left or taken on.
    """
    result = []
    for data in zones or []:
        item = ObjectZone.from_dict(data)
        if item.active:
            result.append(item)
    return result
