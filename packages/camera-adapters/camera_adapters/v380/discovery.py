"""Discovery of V380 cameras on the LAN by UDP broadcast."""

import asyncio
import socket
from dataclasses import dataclass

__all__ = ["DISCOVERY_PORT", "LISTEN_PORT", "SEARCH", "DiscoveredCamera", "discover", "find", "parse_reply"]

SEARCH = b"NVDEVSEARCH^100"
REPLY_TAG = "NVDEVRESULT"
DISCOVERY_PORT = 10008
LISTEN_PORT = 10009
LIMITED_BROADCAST = "255.255.255.255"
MINIMUM_FIELDS = 13
ROUNDS = 5
ROUND_SECONDS = 0.3


@dataclass(frozen=True)
class DiscoveredCamera:
    """A camera that answered a search.

    Attributes:
        host: IPv4 address from the reply, not from the datagram's source.
        mac: Hardware address.
        mask: Subnet mask.
        gateway: Default gateway.
        device_id: Device id.
    """

    host: str
    mac: str
    mask: str
    gateway: str
    device_id: str


def parse_reply(text: str) -> DiscoveredCamera | None:
    """Read a search reply.

    Args:
        text: The datagram as text.

    Returns:
        The camera, or None when the text is not a reply with at least 13 fields.
    """
    fields = [item.strip() for item in text.split("^")]
    if len(fields) < MINIMUM_FIELDS or fields[0] != REPLY_TAG:
        return None
    return DiscoveredCamera(host=fields[3], mac=fields[2], mask=fields[4], gateway=fields[5], device_id=fields[12])


class Listener(asyncio.DatagramProtocol):
    """Collects replies, one per hardware address compared without case, or per device id without one.

    Attributes:
        found: Cameras by hardware address.
    """

    def __init__(self):
        """Create an empty listener."""
        self.found: dict[str, DiscoveredCamera] = {}

    def datagram_received(self, data: bytes, addr) -> None:
        """Keep a valid reply.

        Args:
            data: The datagram.
            addr: Its source, unused because the reply carries the address.
        """
        camera = parse_reply(data.decode("ascii", "replace"))
        if camera is not None:
            self.found.setdefault(camera.mac.upper() or camera.device_id, camera)


def search_socket(port: int) -> socket.socket:
    """Open the search socket with address reuse and broadcast enabled.

    Args:
        port: Local port, 10009 so replies to that port arrive too.

    Returns:
        The bound socket.
    """
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
    sock.bind(("0.0.0.0", port))
    sock.setblocking(False)
    return sock


async def discover(
    broadcasts: tuple[str, ...] = (),
    port: int = DISCOVERY_PORT,
    listen_port: int = LISTEN_PORT,
    rounds: int = ROUNDS,
    round_seconds: float = ROUND_SECONDS,
    limited: bool = True,
) -> list[DiscoveredCamera]:
    """Search the LAN for V380 cameras.

    Args:
        broadcasts: Directed broadcast addresses of the host's interfaces, searched besides 255.255.255.255.
        port: Port the cameras listen on.
        listen_port: Local port of the search socket.
        rounds: Number of searches.
        round_seconds: Seconds to listen after each search.
        limited: Whether to search the limited broadcast address 255.255.255.255 too.

    Returns:
        The cameras that answered, one per hardware address.
    """
    loop = asyncio.get_running_loop()
    transport, listener = await loop.create_datagram_endpoint(Listener, sock=search_socket(listen_port))
    try:
        for _ in range(rounds):
            for address in ((LIMITED_BROADCAST,) if limited else ()) + tuple(broadcasts):
                try:
                    transport.sendto(SEARCH, (address, port))
                except OSError:
                    continue
            await asyncio.sleep(round_seconds)
    finally:
        transport.close()
    return list(listener.found.values())


async def find(device_id: str, broadcasts: tuple[str, ...] = (), **options) -> DiscoveredCamera | None:
    """Find a camera by its device id, for one that moved to another address.

    Args:
        device_id: Device id.
        broadcasts: Directed broadcast addresses to search besides the limited broadcast.
        **options: Further options of discover.

    Returns:
        The camera, or None when it did not answer.
    """
    for camera in await discover(broadcasts, **options):
        if camera.device_id == str(device_id):
            return camera
    return None
