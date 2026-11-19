"""Enumerations of the health module."""

from enum import StrEnum


class DeviceKind(StrEnum):
    """Kinds of network device."""

    ROUTER = "router"
    ACCESS_POINT = "access_point"
    REPEATER = "repeater"
    SWITCH = "switch"
    OTHER = "other"


class LinkKind(StrEnum):
    """Ways a device or camera connects to the device it hangs off."""

    CABLE = "cable"
    WIFI_24 = "wifi_24"
    WIFI_5 = "wifi_5"


class TargetKind(StrEnum):
    """Kinds of probed target."""

    DEVICE = "device"
    CAMERA = "camera"


class TargetStatus(StrEnum):
    """Current state of a target.

    Attributes:
        UP: The latest sample succeeded.
        DEGRADED: The latest sample failed but no outage is open.
        DOWN: An outage is open.
        UNKNOWN: There is no recent sample.
        DISABLED: The target is switched off and not probed.
    """

    UP = "up"
    DEGRADED = "degraded"
    DOWN = "down"
    UNKNOWN = "unknown"
    DISABLED = "disabled"


class HealthRange(StrEnum):
    """Time ranges the overview can cover: one hour, 24 hours and seven days."""

    HOUR = "1h"
    DAY = "24h"
    WEEK = "7d"
