"""Schemas of devices and their channels."""

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel

from app.modules.devices.schemas.capabilities import CapabilitiesRead

__all__ = ["DeviceChannelRead", "DeviceList", "DeviceRead"]


class DeviceChannelRead(BaseModel):
    """A channel of a device and the camera it is.

    Attributes:
        camera: Public id of the camera.
        channel: Channel number from 1.
        name: Name of the camera.
        enabled: Whether the camera is streamed.
    """

    camera: UUID
    channel: int
    name: str
    enabled: bool


class DeviceRead(BaseModel):
    """A camera, NVR or DVR at the site.

    Attributes:
        uuid: Public id.
        kind: camera, nvr or dvr.
        adapter: Adapter that reaches it.
        name: Display name.
        vendor: Manufacturer it reported.
        model: Model it reported.
        connector: Connector that reaches it, None when the backend reaches it.
        channel_count: Video channels it reported.
        channels: Its channels that were added as cameras.
        capabilities: Its capability manifest.
        identified_at: When an adapter last identified it.
        created_at: When it was added.
    """

    uuid: UUID
    kind: str
    adapter: str
    name: str
    vendor: str | None
    model: str | None
    connector: UUID | None
    channel_count: int
    channels: list[DeviceChannelRead]
    capabilities: CapabilitiesRead
    identified_at: datetime | None
    created_at: datetime


class DeviceList(BaseModel):
    """Devices of the site.

    Attributes:
        items: The devices, oldest first.
    """

    items: list[DeviceRead]
