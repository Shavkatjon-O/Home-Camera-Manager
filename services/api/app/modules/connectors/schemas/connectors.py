"""Schemas of the connector endpoints of the apps."""

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field, field_validator

from app.modules.cameras.enums import CameraBrand
from app.modules.connectors.enums import ConnectorMode, FoundBy, PairingStatus

__all__ = [
    "ConnectorClaim",
    "ConnectorList",
    "ConnectorRead",
    "ConnectorUpdate",
    "DiscoveredList",
    "DiscoveredRead",
    "PairingRead",
    "StreamTest",
    "StreamTestResult",
    "clean_user_code",
]

USER_CODE_LENGTH = 8


def clean_user_code(value: str) -> str:
    """Normalise a typed or scanned pairing code.

    Args:
        value: The code, with or without its hyphen, or a claim link that carries it.

    Returns:
        The eight characters in upper case.

    Raises:
        ValueError: The code is not eight letters.
    """
    text = value.strip()
    if "code=" in text:
        text = text.split("code=", 1)[1].split("&", 1)[0]
    code = "".join(character for character in text.upper() if character.isalnum())
    if len(code) != USER_CODE_LENGTH:
        raise ValueError("must be the eight letters the connector shows")
    return code


class ConnectorClaim(BaseModel):
    """Request to pair the connector that shows a code to the request's site.

    Attributes:
        user_code: The code the connector shows, or the link of its QR code.
        name: Name for the connector; the one it suggested when omitted.
    """

    user_code: str = Field(min_length=8, max_length=300)
    name: str | None = Field(default=None, min_length=1, max_length=100)

    @field_validator("user_code")
    @classmethod
    def normalize_code(cls, value: str) -> str:
        """Normalise the code.

        Args:
            value: Raw code.

        Returns:
            The eight characters.
        """
        return clean_user_code(value)


class PairingRead(BaseModel):
    """A claimed pairing as the app follows it until the connector picks up its token.

    Attributes:
        uuid: Public id of the pairing.
        name: Name of the connector.
        status: pending, claimed, delivered or expired.
        expires_at: When the codes stop working.
        connector: The connector, once it received its token.
    """

    uuid: UUID
    name: str
    status: PairingStatus
    expires_at: datetime
    connector: UUID | None


class ConnectorRead(BaseModel):
    """A paired connector.

    Attributes:
        uuid: Public id.
        name: Display name.
        version: Agent version it last reported.
        mode: direct or tunnel.
        address: Address central reaches it at.
        online: Whether a heartbeat arrived recently.
        last_seen_at: When the last heartbeat arrived.
        camera_count: Cameras it serves.
        discovery_requested_at: When a discovery run was last asked for.
        discovered_at: When it last reported discovery results.
        health: Health it last reported.
        created_at: When it was paired.
    """

    uuid: UUID
    name: str
    version: str | None
    mode: ConnectorMode
    address: str | None
    online: bool
    last_seen_at: datetime | None
    camera_count: int
    discovery_requested_at: datetime | None
    discovered_at: datetime | None
    health: dict
    created_at: datetime


class ConnectorList(BaseModel):
    """Connectors of the site.

    Attributes:
        items: The connectors, oldest first.
    """

    items: list[ConnectorRead]


class ConnectorUpdate(BaseModel):
    """Request to change a connector; only the fields sent change.

    Attributes:
        name: Display name.
        address: Address central reaches it at in direct mode, replacing the reported one.
    """

    name: str | None = Field(default=None, min_length=1, max_length=100)
    address: str | None = Field(default=None, min_length=1, max_length=255)


class DiscoveredRead(BaseModel):
    """A camera candidate a connector found.

    Attributes:
        uuid: Public id of the candidate.
        host: Address on the site's network.
        open_ports: Ports that accepted a connection.
        brand: Guessed brand.
        manufacturer: Manufacturer reported over ONVIF.
        model: Model reported over ONVIF.
        onvif_port: ONVIF port.
        found_by: wsd, sweep or both.
        seen_at: When it was last reported.
        camera: Camera registered from it, if any.
    """

    uuid: UUID
    host: str
    open_ports: list[int]
    brand: CameraBrand | None
    manufacturer: str | None
    model: str | None
    onvif_port: int | None
    found_by: FoundBy
    seen_at: datetime
    camera: UUID | None


class DiscoveredList(BaseModel):
    """Camera candidates of a connector.

    Attributes:
        items: The candidates by address.
        discovered_at: When the connector last reported.
    """

    items: list[DiscoveredRead]
    discovered_at: datetime | None


class StreamTest(BaseModel):
    """Request to test a camera's credentials and streams through a connector.

    Attributes:
        host: Address of the camera on the site's network.
        brand: Brand, which fills default ports and paths.
        rtsp_port: RTSP port.
        onvif_port: ONVIF port.
        username: Camera login.
        password: Camera password; it reaches the connector and is not stored by the backend.
        main_path: Main stream path; read over ONVIF when omitted.
        sub_path: Sub stream path.
    """

    host: str = Field(min_length=1, max_length=255)
    brand: CameraBrand = CameraBrand.ONVIF
    rtsp_port: int | None = Field(default=None, ge=1, le=65535)
    onvif_port: int | None = Field(default=None, ge=1, le=65535)
    username: str | None = Field(default=None, max_length=100)
    password: str | None = Field(default=None, max_length=256)
    main_path: str | None = Field(default=None, max_length=255)
    sub_path: str | None = Field(default=None, max_length=255)


class StreamTestResult(BaseModel):
    """What the connector found when it tested a camera.

    Attributes:
        ok: Whether the main stream answered.
        error: Why it did not.
        rtsp_port: RTSP port in use.
        main_path: Main stream path.
        sub_path: Sub stream path, if any.
        ptz: Whether the camera offers PTZ over ONVIF.
        manufacturer: Manufacturer reported over ONVIF.
        model: Model reported over ONVIF.
    """

    ok: bool
    error: str | None = None
    rtsp_port: int | None = None
    main_path: str | None = None
    sub_path: str | None = None
    ptz: bool | None = None
    manufacturer: str | None = None
    model: str | None = None
