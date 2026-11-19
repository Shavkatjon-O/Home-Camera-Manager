from enum import StrEnum


class PairingState(StrEnum):
    PENDING = "pending"
    APPROVED = "approved"
    EXPIRED = "expired"
