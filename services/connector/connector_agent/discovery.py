"""Discovery on the site's network: WS-Discovery from each site LAN interface plus a sweep of their subnets."""

import asyncio
import ipaddress
import logging
from dataclasses import dataclass, field

from camera_adapters.classifier import guess_brand, guess_onvif_port
from camera_adapters.fingerprint import onvif_identity
from camera_adapters.sweep import CAMERA_PORTS, SCAN_PORTS, parse_subnet, subnet_hosts, sweep

from connector_agent import wsdiscovery
from connector_agent.interfaces import LocalNetwork, sweep_subnets

__all__ = ["Candidate", "discover", "merge"]

logger = logging.getLogger(__name__)

IDENTIFY_CONCURRENCY = 16


@dataclass
class Candidate:
    """A camera candidate as the backend receives it.

    Attributes:
        host: Address on the site's network.
        open_ports: Ports that accepted a connection.
        brand: Guessed adapter name.
        manufacturer: Manufacturer reported over ONVIF.
        model: Model reported over ONVIF.
        onvif_port: ONVIF port.
        found_by: wsd, sweep or both.
        scopes: WS-Discovery scopes.
    """

    host: str
    open_ports: list[int] = field(default_factory=list)
    brand: str | None = None
    manufacturer: str | None = None
    model: str | None = None
    onvif_port: int | None = None
    found_by: str = "sweep"
    scopes: list[str] = field(default_factory=list)

    def report(self) -> dict:
        """Return the candidate as the discovery report carries it.

        Returns:
            The fields as a mapping.
        """
        return {
            "host": self.host,
            "open_ports": sorted(set(self.open_ports)),
            "brand": self.brand,
            "manufacturer": self.manufacturer,
            "model": self.model,
            "onvif_port": self.onvif_port,
            "found_by": self.found_by,
            "scopes": self.scopes,
        }


def merge(matches: list[wsdiscovery.Match], swept: dict[str, list[int]], allowed: list) -> dict[str, Candidate]:
    """Combine the probe's answers with the sweep's open ports, keeping only addresses of the allowed networks.

    Args:
        matches: Devices that answered the probe.
        swept: Open ports by address.
        allowed: Networks discovery may report from.

    Returns:
        Candidates by address; one found both ways is marked both.
    """

    def inside(host: str) -> bool:
        """Tell whether an address belongs to an allowed network.

        Args:
            host: The address.

        Returns:
            True when it does.
        """
        try:
            address = ipaddress.ip_address(host)
        except ValueError:
            return False
        return any(address in network for network in allowed)

    candidates: dict[str, Candidate] = {}
    for host, ports in swept.items():
        if CAMERA_PORTS.intersection(ports) and inside(host):
            candidates[host] = Candidate(host=host, open_ports=list(ports))
    for match in matches:
        if not inside(match.host):
            continue
        candidate = candidates.get(match.host)
        if candidate is None:
            candidates[match.host] = Candidate(
                host=match.host, open_ports=[match.port], found_by="wsd", scopes=list(match.scopes)
            )
            continue
        candidate.found_by = "both"
        candidate.scopes = list(match.scopes)
        if match.port not in candidate.open_ports:
            candidate.open_ports.append(match.port)
    return candidates


async def discover(
    networks: list[LocalNetwork], allowed_subnets: tuple[str, ...] = (), wait: float = wsdiscovery.WAIT_SECONDS
) -> list[Candidate]:
    """Find the cameras on the site's network.

    Each site LAN interface sends a WS-Discovery probe and its subnet is swept at the same time; only addresses of
    those networks are reported, and every candidate is identified over ONVIF without credentials.

    Args:
        networks: The interfaces discovery uses, already filtered.
        allowed_subnets: Subnets configured explicitly.
        wait: Seconds to collect probe answers.

    Returns:
        The candidates by address.
    """
    subnets = sweep_subnets(networks, allowed_subnets)
    allowed = [ipaddress.ip_network(value, strict=False) for value in subnets]
    hosts: list[str] = []
    for subnet in subnets:
        try:
            hosts.extend(str(address) for address in subnet_hosts(parse_subnet(subnet)))
        except ValueError as exc:
            logger.warning("Skipping subnet %s: %s", subnet, exc)
    probes = [wsdiscovery.probe(network.address, wait) for network in networks]
    results = await asyncio.gather(*probes, sweep(hosts, SCAN_PORTS) if hosts else asyncio.sleep(0, result={}))
    matches = [match for found in results[:-1] for match in found]
    candidates = merge(matches, results[-1], allowed)
    semaphore = asyncio.Semaphore(IDENTIFY_CONCURRENCY)

    async def identify(candidate: Candidate) -> None:
        """Identify one candidate over ONVIF once a slot is free.

        Args:
            candidate: The candidate, filled in place.
        """
        ports = sorted(set(candidate.open_ports))
        async with semaphore:
            manufacturer, model, _, answered = await onvif_identity(candidate.host, ports)
        brand = guess_brand(ports, manufacturer, answered)
        candidate.brand = brand.value if brand else None
        candidate.manufacturer = manufacturer
        candidate.model = model
        candidate.onvif_port = guess_onvif_port(brand, ports, answered)

    await asyncio.gather(*(identify(candidate) for candidate in candidates.values()))
    return [candidates[host] for host in sorted(candidates, key=wsdiscovery.host_key)]
