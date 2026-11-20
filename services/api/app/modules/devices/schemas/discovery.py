"""Request and response schemas of camera discovery."""

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
    """Request to scan a subnet.

    Attributes:
        subnet: Subnet in CIDR notation, or None to scan the configured default.
    """

    subnet: str | None = Field(default=None, max_length=43)

    @field_validator("subnet", mode="before")
    @classmethod
    def strip_subnet(cls, value):
        """Trim the subnet and turn a blank one into None.

        Args:
            value: Raw field value.

        Returns:
            The cleaned text, or the value unchanged when it is not a string.
        """
        return clean_text(value) if isinstance(value, str) else value


class ScanItem(BaseModel):
    """Host found by a scan.

    Attributes:
        host: IPv4 address of the host.
        open_ports: Scanned ports that accepted a connection.
        brand: Guessed camera brand, or None when it could not be guessed.
        manufacturer: Manufacturer the host reported over ONVIF.
        model: Model the host reported over ONVIF.
        onvif_port: ONVIF port that answered or was guessed from the brand.
        camera_uuid: Id of the registered camera at this address, or None when it is not registered.
    """

    host: str
    open_ports: list[int]
    brand: CameraBrand | None
    manufacturer: str | None
    model: str | None
    onvif_port: int | None
    camera_uuid: UUID | None


class ScanResult(BaseModel):
    """Outcome of a scan.

    Attributes:
        subnet: Subnet that was scanned.
        scanned_at: When the scan started.
        duration_ms: How long the scan took, in milliseconds.
        items: Hosts found.
    """

    subnet: str
    scanned_at: datetime
    duration_ms: int
    items: list[ScanItem]


class InspectRequest(BaseModel):
    """Request to inspect a camera over ONVIF.

    Attributes:
        host: Address of the camera.
        onvif_port: ONVIF port of the camera.
        username: Camera login name.
        password: Camera password.
    """

    host: str = Field(min_length=1, max_length=255)
    onvif_port: int = Field(ge=1, le=65535)
    username: str | None = Field(default=None, max_length=100)
    password: str | None = Field(default=None, max_length=256)

    @field_validator("host", mode="before")
    @classmethod
    def normalize_host(cls, value):
        """Clean and lowercase the host.

        Args:
            value: Raw field value.

        Returns:
            The cleaned host, or the value unchanged when it is not a string.
        """
        return clean_host(value) if isinstance(value, str) else value

    @field_validator("username", mode="before")
    @classmethod
    def strip_username(cls, value):
        """Trim the username and turn a blank one into None.

        Args:
            value: Raw field value.

        Returns:
            The cleaned text, or the value unchanged when it is not a string.
        """
        return clean_text(value) if isinstance(value, str) else value


class InspectProfile(BaseModel):
    """Stream profile a camera reports.

    Attributes:
        token: Profile token used in ONVIF calls.
        name: Profile name.
        encoding: Video encoding, if reported.
        width: Frame width in pixels, if reported.
        height: Frame height in pixels, if reported.
        stream_uri: RTSP address of the profile, if the camera gave one.
    """

    token: str
    name: str
    encoding: str | None
    width: int | None
    height: int | None
    stream_uri: str | None


class InspectResult(BaseModel):
    """What a camera reported when inspected.

    Attributes:
        manufacturer: Manufacturer, if reported.
        model: Model, if reported.
        firmware: Firmware version, if reported.
        profiles: Stream profiles of the camera.
        ptz: Whether any profile supports pan, tilt and zoom.
    """

    manufacturer: str | None
    model: str | None
    firmware: str | None
    profiles: list[InspectProfile]
    ptz: bool
