"""Resolution of a camera's ONVIF endpoint and a short-lived cache of open device connections."""

import time
from dataclasses import dataclass

from app.core.config import settings
from app.core.security import decrypt_secret
from app.models import Camera
from app.onvif.client import OnvifClient

DIRECTORY_TTL_SECONDS = 600.0
CONTROL_TIMEOUT_SECONDS = 8.0


@dataclass(frozen=True)
class OnvifEndpoint:
    """Address and credentials for reaching a camera's ONVIF service.

    Attributes:
        host: Host to connect to.
        port: ONVIF port.
        username: User name, if any.
        password: Password, if any.
        bridged: Whether the camera sits behind a V380 bridge.
    """

    host: str
    port: int
    username: str | None
    password: str | None
    bridged: bool

    def client(self, timeout: float | None = None) -> OnvifClient:
        """Create an ONVIF client for this endpoint.

        Args:
            timeout: Request timeout in seconds, the client default when omitted.

        Returns:
            A new client.
        """
        if timeout is None:
            return OnvifClient(self.host, self.port, self.username, self.password)
        return OnvifClient(self.host, self.port, self.username, self.password, timeout=timeout)

    @property
    def label(self) -> str:
        """Return the endpoint as host:port for messages.

        Returns:
            The host and port joined by a colon.
        """
        return f"{self.host}:{self.port}"


def device_endpoint(camera: Camera) -> OnvifEndpoint | None:
    """Resolve the ONVIF endpoint of the camera device itself.

    A camera with a device host is reached on that host with the shared device credentials from settings.
    Otherwise the camera's own host, ONVIF port and stored credentials are used.

    Args:
        camera: Camera to resolve.

    Returns:
        The endpoint, or None when the camera has no device host and no ONVIF port.
    """
    if camera.device_host:
        return OnvifEndpoint(
            host=camera.device_host,
            port=settings.device_onvif_port,
            username=settings.device_username or None,
            password=settings.device_password or None,
            bridged=True,
        )
    if camera.onvif_port is None:
        return None
    return OnvifEndpoint(
        host=camera.host,
        port=camera.onvif_port,
        username=camera.username,
        password=decrypt_secret(camera.password_encrypted),
        bridged=False,
    )


def bridge_endpoint(camera: Camera) -> OnvifEndpoint | None:
    """Resolve the ONVIF endpoint the V380 bridge exposes for a bridged camera.

    Args:
        camera: Camera to resolve.

    Returns:
        The endpoint on the camera's host with its stored credentials, or None when the camera has no device host
        or no ONVIF port.
    """
    if not camera.device_host or camera.onvif_port is None:
        return None
    return OnvifEndpoint(
        host=camera.host,
        port=camera.onvif_port,
        username=camera.username,
        password=decrypt_secret(camera.password_encrypted),
        bridged=True,
    )


@dataclass
class Connection:
    """An open ONVIF connection with the service addresses found on the device.

    Attributes:
        endpoint: Endpoint the connection was opened to.
        client: ONVIF client for the endpoint.
        services: Service name to service address.
    """

    endpoint: OnvifEndpoint
    client: OnvifClient
    services: dict[str, str]

    def address(self, name: str) -> str | None:
        """Return the address of an ONVIF service.

        Args:
            name: Service name, such as device or media.

        Returns:
            The service address, falling back to the client's device address for the device service,
            or None when the service is not offered.
        """
        if name == "device":
            return self.services.get("device") or self.client.device_address
        return self.services.get(name)


def endpoint_key(endpoint: OnvifEndpoint) -> tuple:
    """Build the cache key of an endpoint.

    Args:
        endpoint: Endpoint to key.

    Returns:
        The host, port, user name and password, so changed credentials open a new connection.
    """
    return (endpoint.host, endpoint.port, endpoint.username or "", endpoint.password or "")


class Directory:
    """Cache open ONVIF connections per endpoint for a limited time.

    Attributes:
        ttl: Seconds a connection stays cached.
        entries: Endpoint key to the time the connection was opened and the connection.
    """

    def __init__(self, ttl: float = DIRECTORY_TTL_SECONDS):
        """Create an empty connection directory.

        Args:
            ttl: Seconds a connection stays cached.
        """
        self.ttl = ttl
        self.entries: dict[tuple, tuple[float, Connection]] = {}

    async def open(self, endpoint: OnvifEndpoint) -> Connection:
        """Return a connection to an endpoint, opening one when none is cached or the cached one has expired.

        Args:
            endpoint: Endpoint to connect to.

        Returns:
            The connection with the service addresses the device reports.
        """
        key = endpoint_key(endpoint)
        cached = self.entries.get(key)
        if cached is not None and time.monotonic() - cached[0] < self.ttl:
            return cached[1]
        client = endpoint.client(timeout=CONTROL_TIMEOUT_SECONDS)
        services = await client.services()
        connection = Connection(endpoint=endpoint, client=client, services=services)
        self.entries[key] = (time.monotonic(), connection)
        return connection

    def drop(self, endpoint: OnvifEndpoint) -> None:
        """Forget the cached connection of an endpoint.

        Args:
            endpoint: Endpoint to forget.
        """
        self.entries.pop(endpoint_key(endpoint), None)


directory = Directory()
