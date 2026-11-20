"""Request and response schemas of cameras."""

import re
from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field, field_validator, model_validator

from app.modules.devices.enums import CameraBrand

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
    """Trim a text value and turn an empty result into None.

    Args:
        value: Text to clean, if any.

    Returns:
        The trimmed text, or None when it is missing or blank.
    """
    if value is None:
        return None
    value = value.strip()
    return value or None


def clean_host(value: str | None) -> str | None:
    """Trim a host and lowercase it after checking its characters.

    Args:
        value: IP address or host name to clean, if any.

    Returns:
        The lowercase host, or None when it is missing or blank.

    Raises:
        ValueError: The host holds characters other than letters, digits, dots, hyphens and underscores.
    """
    value = clean_text(value)
    if value is None:
        return None
    if not HOST_PATTERN.match(value):
        raise ValueError("must be an IP address or a host name")
    return value.lower()


def clean_path(value: str | None) -> str | None:
    """Trim a stream path and give it a leading slash.

    Args:
        value: Stream path to clean, if any.

    Returns:
        The path starting with a slash, or None when it is missing or blank.

    Raises:
        ValueError: The path contains whitespace.
    """
    value = clean_text(value)
    if value is None:
        return None
    if not PATH_PATTERN.match(value):
        raise ValueError("must not contain spaces")
    return value if value.startswith("/") else f"/{value}"


class CameraStatus(BaseModel):
    """Last known reachability of a camera.

    Attributes:
        online: Whether the last probe reached the camera, or None before any probe.
        checked_at: When the last probe ran, or None before any probe.
        error: Reason the last probe failed, if it did.
    """

    online: bool | None
    checked_at: datetime | None
    error: str | None


class CameraStreams(BaseModel):
    """Names of the camera streams in the stream server.

    Attributes:
        main: Name of the main stream.
        sub: Name of the sub stream, or None when the camera has none.
    """

    main: str
    sub: str | None


class CameraRead(BaseModel):
    """Camera as returned by the API; the password is never included.

    Attributes:
        uuid: Public id of the camera.
        name: Display name.
        brand: Camera brand.
        host: Address the streams are pulled from.
        device_host: Address of the camera itself when it differs from host.
        rtsp_port: RTSP port of host.
        onvif_port: ONVIF port, or None when the camera has none.
        username: Camera login name.
        has_password: Whether a password is stored.
        main_path: RTSP path of the main stream.
        sub_path: RTSP path of the sub stream, or None when there is none.
        lenses: Number of lenses the camera has.
        ptz_enabled: Whether pan, tilt and zoom control is on.
        location: Free-text place the camera watches.
        position: Place of the camera in the wall order.
        enabled: Whether the camera is streamed.
        status: Last known reachability.
        streams: Stream names in the stream server.
        created_at: When the camera was registered.
        updated_at: When the camera last changed.
        connector: Connector that reaches the camera on its site's network, None when the backend reaches it.
    """

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
    connector: UUID | None = None


class CameraList(BaseModel):
    """One page of cameras.

    Attributes:
        items: Cameras on the page.
        total: Number of cameras in the registry.
        page: Page number, starting at 1.
        page_size: Number of cameras per page.
    """

    items: list[CameraRead]
    total: int
    page: int
    page_size: int


class CameraFields(BaseModel):
    """Cleaning shared by the create and update requests."""

    @field_validator("name", "username", "location", mode="before", check_fields=False)
    @classmethod
    def strip_text(cls, value):
        """Trim text fields and turn blank ones into None.

        Args:
            value: Raw field value.

        Returns:
            The cleaned text, or the value unchanged when it is not a string.
        """
        return clean_text(value) if isinstance(value, str) else value

    @field_validator("host", "device_host", mode="before", check_fields=False)
    @classmethod
    def normalize_host(cls, value):
        """Clean and lowercase host fields.

        Args:
            value: Raw field value.

        Returns:
            The cleaned host, or the value unchanged when it is not a string.
        """
        return clean_host(value) if isinstance(value, str) else value

    @field_validator("main_path", "sub_path", mode="before", check_fields=False)
    @classmethod
    def normalize_path(cls, value):
        """Clean stream path fields and give them a leading slash.

        Args:
            value: Raw field value.

        Returns:
            The cleaned path, or the value unchanged when it is not a string.
        """
        return clean_path(value) if isinstance(value, str) else value


class CameraCreate(CameraFields):
    """Request to register a camera.

    Fields left as None are filled from the brand defaults or, for an ONVIF camera, from the camera itself.

    Attributes:
        name: Display name.
        brand: Camera brand.
        host: Address the streams are pulled from.
        device_host: Address of the camera itself when it differs from host.
        location: Free-text place the camera watches.
        rtsp_port: RTSP port of host.
        onvif_port: ONVIF port.
        username: Camera login name.
        password: Camera password.
        main_path: RTSP path of the main stream.
        sub_path: RTSP path of the sub stream.
        lenses: Number of lenses the camera has.
        ptz_enabled: Whether pan, tilt and zoom control is on.
        enabled: Whether the camera is streamed.
        connector: Connector of the site that reaches the camera; its password then goes to the connector and is
            not stored by the backend.
    """

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
    connector: UUID | None = None


class CameraUpdate(CameraFields):
    """Request to change a camera; only the fields that are sent change.

    Attributes:
        name: Display name.
        brand: Camera brand.
        host: Address the streams are pulled from.
        device_host: Address of the camera itself when it differs from host.
        location: Free-text place the camera watches.
        rtsp_port: RTSP port of host.
        onvif_port: ONVIF port.
        username: Camera login name.
        password: New camera password; an empty string removes the stored one.
        main_path: RTSP path of the main stream.
        sub_path: RTSP path of the sub stream.
        lenses: Number of lenses the camera has.
        ptz_enabled: Whether pan, tilt and zoom control is on.
        enabled: Whether the camera is streamed.
    """

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
        """Reject an explicit null for a field the camera cannot be without.

        Returns:
            The validated request.

        Raises:
            ValueError: A required field is sent as null.
        """
        for field in REQUIRED_ON_UPDATE:
            if field in self.model_fields_set and getattr(self, field) is None:
                raise ValueError(f"{field} cannot be empty")
        return self


class CameraOrder(BaseModel):
    """Request to set the wall order.

    Attributes:
        uuids: Camera ids in the order they should appear.
    """

    uuids: list[UUID] = Field(min_length=1)

    @field_validator("uuids")
    @classmethod
    def unique_uuids(cls, value: list[UUID]) -> list[UUID]:
        """Reject a list that names a camera twice.

        Args:
            value: Camera ids in the requested order.

        Returns:
            The same ids.

        Raises:
            ValueError: An id appears more than once.
        """
        if len(set(value)) != len(value):
            raise ValueError("must not repeat a camera")
        return value


class PtzMove(BaseModel):
    """Speed of a pan, tilt and zoom move.

    Attributes:
        pan: Pan speed from -1.0 to 1.0.
        tilt: Tilt speed from -1.0 to 1.0.
        zoom: Zoom speed from -1.0 to 1.0.
    """

    pan: float = Field(default=0.0, ge=-1.0, le=1.0)
    tilt: float = Field(default=0.0, ge=-1.0, le=1.0)
    zoom: float = Field(default=0.0, ge=-1.0, le=1.0)
