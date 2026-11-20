"""Enumerations of the alerting module."""

from enum import StrEnum

__all__ = ["PushProvider"]


class PushProvider(StrEnum):
    """Push services the backend delivers through."""

    FCM = "fcm"
    NTFY = "ntfy"
