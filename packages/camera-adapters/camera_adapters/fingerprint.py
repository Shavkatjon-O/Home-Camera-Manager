"""Fingerprints: what an address reveals without credentials, from its ports, ONVIF, its web page and its MAC."""

import asyncio
import re
from pathlib import Path

import httpx

from camera_adapters.base import Fingerprint
from camera_adapters.classifier import V380_PORT
from camera_adapters.onvif.client import OnvifClient
from camera_adapters.onvif.soap import OnvifError, OnvifFault
from camera_adapters.sweep import SCAN_PORTS, sweep

__all__ = ["FINGERPRINT_PORTS", "arp_mac", "collect", "http_banner", "onvif_identity"]

FINGERPRINT_PORTS = tuple(sorted({*SCAN_PORTS, 2020, 8080, 9000, 37777}))
ONVIF_CANDIDATES = (80, 8899, 2020, 8080, 8000)
ARP_TABLE = Path("/proc/net/arp")
TITLE = re.compile(r"<title>\s*([^<]{1,120})\s*</title>", re.IGNORECASE)
HTTP_TIMEOUT_SECONDS = 3.0
ONVIF_TIMEOUT_SECONDS = 2.5


def arp_mac(host: str, table: Path = ARP_TABLE) -> str | None:
    """Look up the hardware address of a neighbour in the kernel's ARP table.

    Args:
        host: IPv4 address.
        table: ARP table file.

    Returns:
        The address in lower case with colons, or None when the host is not a known neighbour.
    """
    try:
        lines = table.read_text().splitlines()[1:]
    except OSError:
        return None
    for line in lines:
        parts = line.split()
        if len(parts) >= 4 and parts[0] == host and parts[3] != "00:00:00:00:00:00":
            return parts[3].lower()
    return None


async def http_banner(
    host: str, port: int = 80, transport: httpx.AsyncBaseTransport | None = None
) -> tuple[str | None, str | None]:
    """Read the server banner and page title of a device's web page.

    Args:
        host: Address.
        port: Web port.
        transport: HTTP transport, replaced in tests.

    Returns:
        The Server header and the page title, each None when absent.
    """
    try:
        async with httpx.AsyncClient(timeout=HTTP_TIMEOUT_SECONDS, transport=transport) as http:
            response = await http.get(f"http://{host}:{port}/")
    except httpx.HTTPError:
        return None, None
    title = TITLE.search(response.text[:65536])
    return response.headers.get("server"), title.group(1).strip() if title else None


async def onvif_identity(host: str, ports: list[int]) -> tuple[str | None, str | None, str | None, int | None]:
    """Ask a host for its identity over ONVIF without credentials.

    Args:
        host: Address.
        ports: Open ports to try, in order.

    Returns:
        Manufacturer, model, firmware and the port that answered; a port that answers with a fault still counts
        as ONVIF.
    """
    for port in ports:
        client = OnvifClient(host, port, timeout=ONVIF_TIMEOUT_SECONDS)
        try:
            info = await client.device_information()
        except OnvifFault:
            return None, None, None, port
        except OnvifError:
            continue
        return info.manufacturer, info.model, info.firmware, port
    return None, None, None, None


async def collect(host: str, open_ports: list[int] | None = None, scopes: tuple[str, ...] = ()) -> Fingerprint:
    """Fingerprint one address.

    Args:
        host: Address.
        open_ports: Open ports already known from a sweep; swept here when omitted.
        scopes: WS-Discovery scopes already known.

    Returns:
        The fingerprint.
    """
    if open_ports is None:
        found = await sweep([host], FINGERPRINT_PORTS)
        open_ports = found.get(host, [])
    ports = sorted(set(open_ports))
    onvif_ports = [port for port in ONVIF_CANDIDATES if port in ports]
    (manufacturer, model, firmware, onvif_port), (server, title) = await asyncio.gather(
        onvif_identity(host, onvif_ports),
        http_banner(host) if 80 in ports else asyncio.sleep(0, result=(None, None)),
    )
    return Fingerprint(
        host=host,
        open_ports=tuple(ports),
        manufacturer=manufacturer,
        model=model,
        firmware=firmware,
        onvif_port=onvif_port,
        http_server=server,
        http_title=title,
        mac=arp_mac(host),
        scopes=tuple(scopes),
        v380=V380_PORT in ports,
    )
