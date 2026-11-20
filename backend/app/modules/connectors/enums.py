"""Enumerations of the connectors module."""

from enum import StrEnum

__all__ = ["ConnectorMode", "DeviceGrantError", "FoundBy", "PairingStatus"]

DEVICE_GRANT = "urn:ietf:params:oauth:grant-type:device_code"


class ConnectorMode(StrEnum):
    """How central reaches a connector: at an address on its network or a public one, or through the tunnel."""

    DIRECT = "direct"
    TUNNEL = "tunnel"


class PairingStatus(StrEnum):
    """State of a pairing request."""

    PENDING = "pending"
    CLAIMED = "claimed"
    DELIVERED = "delivered"
    EXPIRED = "expired"


class DeviceGrantError(StrEnum):
    """Error codes of the RFC 8628 token endpoint."""

    PENDING = "authorization_pending"
    SLOW_DOWN = "slow_down"
    EXPIRED = "expired_token"
    DENIED = "access_denied"
    INVALID_GRANT = "invalid_grant"
    UNSUPPORTED = "unsupported_grant_type"


class FoundBy(StrEnum):
    """How a connector found a camera."""

    WSD = "wsd"
    SWEEP = "sweep"
    BOTH = "both"
