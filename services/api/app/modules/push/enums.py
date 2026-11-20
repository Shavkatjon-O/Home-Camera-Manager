"""Enumerations of the push module."""

from enum import StrEnum

__all__ = ["PushProvider"]


class PushProvider(StrEnum):
    """Push services the backend delivers through."""

    FCM = "fcm"
    NTFY = "ntfy"
