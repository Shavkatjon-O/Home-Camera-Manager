from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field, field_validator

from app.modules.cameras.enums import CameraBrand
from app.modules.cameras.schemas import clean_host, clean_text

__all__ = [
    "InspectProfile",
    "InspectRequest",
    "InspectResult",
    "ScanItem",
    "ScanRequest",
    "ScanResult",
]


class ScanRequest(BaseModel):
    subnet: str | None = Field(default=None, max_length=43)

    @field_validator("subnet", mode="before")
    @classmethod
    def strip_subnet(cls, value):
        return clean_text(value) if isinstance(value, str) else value


class ScanItem(BaseModel):
    host: str
    open_ports: list[int]
    brand: CameraBrand | None
    manufacturer: str | None
    model: str | None
    onvif_port: int | None
    camera_uuid: UUID | None


class ScanResult(BaseModel):
    subnet: str
    scanned_at: datetime
    duration_ms: int
    items: list[ScanItem]


class InspectRequest(BaseModel):
    host: str = Field(min_length=1, max_length=255)
    onvif_port: int = Field(ge=1, le=65535)
    username: str | None = Field(default=None, max_length=100)
    password: str | None = Field(default=None, max_length=256)

    @field_validator("host", mode="before")
    @classmethod
    def normalize_host(cls, value):
        return clean_host(value) if isinstance(value, str) else value

    @field_validator("username", mode="before")
    @classmethod
    def strip_username(cls, value):
        return clean_text(value) if isinstance(value, str) else value


class InspectProfile(BaseModel):
    token: str
    name: str
    encoding: str | None
    width: int | None
    height: int | None
    stream_uri: str | None


class InspectResult(BaseModel):
    manufacturer: str | None
    model: str | None
    firmware: str | None
    profiles: list[InspectProfile]
    ptz: bool
