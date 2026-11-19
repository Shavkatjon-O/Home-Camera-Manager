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
    text = " ".join((value or "").split())
    return text[:DEVICE_NAME_MAX].strip() or DEFAULT_DEVICE_NAME


class PairingCreate(BaseModel):
    device_name: str = Field(default=DEFAULT_DEVICE_NAME, max_length=DEVICE_NAME_INPUT_MAX)

    @field_validator("device_name", mode="after")
    @classmethod
    def normalize_name(cls, value: str) -> str:
        return clean_device_name(value)


class PairingCreated(BaseModel):
    id: UUID
    code: str
    expires_at: datetime


class PairingStatus(BaseModel):
    status: PairingState
    token: str | None = None


class PairingApprove(BaseModel):
    code: str = Field(pattern=CODE_PATTERN)

    @field_validator("code", mode="before")
    @classmethod
    def strip_code(cls, value):
        return "".join(value.split()) if isinstance(value, str) else value
