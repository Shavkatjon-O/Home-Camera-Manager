"""Network device schemas."""

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field, field_validator, model_validator

from app.modules.devices.schemas import clean_host, clean_text
from app.modules.operations.enums import DeviceKind, LinkKind

__all__ = ["NetworkDeviceCreate", "NetworkDeviceList", "NetworkDeviceRead", "NetworkDeviceUpdate"]

PORT_MIN = 1
PORT_MAX = 65535
PROBE_PORT_DEFAULT = 80

NAME_MAX = 100
HOST_MAX = 255
NOTES_MAX = 1000

REQUIRED_ON_UPDATE = ("name", "kind", "host", "probe_port", "enabled")


class NetworkDeviceRead(BaseModel):
    """Network device as returned by the API.

    Attributes:
        uuid: Public id.
        name: Display name.
        kind: Device kind.
        host: Address that is probed.
        probe_port: TCP port that is probed.
        parent_uuid: Public id of the device it connects through, if any.
        parent_name: Name of that device.
        link: How it connects to the parent.
        notes: Free-form notes.
        enabled: Whether the device is probed.
        created_at: When the device was created.
        updated_at: When the device last changed.
    """

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
    """One page of network devices.

    Attributes:
        items: Devices on the page.
        total: Number of devices in all pages.
        page: One-based page number.
        page_size: Devices per page.
    """

    items: list[NetworkDeviceRead]
    total: int
    page: int
    page_size: int


class DeviceFields(BaseModel):
    """Input cleaning shared by device creation and update."""

    @field_validator("name", "notes", mode="before", check_fields=False)
    @classmethod
    def strip_text(cls, value):
        """Trim name and notes and turn a blank result into None.

        Args:
            value: Raw input.

        Returns:
            The cleaned text, or the value unchanged when it is not a string.
        """
        return clean_text(value) if isinstance(value, str) else value

    @field_validator("host", mode="before", check_fields=False)
    @classmethod
    def normalize_host(cls, value):
        """Trim a host and lowercase it after checking its characters.

        Args:
            value: Raw input.

        Returns:
            The cleaned host, or the value unchanged when it is not a string.
        """
        return clean_host(value) if isinstance(value, str) else value


class NetworkDeviceCreate(DeviceFields):
    """Fields for creating a network device.

    Attributes:
        name: Display name.
        kind: Device kind.
        host: Address to probe.
        probe_port: TCP port to probe.
        parent_uuid: Public id of the device it connects through, if any.
        link: How it connects to the parent.
        notes: Free-form notes.
        enabled: Whether the device is probed.
    """

    name: str = Field(min_length=1, max_length=NAME_MAX)
    kind: DeviceKind
    host: str = Field(min_length=1, max_length=HOST_MAX)
    probe_port: int = Field(default=PROBE_PORT_DEFAULT, ge=PORT_MIN, le=PORT_MAX)

    parent_uuid: UUID | None = None
    link: LinkKind | None = None

    notes: str | None = Field(default=None, max_length=NOTES_MAX)
    enabled: bool = True


class NetworkDeviceUpdate(DeviceFields):
    """Fields for changing a network device. Fields left out stay as they are.

    Attributes:
        name: New display name.
        kind: New device kind.
        host: New address to probe.
        probe_port: New TCP port to probe.
        parent_uuid: New parent device, or null to detach it.
        link: New link kind, or null to clear it.
        notes: New notes, or null to clear them.
        enabled: Whether the device is probed.
    """

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
        """Reject an update that sets a required field to null.

        Returns:
            The validated update.

        Raises:
            ValueError: A required field is present with a null value.
        """
        for field in REQUIRED_ON_UPDATE:
            if field in self.model_fields_set and getattr(self, field) is None:
                raise ValueError(f"{field} cannot be empty")
        return self
