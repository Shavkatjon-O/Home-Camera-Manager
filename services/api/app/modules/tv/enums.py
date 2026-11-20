"""Enumerations of the TV module."""

from enum import StrEnum


class PairingState(StrEnum):
    """Progress of a TV pairing request, as reported to the TV."""

    PENDING = "pending"
    APPROVED = "approved"
    EXPIRED = "expired"
