"""Follow settings of one view, read from the view configuration's follow key."""

from __future__ import annotations

from dataclasses import dataclass, field

DEFAULT_LABELS = frozenset({"person"})


def pair(value, default: tuple[float, float]) -> tuple[float, float]:
    """Read a pair of numbers, or one number used for both.

    Args:
        value: A list of two numbers, one number, or None.
        default: Pair used when the value is None.

    Returns:
        The pair.
    """
    if value is None:
        return default
    if isinstance(value, (int, float)):
        return (float(value), float(value))
    first, second = value
    return (float(first), float(second))


@dataclass(frozen=True)
class FollowSettings:
    """How a view follows a person.

    Attributes:
        enabled: Whether the view moves its lens to follow; off by default.
        dead_zone: Half width of the centre area in x and y, in normalized view units, where the lens stays still.
        centre: Point of the view the target's box centre is kept at.
        gain: Speed per unit of centring error.
        min_speed: Smallest speed sent, because slower ContinuousMove commands do not move the motors.
        max_speed: Largest speed sent.
        smoothing: Weight of the new speed against the previous one, from 0 to 1.
        interval: Smallest time between two move commands unless the direction flips.
        refresh: Time after which an unchanged move is sent again, so cameras with move timeouts keep moving.
        lost_seconds: Time without the target after which the lens stops.
        idle_seconds: Time without any target after which the lens returns to where follow started.
        reacquire_seconds: Time after losing the target during which a new track near its last place takes over.
        reacquire_distance: Largest distance of such a new track from the target's last place.
        invert_pan: Flips the pan direction for cameras that turn the other way.
        invert_tilt: Flips the tilt direction.
        labels: Labels that can be followed.
    """

    enabled: bool = False
    dead_zone: tuple[float, float] = (0.08, 0.1)
    centre: tuple[float, float] = (0.5, 0.45)
    gain: float = 1.2
    min_speed: float = 0.15
    max_speed: float = 0.5
    smoothing: float = 0.6
    interval: float = 0.3
    refresh: float = 1.0
    lost_seconds: float = 1.0
    idle_seconds: float = 30.0
    reacquire_seconds: float = 2.0
    reacquire_distance: float = 0.15
    invert_pan: bool = False
    invert_tilt: bool = False
    labels: frozenset[str] = field(default_factory=lambda: DEFAULT_LABELS)

    @classmethod
    def from_dict(cls, data: dict | None) -> FollowSettings:
        """Build the settings from the follow mapping, keeping defaults for missing keys.

        Args:
            data: The follow mapping, or None for the defaults.

        Returns:
            The settings.
        """
        data = data or {}
        defaults = cls()
        numbers = {}
        for name in (
            "gain",
            "min_speed",
            "max_speed",
            "smoothing",
            "interval",
            "refresh",
            "lost_seconds",
            "idle_seconds",
            "reacquire_seconds",
            "reacquire_distance",
        ):
            if data.get(name) is not None:
                numbers[name] = float(data[name])
        labels = data.get("labels")
        return cls(
            enabled=bool(data.get("enabled", False)),
            dead_zone=pair(data.get("dead_zone"), defaults.dead_zone),
            centre=pair(data.get("centre"), defaults.centre),
            invert_pan=bool(data.get("invert_pan", False)),
            invert_tilt=bool(data.get("invert_tilt", False)),
            labels=frozenset(str(label) for label in labels) if labels else DEFAULT_LABELS,
            **numbers,
        )

    @classmethod
    def from_view(cls, raw: dict | None) -> FollowSettings:
        """Build the settings from a view's configuration.

        Args:
            raw: The view configuration as the backend sent it.

        Returns:
            The settings of its follow key.
        """
        return cls.from_dict((raw or {}).get("follow"))
