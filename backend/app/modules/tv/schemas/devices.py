"""Schemas of paired TV devices."""

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel

__all__ = ["TvDeviceList", "TvDeviceRead"]


class TvDeviceRead(BaseModel):
    """Paired TV device as shown to users.

    Attributes:
        uuid: Public id of the device.
        name: Name the TV was paired under.
        created_at: Time the device was paired.
        last_seen_at: Time of the last authenticated request, if any.
    """

    uuid: UUID
    name: str
    created_at: datetime
    last_seen_at: datetime | None


class TvDeviceList(BaseModel):
    """List of paired TV devices.

    Attributes:
        items: Active devices, newest first.
    """

    items: list[TvDeviceRead]
