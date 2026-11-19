from enum import StrEnum


class EventKind(StrEnum):
    MOTION = "motion"
    PERSON = "person"
    VEHICLE = "vehicle"
    TAMPER = "tamper"
    STORAGE = "storage"
    REBOOT = "reboot"


class SourceMode(StrEnum):
    PULLPOINT = "pullpoint"
    POLLING = "polling"
    NONE = "none"


class SourceState(StrEnum):
    CONNECTING = "connecting"
    LIVE = "live"
    RECONNECTING = "reconnecting"
    UNSUPPORTED = "unsupported"
    DISABLED = "disabled"
