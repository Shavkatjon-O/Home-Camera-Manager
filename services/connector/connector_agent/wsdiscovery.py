"""WS-Discovery: the multicast probe that finds ONVIF cameras on the site's network."""

import asyncio
import ipaddress
import socket
import uuid
from dataclasses import dataclass
from urllib.parse import urlsplit
from xml.etree import ElementTree

__all__ = ["Match", "host_key", "parse_matches", "probe", "probe_message"]

GROUP = "239.255.255.250"
PORT = 3702
WAIT_SECONDS = 3.0

ADDRESSING = "http://schemas.xmlsoap.org/ws/2004/08/addressing"
DISCOVERY = "http://schemas.xmlsoap.org/ws/2005/04/discovery"
SOAP = "http://www.w3.org/2003/05/soap-envelope"


@dataclass(frozen=True)
class Match:
    """A device that answered a probe.

    Attributes:
        host: Address of its first ONVIF service.
        port: Port of that service.
        xaddrs: Every service address it announced.
        scopes: Its scopes.
        endpoint: Its endpoint reference.
    """

    host: str
    port: int
    xaddrs: tuple[str, ...]
    scopes: tuple[str, ...]
    endpoint: str


def host_key(host: str) -> tuple:
    """Sort addresses numerically and names after them.

    Args:
        host: Address or name.

    Returns:
        A sort key.
    """
    try:
        return (0, int(ipaddress.ip_address(host)), host)
    except ValueError:
        return (1, 0, host)


def probe_message(message_id: str) -> bytes:
    """Build a probe for ONVIF video transmitters.

    Args:
        message_id: Message id, such as urn:uuid:...

    Returns:
        The SOAP envelope.
    """
    return (
        '<?xml version="1.0" encoding="UTF-8"?>'
        f'<e:Envelope xmlns:e="{SOAP}" xmlns:w="{ADDRESSING}" xmlns:d="{DISCOVERY}" '
        'xmlns:dn="http://www.onvif.org/ver10/network/wsdl">'
        f"<e:Header><w:MessageID>{message_id}</w:MessageID>"
        "<w:To>urn:schemas-xmlsoap-org:ws:2005:04:discovery</w:To>"
        f"<w:Action>{DISCOVERY}/Probe</w:Action></e:Header>"
        "<e:Body><d:Probe><d:Types>dn:NetworkVideoTransmitter</d:Types></d:Probe></e:Body></e:Envelope>"
    ).encode()


def local(tag: str) -> str:
    """Strip the namespace of a tag.

    Args:
        tag: Tag with or without a namespace.

    Returns:
        The local name.
    """
    return tag.rsplit("}", 1)[-1]


def parse_matches(data: bytes, message_id: str | None = None) -> list[Match]:
    """Read the devices of a ProbeMatches answer.

    Args:
        data: The datagram.
        message_id: Id of the probe; answers that relate to another message are ignored.

    Returns:
        The matches that announce an HTTP service address.
    """
    try:
        root = ElementTree.fromstring(data)
    except ElementTree.ParseError:
        return []
    if message_id is not None:
        relates = [element.text for element in root.iter() if local(element.tag) == "RelatesTo"]
        if relates and (relates[0] or "").strip() != message_id:
            return []
    matches = []
    for element in root.iter():
        if local(element.tag) != "ProbeMatch":
            continue
        values = {local(child.tag): child for child in element.iter()}
        xaddrs = tuple((values["XAddrs"].text or "").split()) if "XAddrs" in values else ()
        scopes = tuple((values["Scopes"].text or "").split()) if "Scopes" in values else ()
        endpoint = (values["Address"].text or "").strip() if "Address" in values else ""
        for xaddr in xaddrs:
            parts = urlsplit(xaddr)
            if parts.scheme in ("http", "https") and parts.hostname:
                port = parts.port or (443 if parts.scheme == "https" else 80)
                matches.append(Match(parts.hostname, port, xaddrs, scopes, endpoint))
                break
    return matches


class ProbeProtocol(asyncio.DatagramProtocol):
    """Collects the answers to one probe.

    Attributes:
        message_id: Id of the probe.
        found: Matches by host.
    """

    def __init__(self, message_id: str):
        """Create the collector.

        Args:
            message_id: Id of the probe.
        """
        self.message_id = message_id
        self.found: dict[str, Match] = {}

    def datagram_received(self, data: bytes, addr) -> None:
        """Keep the matches of an answer.

        Args:
            data: The datagram.
            addr: Sender address.
        """
        for match in parse_matches(data, self.message_id):
            self.found.setdefault(match.host, match)


async def probe(interface: str, wait: float = WAIT_SECONDS) -> list[Match]:
    """Send a probe to the WS-Discovery group from one interface and collect the answers.

    The probe leaves with a time to live of 1 from the given interface only, so it never crosses a router or
    reaches another network of this machine.

    Args:
        interface: Local IPv4 address to send from.
        wait: Seconds to collect answers.

    Returns:
        The devices that answered, by address.
    """
    message_id = f"urn:uuid:{uuid.uuid4()}"
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_TTL, 1)
    sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_IF, socket.inet_aton(interface))
    sock.bind((interface, 0))
    sock.setblocking(False)
    loop = asyncio.get_running_loop()
    transport, protocol = await loop.create_datagram_endpoint(lambda: ProbeProtocol(message_id), sock=sock)
    try:
        transport.sendto(probe_message(message_id), (GROUP, PORT))
        await asyncio.sleep(wait)
    finally:
        transport.close()
    return sorted(protocol.found.values(), key=lambda match: host_key(match.host))
