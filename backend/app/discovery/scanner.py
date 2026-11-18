import asyncio
from collections import defaultdict
from dataclasses import dataclass
from ipaddress import IPv4Address, IPv4Network, ip_network

from app.discovery.classifier import guess_brand, guess_onvif_port
from app.modules.cameras.enums import CameraBrand
from app.onvif.client import OnvifClient
from app.onvif.soap import OnvifError, OnvifFault

SCAN_PORTS = (80, 443, 554, 8000, 8800, 8899, 34567)
CAMERA_PORTS = frozenset({554, 8000, 8800, 8899})
ONVIF_PORTS = (8899, 80)

SMALLEST_PREFIX = 24

CONNECT_TIMEOUT_SECONDS = 0.8
SCAN_CONCURRENCY = 512

ONVIF_TIMEOUT_SECONDS = 2.5
ONVIF_CONCURRENCY = 16


class SubnetError(ValueError):
    def __init__(self, code: str, message: str):
        super().__init__(message)
        self.code = code
        self.message = message


@dataclass(frozen=True)
class DiscoveredHost:
    host: str
    open_ports: list[int]
    brand: CameraBrand | None
    manufacturer: str | None
    model: str | None
    onvif_port: int | None


def parse_subnet(value: str) -> IPv4Network:
    try:
        network = ip_network(value.strip(), strict=False)
    except ValueError:
        raise SubnetError("invalid_subnet", f"{value} is not a valid subnet")
    if not isinstance(network, IPv4Network):
        raise SubnetError("invalid_subnet", "Only IPv4 subnets can be scanned")
    if network.prefixlen < SMALLEST_PREFIX:
        raise SubnetError("subnet_too_large", f"Subnets larger than a /{SMALLEST_PREFIX} are not scanned")
    return network


def subnet_hosts(network: IPv4Network) -> list[IPv4Address]:
    hosts = list(network.hosts())
    return hosts or [network.network_address]


async def port_open(host: str, port: int, timeout: float = CONNECT_TIMEOUT_SECONDS) -> bool:
    try:
        reader, writer = await asyncio.wait_for(asyncio.open_connection(host, port), timeout)
    except (OSError, TimeoutError):
        return False
    writer.close()
    try:
        await asyncio.wait_for(writer.wait_closed(), timeout)
    except (OSError, TimeoutError):
        pass
    return True


async def sweep(hosts: list[str], ports: tuple[int, ...], concurrency: int = SCAN_CONCURRENCY) -> dict[str, list[int]]:
    semaphore = asyncio.Semaphore(concurrency)

    async def check(host: str, port: int) -> tuple[str, int, bool]:
        async with semaphore:
            return host, port, await port_open(host, port)

    results = await asyncio.gather(*(check(host, port) for host in hosts for port in ports))
    found: dict[str, list[int]] = defaultdict(list)
    for host, port, is_open in results:
        if is_open:
            found[host].append(port)
    return {host: sorted(ports) for host, ports in found.items()}


async def identify(host: str, open_ports: list[int]) -> tuple[str | None, str | None, int | None]:
    for port in ONVIF_PORTS:
        if port not in open_ports:
            continue
        client = OnvifClient(host, port, timeout=ONVIF_TIMEOUT_SECONDS)
        try:
            info = await client.device_information()
        except OnvifFault:
            return None, None, port
        except OnvifError:
            continue
        return info.manufacturer, info.model, port
    return None, None, None


async def describe(host: str, open_ports: list[int], semaphore: asyncio.Semaphore) -> DiscoveredHost:
    async with semaphore:
        manufacturer, model, answered_port = await identify(host, open_ports)
    brand = guess_brand(open_ports, manufacturer, answered_port)
    return DiscoveredHost(
        host=host,
        open_ports=open_ports,
        brand=brand,
        manufacturer=manufacturer,
        model=model,
        onvif_port=guess_onvif_port(brand, open_ports, answered_port),
    )


async def scan(network: IPv4Network) -> list[DiscoveredHost]:
    hosts = [str(address) for address in subnet_hosts(network)]
    found = await sweep(hosts, SCAN_PORTS)
    candidates = {host: ports for host, ports in found.items() if CAMERA_PORTS.intersection(ports)}
    semaphore = asyncio.Semaphore(ONVIF_CONCURRENCY)
    described = await asyncio.gather(*(describe(host, ports, semaphore) for host, ports in candidates.items()))
    return sorted(described, key=lambda item: IPv4Address(item.host))
