"""Enumerations of the operations module."""

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


class WallMaterial(StrEnum):
    """Materials a wall can be made of, which set how much it weakens the signal."""

    DRYWALL = "drywall"
    WOOD = "wood"
    GLASS = "glass"
    BRICK = "brick"
    THICK_BRICK = "thick_brick"
    CONCRETE = "concrete"
    REINFORCED_CONCRETE = "reinforced_concrete"
    METAL = "metal"


class AccessPointPreset(StrEnum):
    """Router models a plan can place, or a generic router."""

    ARCHER_C64 = "archer_c64"
    ARCHER_C54 = "archer_c54"
    REYEE_EW300N = "reyee_ew300n"
    GENERIC = "generic"


class Band(StrEnum):
    """Wi-Fi frequency bands, valued by their frequency in GHz."""

    BAND_24 = "2.4"
    BAND_5 = "5"


class AuditAction(StrEnum):
    """Actions the audit log records."""

    SIGN_IN = "sign_in"
    SIGN_OUT = "sign_out"
    ACCOUNT_DELETE = "account_delete"
    PASSWORD_CHANGE = "password_change"

    ORGANISATION_CREATE = "organisation_create"
    ORGANISATION_UPDATE = "organisation_update"
    ORGANISATION_DELETE = "organisation_delete"
    OWNERSHIP_TRANSFER = "ownership_transfer"
    SITE_CREATE = "site_create"
    SITE_UPDATE = "site_update"
    SITE_DELETE = "site_delete"
    MEMBER_UPDATE = "member_update"
    MEMBER_REMOVE = "member_remove"
    INVITATION_CREATE = "invitation_create"
    INVITATION_REVOKE = "invitation_revoke"
    INVITATION_ACCEPT = "invitation_accept"

    CAMERA_CREATE = "camera_create"
    CAMERA_UPDATE = "camera_update"
    CAMERA_DELETE = "camera_delete"
    DEVICE_PAIR = "device_pair"
    CONNECTOR_CLAIM = "connector_claim"
    CONNECTOR_UPDATE = "connector_update"
    CONNECTOR_REVOKE = "connector_revoke"
    CAMERA_CONTROL = "camera_control"

    RULES_UPDATE = "rules_update"
    ARM_MODE_CHANGE = "arm_mode_change"
    ALERT_CHANNEL_LINK = "alert_channel_link"
    ALERT_CHANNEL_REMOVE = "alert_channel_remove"

    LIVE_VIEW = "live_view"
    CLIP_VIEW = "clip_view"
    EXPORT = "export"

    FACE_ENROL = "face_enrol"
    FACE_DELETE = "face_delete"
    FACES_CONSENT = "faces_consent"

    ADMIN_PLAN_CHANGE = "admin_plan_change"
    ADMIN_SUSPEND = "admin_suspend"
    ADMIN_RESTORE = "admin_restore"
