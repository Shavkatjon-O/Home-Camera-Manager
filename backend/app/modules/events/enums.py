"""Enumerations of the events module."""

from enum import StrEnum


class EventKind(StrEnum):
    """Kinds of events from the cameras and from the analytics service."""

    MOTION = "motion"
    PERSON = "person"
    VEHICLE = "vehicle"
    TAMPER = "tamper"
    STORAGE = "storage"
    REBOOT = "reboot"
    INTRUSION = "intrusion"
    LINE_CROSSING = "line_crossing"
    LOITERING = "loitering"
    CROWD = "crowd"
    FACE_KNOWN = "face_known"
    FACE_UNKNOWN = "face_unknown"
    ANIMAL = "animal"
    OBJECT_LEFT = "object_left"
    OBJECT_TAKEN = "object_taken"
    FALL = "fall"


class EventSource(StrEnum):
    """Where an event came from."""

    CAMERA = "camera"
    ANALYTICS = "analytics"


class SourceMode(StrEnum):
    """How the events engine receives a camera's notifications."""

    PULLPOINT = "pullpoint"
    POLLING = "polling"
    NONE = "none"


class SourceState(StrEnum):
    """Connection state of a camera's event subscription."""

    CONNECTING = "connecting"
    LIVE = "live"
    RECONNECTING = "reconnecting"
    UNSUPPORTED = "unsupported"
    DISABLED = "disabled"
