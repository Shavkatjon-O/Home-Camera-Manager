"""TCP port sweep and ONVIF identification of hosts on a subnet."""

import asyncio
from collections import defaultdict
from dataclasses import dataclass
from ipaddress import IPv4Address, IPv4Network, ip_network

from adapters.base import AdapterName
from adapters.classifier import guess_brand, guess_onvif_port
from adapters.onvif.client import OnvifClient
from adapters.onvif.soap import OnvifError, OnvifFault

SCAN_PORTS = (80, 443, 554, 8000, 8800, 8899, 34567)
CAMERA_PORTS = frozenset({554, 8000, 8800, 8899})
ONVIF_PORTS = (8899, 80)

SMALLEST_PREFIX = 24

CONNECT_TIMEOUT_SECONDS = 0.8
SCAN_CONCURRENCY = 512

ONVIF_TIMEOUT_SECONDS = 2.5
ONVIF_CONCURRENCY = 16


class SubnetError(ValueError):
    """Subnet that cannot be scanned.

    Attributes:
        code: Machine-readable error code.
        message: Human-readable description.
    """

    def __init__(self, code: str, message: str):
        """Create the error.

        Args:
            code: Machine-readable error code.
            message: Human-readable description.
        """
        super().__init__(message)
        self.code = code
        self.message = message


@dataclass(frozen=True)
class DiscoveredHost:
    """Camera candidate found by a scan.

    Attributes:
        host: IPv4 address of the host.
        open_ports: Scanned ports that accepted a connection.
        brand: Guessed camera brand, or None when it could not be guessed.
        manufacturer: Manufacturer the host reported over ONVIF.
        model: Model the host reported over ONVIF.
        onvif_port: ONVIF port that answered or was guessed from the brand.
    """

    host: str
    open_ports: list[int]
    brand: AdapterName | None
    manufacturer: str | None
    model: str | None
    onvif_port: int | None


def parse_subnet(value: str) -> IPv4Network:
    """Parse a subnet and check that it is small enough to scan.

    Args:
        value: Subnet in CIDR notation; host bits are ignored.

    Returns:
        The IPv4 network.

    Raises:
        SubnetError: The value is not a valid IPv4 subnet or is larger than the smallest allowed prefix.
    """
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
    """List the addresses to scan in a subnet.

    Args:
        network: Subnet to scan.

    Returns:
        Usable host addresses, or the network address itself for a subnet that has none.
    """
    hosts = list(network.hosts())
    return hosts or [network.network_address]


async def port_open(host: str, port: int, timeout: float = CONNECT_TIMEOUT_SECONDS) -> bool:
    """Check whether a TCP port accepts a connection.

    Args:
        host: Address to connect to.
        port: TCP port.
        timeout: Seconds to wait for the connection and again for it to close.

    Returns:
        True when the connection was accepted.
    """
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
    """Check many hosts and ports for open TCP ports.

    Args:
        hosts: Addresses to check.
        ports: Ports to check on every host.
        concurrency: Most connection attempts in flight at once.

    Returns:
        Sorted open ports for each host that has at least one.
    """
    semaphore = asyncio.Semaphore(concurrency)

    async def check(host: str, port: int) -> tuple[str, int, bool]:
        """Check one port, limited by the shared semaphore.

        Args:
            host: Address to connect to.
            port: TCP port.

        Returns:
            The host, the port and whether the port is open.
        """
        async with semaphore:
            return host, port, await port_open(host, port)

    results = await asyncio.gather(*(check(host, port) for host in hosts for port in ports))
    found: dict[str, list[int]] = defaultdict(list)
    for host, port, is_open in results:
        if is_open:
            found[host].append(port)
    return {host: sorted(ports) for host, ports in found.items()}


async def identify(host: str, open_ports: list[int]) -> tuple[str | None, str | None, int | None]:
    """Ask a host for its device information over ONVIF on the ONVIF ports it has open.

    Args:
        host: Address of the host.
        open_ports: Ports of the host that accepted a connection.

    Returns:
        Manufacturer, model and the ONVIF port that answered. A port that answers with an ONVIF fault
        returns no manufacturer or model but still counts as answered; all three are None when no port answered.
    """
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
    """Identify a host over ONVIF and classify it.

    Args:
        host: Address of the host.
        open_ports: Ports of the host that accepted a connection.
        semaphore: Limit on concurrent ONVIF requests.

    Returns:
        The host with its guessed brand, manufacturer, model and ONVIF port.
    """
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
    """Scan a subnet for cameras.

    Hosts with none of the camera ports open are dropped before the slower ONVIF identification.

    Args:
        network: Subnet to scan.

    Returns:
        Camera candidates sorted by address.
    """
    hosts = [str(address) for address in subnet_hosts(network)]
    found = await sweep(hosts, SCAN_PORTS)
    candidates = {host: ports for host, ports in found.items() if CAMERA_PORTS.intersection(ports)}
    semaphore = asyncio.Semaphore(ONVIF_CONCURRENCY)
    described = await asyncio.gather(*(describe(host, ports, semaphore) for host, ports in candidates.items()))
    return sorted(described, key=lambda item: IPv4Address(item.host))
