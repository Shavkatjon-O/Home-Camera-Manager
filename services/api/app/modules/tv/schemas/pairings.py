"""Schemas of the TV pairing flow."""

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field, field_validator

from app.modules.tv.enums import PairingState

__all__ = [
    "DEFAULT_DEVICE_NAME",
    "PairingApprove",
    "PairingCreate",
    "PairingCreated",
    "PairingStatus",
    "clean_device_name",
]

DEFAULT_DEVICE_NAME = "TV"
DEVICE_NAME_MAX = 100
DEVICE_NAME_INPUT_MAX = 500

CODE_PATTERN = r"^\d{6}$"


def clean_device_name(value: str | None) -> str:
    """Normalize a device name sent by a TV.

    Collapses runs of whitespace, cuts the name to the stored length and falls back to the default name
    when nothing is left.

    Args:
        value: Name as sent, if any.

    Returns:
        Name that fits the database column, never empty.
    """
    text = " ".join((value or "").split())
    return text[:DEVICE_NAME_MAX].strip() or DEFAULT_DEVICE_NAME


class PairingCreate(BaseModel):
    """Request a TV sends to open a pairing.

    Attributes:
        device_name: Name the TV asks to be paired under.
    """

    device_name: str = Field(default=DEFAULT_DEVICE_NAME, max_length=DEVICE_NAME_INPUT_MAX)

    @field_validator("device_name", mode="after")
    @classmethod
    def normalize_name(cls, value: str) -> str:
        """Clean the device name.

        Args:
            value: Name as sent.

        Returns:
            Normalized name.
        """
        return clean_device_name(value)


class PairingCreated(BaseModel):
    """Response to an opened pairing.

    Attributes:
        id: Public id the TV polls for the pairing status.
        code: Six-digit code to show on the TV.
        expires_at: Time after which the code stops working.
    """

    id: UUID
    code: str
    expires_at: datetime


class PairingStatus(BaseModel):
    """Status of a pairing as seen by the TV.

    Attributes:
        status: Progress of the pairing.
        token: Device token, present only in the response that hands it over.
    """

    status: PairingState
    token: str | None = None


class PairingApprove(BaseModel):
    """Request a signed-in user sends to approve the TV showing a code.

    Attributes:
        code: Six-digit code shown on the TV.
    """

    code: str = Field(pattern=CODE_PATTERN)

    @field_validator("code", mode="before")
    @classmethod
    def strip_code(cls, value):
        """Remove whitespace from the code before it is checked.

        Args:
            value: Code as sent.

        Returns:
            The code without whitespace, or the value unchanged when it is not a string.
        """
        return "".join(value.split()) if isinstance(value, str) else value
