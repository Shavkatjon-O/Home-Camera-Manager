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
    host: str
    port: int
    username: str | None
    password: str | None
    bridged: bool

    def client(self, timeout: float | None = None) -> OnvifClient:
        if timeout is None:
            return OnvifClient(self.host, self.port, self.username, self.password)
        return OnvifClient(self.host, self.port, self.username, self.password, timeout=timeout)

    @property
    def label(self) -> str:
        return f"{self.host}:{self.port}"


def device_endpoint(camera: Camera) -> OnvifEndpoint | None:
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
    endpoint: OnvifEndpoint
    client: OnvifClient
    services: dict[str, str]

    def address(self, name: str) -> str | None:
        if name == "device":
            return self.services.get("device") or self.client.device_address
        return self.services.get(name)


def endpoint_key(endpoint: OnvifEndpoint) -> tuple:
    return (endpoint.host, endpoint.port, endpoint.username or "", endpoint.password or "")


class Directory:
    def __init__(self, ttl: float = DIRECTORY_TTL_SECONDS):
        self.ttl = ttl
        self.entries: dict[tuple, tuple[float, Connection]] = {}

    async def open(self, endpoint: OnvifEndpoint) -> Connection:
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
        self.entries.pop(endpoint_key(endpoint), None)


directory = Directory()
