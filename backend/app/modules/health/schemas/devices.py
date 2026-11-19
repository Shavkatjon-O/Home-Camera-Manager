from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field, field_validator, model_validator

from app.modules.cameras.schemas import clean_host, clean_text
from app.modules.health.enums import DeviceKind, LinkKind

__all__ = ["NetworkDeviceCreate", "NetworkDeviceList", "NetworkDeviceRead", "NetworkDeviceUpdate"]

PORT_MIN = 1
PORT_MAX = 65535
PROBE_PORT_DEFAULT = 80

NAME_MAX = 100
HOST_MAX = 255
NOTES_MAX = 1000

REQUIRED_ON_UPDATE = ("name", "kind", "host", "probe_port", "enabled")


class NetworkDeviceRead(BaseModel):
    uuid: UUID
    name: str
    kind: DeviceKind
    host: str
    probe_port: int
    parent_uuid: UUID | None
    parent_name: str | None
    link: LinkKind | None
    notes: str | None
    enabled: bool
    created_at: datetime
    updated_at: datetime


class NetworkDeviceList(BaseModel):
    items: list[NetworkDeviceRead]
    total: int
    page: int
    page_size: int


class DeviceFields(BaseModel):
    @field_validator("name", "notes", mode="before", check_fields=False)
    @classmethod
    def strip_text(cls, value):
        return clean_text(value) if isinstance(value, str) else value

    @field_validator("host", mode="before", check_fields=False)
    @classmethod
    def normalize_host(cls, value):
        return clean_host(value) if isinstance(value, str) else value


class NetworkDeviceCreate(DeviceFields):
    name: str = Field(min_length=1, max_length=NAME_MAX)
    kind: DeviceKind
    host: str = Field(min_length=1, max_length=HOST_MAX)
    probe_port: int = Field(default=PROBE_PORT_DEFAULT, ge=PORT_MIN, le=PORT_MAX)

    parent_uuid: UUID | None = None
    link: LinkKind | None = None

    notes: str | None = Field(default=None, max_length=NOTES_MAX)
    enabled: bool = True


class NetworkDeviceUpdate(DeviceFields):
    name: str | None = Field(default=None, min_length=1, max_length=NAME_MAX)
    kind: DeviceKind | None = None
    host: str | None = Field(default=None, min_length=1, max_length=HOST_MAX)
    probe_port: int | None = Field(default=None, ge=PORT_MIN, le=PORT_MAX)

    parent_uuid: UUID | None = None
    link: LinkKind | None = None

    notes: str | None = Field(default=None, max_length=NOTES_MAX)
    enabled: bool | None = None

    @model_validator(mode="after")
    def reject_null_required(self):
        for field in REQUIRED_ON_UPDATE:
            if field in self.model_fields_set and getattr(self, field) is None:
                raise ValueError(f"{field} cannot be empty")
        return self
