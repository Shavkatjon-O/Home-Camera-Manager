"""Enumerations of the analytics module."""

from enum import StrEnum


class ArmMode(StrEnum):
    """Global arm mode that decides which analytics events raise an alert."""

    DISARMED = "disarmed"
    HOME = "home"
    AWAY = "away"
    SCHEDULE = "schedule"


class Profile(StrEnum):
    """Pipeline profile of an analytics view."""

    PERIMETER = "perimeter"
    VEHICLE = "vehicle"
    IDENTITY = "identity"
    TAMPER = "tamper"


class LineDirection(StrEnum):
    """Crossings of a line that produce events."""

    IN = "in"
    OUT = "out"
    BOTH = "both"


class AnimalMode(StrEnum):
    """What dogs, cats and birds do in a zone or on a line."""

    INCLUDE = "include"
    RECORD = "record"
    EXCLUDE = "exclude"


class AlertMode(StrEnum):
    """When the events of a zone or line raise an alert, below the arm mode."""

    OFF = "off"
    ALWAYS = "always"
    SCHEDULE = "schedule"


LABELS = (
    "person",
    "bicycle",
    "car",
    "motorcycle",
    "bus",
    "truck",
    "bird",
    "cat",
    "dog",
    "backpack",
    "handbag",
    "suitcase",
)
LABEL_GROUPS = ("vehicle", "animal")
