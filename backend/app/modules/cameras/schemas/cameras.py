import re
from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field, field_validator, model_validator

from app.modules.cameras.enums import CameraBrand

__all__ = [
    "CameraCreate",
    "CameraList",
    "CameraOrder",
    "CameraRead",
    "CameraStatus",
    "CameraStreams",
    "CameraUpdate",
    "PtzMove",
    "clean_host",
    "clean_path",
    "clean_text",
]

HOST_PATTERN = re.compile(r"^[A-Za-z0-9._-]+$")
PATH_PATTERN = re.compile(r"^\S+$")

PORT_MIN = 1
PORT_MAX = 65535

LENSES_MIN = 1
LENSES_MAX = 4

REQUIRED_ON_UPDATE = ("name", "brand", "host", "rtsp_port", "main_path", "lenses", "ptz_enabled", "enabled")


def clean_text(value: str | None) -> str | None:
    if value is None:
        return None
    value = value.strip()
    return value or None


def clean_host(value: str | None) -> str | None:
    value = clean_text(value)
    if value is None:
        return None
    if not HOST_PATTERN.match(value):
        raise ValueError("must be an IP address or a host name")
    return value.lower()


def clean_path(value: str | None) -> str | None:
    value = clean_text(value)
    if value is None:
        return None
    if not PATH_PATTERN.match(value):
        raise ValueError("must not contain spaces")
    return value if value.startswith("/") else f"/{value}"


class CameraStatus(BaseModel):
    online: bool | None
    checked_at: datetime | None
    error: str | None


class CameraStreams(BaseModel):
    main: str
    sub: str | None


class CameraRead(BaseModel):
    uuid: UUID
    name: str
    brand: CameraBrand
    host: str
    device_host: str | None
    rtsp_port: int
    onvif_port: int | None
    username: str | None
    has_password: bool
    main_path: str
    sub_path: str | None
    lenses: int
    ptz_enabled: bool
    location: str | None
    position: int
    enabled: bool
    status: CameraStatus
    streams: CameraStreams
    created_at: datetime
    updated_at: datetime


class CameraList(BaseModel):
    items: list[CameraRead]
    total: int
    page: int
    page_size: int


class CameraFields(BaseModel):
    @field_validator("name", "username", "location", mode="before", check_fields=False)
    @classmethod
    def strip_text(cls, value):
        return clean_text(value) if isinstance(value, str) else value

    @field_validator("host", "device_host", mode="before", check_fields=False)
    @classmethod
    def normalize_host(cls, value):
        return clean_host(value) if isinstance(value, str) else value

    @field_validator("main_path", "sub_path", mode="before", check_fields=False)
    @classmethod
    def normalize_path(cls, value):
        return clean_path(value) if isinstance(value, str) else value


class CameraCreate(CameraFields):
    name: str = Field(min_length=1, max_length=100)
    brand: CameraBrand
    host: str = Field(min_length=1, max_length=255)
    device_host: str | None = Field(default=None, max_length=255)
    location: str | None = Field(default=None, max_length=100)

    rtsp_port: int | None = Field(default=None, ge=PORT_MIN, le=PORT_MAX)
    onvif_port: int | None = Field(default=None, ge=PORT_MIN, le=PORT_MAX)

    username: str | None = Field(default=None, max_length=100)
    password: str | None = Field(default=None, max_length=256)

    main_path: str | None = Field(default=None, max_length=255)
    sub_path: str | None = Field(default=None, max_length=255)
    lenses: int = Field(default=1, ge=LENSES_MIN, le=LENSES_MAX)

    ptz_enabled: bool | None = None
    enabled: bool = True


class CameraUpdate(CameraFields):
    name: str | None = Field(default=None, min_length=1, max_length=100)
    brand: CameraBrand | None = None
    host: str | None = Field(default=None, min_length=1, max_length=255)
    device_host: str | None = Field(default=None, max_length=255)
    location: str | None = Field(default=None, max_length=100)

    rtsp_port: int | None = Field(default=None, ge=PORT_MIN, le=PORT_MAX)
    onvif_port: int | None = Field(default=None, ge=PORT_MIN, le=PORT_MAX)

    username: str | None = Field(default=None, max_length=100)
    password: str | None = Field(default=None, max_length=256)

    main_path: str | None = Field(default=None, max_length=255)
    sub_path: str | None = Field(default=None, max_length=255)
    lenses: int | None = Field(default=None, ge=LENSES_MIN, le=LENSES_MAX)

    ptz_enabled: bool | None = None
    enabled: bool | None = None

    @model_validator(mode="after")
    def reject_null_required(self):
        for field in REQUIRED_ON_UPDATE:
            if field in self.model_fields_set and getattr(self, field) is None:
                raise ValueError(f"{field} cannot be empty")
        return self


class CameraOrder(BaseModel):
    uuids: list[UUID] = Field(min_length=1)

    @field_validator("uuids")
    @classmethod
    def unique_uuids(cls, value: list[UUID]) -> list[UUID]:
        if len(set(value)) != len(value):
            raise ValueError("must not repeat a camera")
        return value


class PtzMove(BaseModel):
    pan: float = Field(default=0.0, ge=-1.0, le=1.0)
    tilt: float = Field(default=0.0, ge=-1.0, le=1.0)
    zoom: float = Field(default=0.0, ge=-1.0, le=1.0)
