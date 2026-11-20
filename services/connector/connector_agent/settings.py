"""Settings of the connector agent, read from SSS_CONNECTOR_ environment variables."""

import os
from dataclasses import dataclass, field

__all__ = ["Settings", "env", "env_list", "load_settings"]


def env(name: str, default: str = "") -> str:
    """Read one setting.

    Args:
        name: Name without the SSS_CONNECTOR_ prefix.
        default: Value when it is unset.

    Returns:
        The value, trimmed.
    """
    return os.environ.get(f"SSS_CONNECTOR_{name}", default).strip()


def env_list(name: str) -> tuple[str, ...]:
    """Read a comma-separated setting.

    Args:
        name: Name without the SSS_CONNECTOR_ prefix.

    Returns:
        The items, trimmed, without empty ones.
    """
    return tuple(item.strip() for item in env(name).split(",") if item.strip())


@dataclass(frozen=True)
class Settings:
    """Every setting of the agent.

    Attributes:
        backend_url: Base address of the central backend.
        name: Name the connector suggests when pairing.
        state_dir: Folder of the agent's state, the camera store and its key.
        secret: Text the store key is derived from; empty keeps a generated key file in the state folder.
        advertise_address: Address central reaches the connector at in direct mode; empty lets the backend use the
            heartbeat's source address.
        api_port: Port of the agent API.
        rtsp_port: RTSP port of the connector's go2rtc.
        go2rtc_binary: Path of the go2rtc program.
        go2rtc_api: Loopback address of go2rtc's API.
        interfaces: Network interfaces discovery may use; empty uses every site LAN interface the filter keeps.
        subnets: Subnets the port sweep covers; empty uses the subnets of the allowed interfaces.
        discovery_interval: Seconds between discovery runs of their own, 0 for runs on request only.
        heartbeat_seconds: Seconds between heartbeats before the backend sets its own interval.
        verify_tls: Whether to verify the backend's TLS certificate.
        mdns: Whether to announce the connector over multicast DNS while it waits for pairing.
    """

    backend_url: str = field(default_factory=lambda: env("BACKEND_URL", "http://backend:8000").rstrip("/"))
    name: str = field(default_factory=lambda: env("NAME", "Connector"))

    state_dir: str = field(default_factory=lambda: env("STATE_DIR", "/data"))
    secret: str = field(default_factory=lambda: env("SECRET"))

    advertise_address: str = field(default_factory=lambda: env("ADVERTISE_ADDRESS"))
    api_port: int = field(default_factory=lambda: int(env("API_PORT", "8780")))
    rtsp_port: int = field(default_factory=lambda: int(env("RTSP_PORT", "8554")))

    go2rtc_binary: str = field(default_factory=lambda: env("GO2RTC_BINARY", "/usr/local/bin/go2rtc"))
    go2rtc_api: str = field(default_factory=lambda: env("GO2RTC_API", "127.0.0.1:1984"))

    interfaces: tuple[str, ...] = field(default_factory=lambda: env_list("INTERFACES"))
    subnets: tuple[str, ...] = field(default_factory=lambda: env_list("SUBNETS"))
    discovery_interval: int = field(default_factory=lambda: int(env("DISCOVERY_INTERVAL", "0")))

    heartbeat_seconds: int = field(default_factory=lambda: int(env("HEARTBEAT_SECONDS", "30")))
    verify_tls: bool = field(default_factory=lambda: env("VERIFY_TLS", "true").lower() != "false")
    mdns: bool = field(default_factory=lambda: env("MDNS", "true").lower() != "false")


def load_settings() -> Settings:
    """Read the settings from the environment.

    Returns:
        The settings.
    """
    return Settings()
