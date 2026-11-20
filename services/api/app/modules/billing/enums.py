"""Enumerations of the billing module."""

from enum import StrEnum

__all__ = ["Feature", "Limit", "UsageMetric"]


class Feature(StrEnum):
    """Features a plan turns on."""

    FACES = "faces"
    PLATES = "plates"
    APPEARANCE_SEARCH = "appearance_search"
    JOURNEYS = "journeys"
    FALLS = "falls"
    OBJECTS = "objects"
    FOLLOW = "follow"
    TELEGRAM_ALERTS = "telegram_alerts"


class Limit(StrEnum):
    """Quantities a plan caps; a missing or null limit is unlimited."""

    SITES = "sites"
    CAMERAS = "cameras"
    MEMBERS = "members"
    EVENT_RETENTION_DAYS = "event_retention_days"
    CLIP_RETENTION_DAYS = "clip_retention_days"


class UsageMetric(StrEnum):
    """What usage metering counts per site and hour."""

    CAMERA_HOURS = "camera_hours"
    VIEW_HOURS = "view_hours"
    EVENTS = "events"
    CLIP_BYTES = "clip_bytes"
    NOTIFICATIONS = "notifications"
