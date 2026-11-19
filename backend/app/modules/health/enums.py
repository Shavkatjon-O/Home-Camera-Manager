from enum import StrEnum


class DeviceKind(StrEnum):
    ROUTER = "router"
    ACCESS_POINT = "access_point"
    REPEATER = "repeater"
    SWITCH = "switch"
    OTHER = "other"


class LinkKind(StrEnum):
    CABLE = "cable"
    WIFI_24 = "wifi_24"
    WIFI_5 = "wifi_5"


class TargetKind(StrEnum):
    DEVICE = "device"
    CAMERA = "camera"


class TargetStatus(StrEnum):
    UP = "up"
    DEGRADED = "degraded"
    DOWN = "down"
    UNKNOWN = "unknown"
    DISABLED = "disabled"


class HealthRange(StrEnum):
    HOUR = "1h"
    DAY = "24h"
    WEEK = "7d"
