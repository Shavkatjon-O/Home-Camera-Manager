"""Schemas of the calls a connector makes: pairing, heartbeat, discovery reports and its configuration."""

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field

from app.modules.cameras.enums import CameraBrand
from app.modules.connectors.enums import DEVICE_GRANT, DeviceGrantError, FoundBy

__all__ = [
    "ConnectorCameraConfig",
    "ConnectorConfig",
    "ConnectorToken",
    "DeviceAuthorization",
    "DeviceCodeRequest",
    "DeviceGrantErrorBody",
    "DeviceTokenRequest",
    "DiscoveredIn",
    "DiscoveryReport",
    "HeartbeatAck",
    "HeartbeatCamera",
    "HeartbeatIn",
    "TunnelPeer",
]


class DeviceCodeRequest(BaseModel):
    """A connector's request for a pairing code.

    Attributes:
        name: Name the connector suggests, such as its host name.
        version: Agent version.
        public_key: WireGuard public key of the connector, for the tunnel.
    """

    name: str = Field(default="Connector", min_length=1, max_length=100)
    version: str | None = Field(default=None, max_length=40)
    public_key: str | None = Field(default=None, max_length=64)


class DeviceAuthorization(BaseModel):
    """The RFC 8628 device authorization answer.

    Attributes:
        device_code: Code the connector polls the token endpoint with; kept secret on the connector.
        user_code: Code the connector shows, which a member types or scans in the app.
        verification_uri: Address of the claim page.
        verification_uri_complete: The same with the code, for the QR code.
        expires_in: Seconds both codes stay valid.
        interval: Seconds to wait between polls.
    """

    device_code: str
    user_code: str
    verification_uri: str
    verification_uri_complete: str
    expires_in: int
    interval: int


class DeviceTokenRequest(BaseModel):
    """A connector's poll of the token endpoint.

    Attributes:
        grant_type: The device code grant URN.
        device_code: The device code.
    """

    grant_type: str = Field(default=DEVICE_GRANT, max_length=100)
    device_code: str = Field(min_length=16, max_length=128)


class DeviceGrantErrorBody(BaseModel):
    """An RFC 8628 error answer of the token endpoint.

    Attributes:
        error: Error code.
        error_description: Explanation.
        interval: Seconds to wait before the next poll, sent with slow_down.
    """

    error: DeviceGrantError
    error_description: str
    interval: int | None = None


class TunnelPeer(BaseModel):
    """Where the connector's WireGuard tunnel connects, once tunnel mode exists.

    Attributes:
        endpoint: WireGuard endpoint of central, host and UDP port.
        websocket: wstunnel address of central on TCP 443 for networks without UDP.
        public_key: Central's WireGuard public key.
        address: Overlay address assigned to the connector, as a /32.
        allowed_ips: Overlay addresses the connector routes into the tunnel.
    """

    endpoint: str
    websocket: str
    public_key: str
    address: str
    allowed_ips: list[str]


class ConnectorToken(BaseModel):
    """What a connector receives once a member claimed it.

    Attributes:
        access_token: Token for the connector's calls to the backend.
        token_type: Always Bearer.
        connector: Public id of the connector.
        site: Public id of the site it belongs to.
        organisation: Public id of the organisation.
        agent_key: Key central sends on its calls to the connector's agent.
        stream_username: RTSP user the connector's go2rtc asks central for.
        stream_password: RTSP password of that user.
        heartbeat_interval: Seconds between heartbeats.
        tunnel: Tunnel peer, None in direct mode.
    """

    access_token: str
    token_type: str = "Bearer"
    connector: UUID
    site: UUID
    organisation: UUID
    agent_key: str
    stream_username: str
    stream_password: str
    heartbeat_interval: int
    tunnel: TunnelPeer | None = None


class HeartbeatCamera(BaseModel):
    """Reachability of one camera as the connector sees it.

    Attributes:
        uuid: Camera id.
        online: Whether its stream answered.
        error: Reason it did not.
    """

    uuid: UUID
    online: bool
    error: str | None = Field(default=None, max_length=200)


class HeartbeatIn(BaseModel):
    """A connector's periodic report.

    Attributes:
        version: Agent version.
        address: Address central should reach it at in direct mode; the request's source address when omitted.
        api_port: Port of the agent API.
        rtsp_port: RTSP port of its go2rtc.
        uptime_seconds: Seconds since the agent started.
        cameras: Reachability of its cameras.
        health: Free-form health facts, such as load and disk.
    """

    version: str | None = Field(default=None, max_length=40)
    address: str | None = Field(default=None, max_length=255)
    api_port: int = Field(default=8780, ge=1, le=65535)
    rtsp_port: int = Field(default=8554, ge=1, le=65535)
    uptime_seconds: float = Field(default=0, ge=0)
    cameras: list[HeartbeatCamera] = Field(default_factory=list, max_length=256)
    health: dict = Field(default_factory=dict)


class HeartbeatAck(BaseModel):
    """The backend's answer to a heartbeat.

    Attributes:
        discovery_requested: Whether a member asked for a discovery run since the last report.
        config_version: Digest of the connector's camera list, which changes when a camera changes.
        server_time: Backend time.
    """

    discovery_requested: bool
    config_version: str
    server_time: datetime


class DiscoveredIn(BaseModel):
    """A camera candidate a connector found.

    Attributes:
        host: Address on the site's network.
        open_ports: Ports that accepted a connection.
        brand: Guessed brand.
        manufacturer: Manufacturer reported over ONVIF.
        model: Model reported over ONVIF.
        onvif_port: ONVIF port.
        found_by: wsd, sweep or both.
        scopes: WS-Discovery scopes.
    """

    host: str = Field(min_length=1, max_length=255)
    open_ports: list[int] = Field(default_factory=list, max_length=32)
    brand: CameraBrand | None = None
    manufacturer: str | None = Field(default=None, max_length=100)
    model: str | None = Field(default=None, max_length=100)
    onvif_port: int | None = Field(default=None, ge=1, le=65535)
    found_by: FoundBy = FoundBy.SWEEP
    scopes: list[str] = Field(default_factory=list, max_length=64)


class DiscoveryReport(BaseModel):
    """Everything a discovery run found.

    Attributes:
        cameras: The candidates.
    """

    cameras: list[DiscoveredIn] = Field(default_factory=list, max_length=1024)


class ConnectorCameraConfig(BaseModel):
    """A camera the connector serves, without its credentials, which the connector keeps itself.

    Attributes:
        uuid: Camera id; the connector's go2rtc streams are named by it.
        name: Display name.
        brand: Brand.
        host: Address on the site's network.
        rtsp_port: RTSP port.
        onvif_port: ONVIF port, if any.
        main_path: Main stream path.
        sub_path: Sub stream path, if any.
        enabled: Whether to stream it.
    """

    uuid: UUID
    name: str
    brand: CameraBrand
    host: str
    rtsp_port: int
    onvif_port: int | None
    main_path: str
    sub_path: str | None
    enabled: bool


class ConnectorConfig(BaseModel):
    """The connector's camera list.

    Attributes:
        version: Digest of the list.
        cameras: The cameras.
    """

    version: str
    cameras: list[ConnectorCameraConfig]
