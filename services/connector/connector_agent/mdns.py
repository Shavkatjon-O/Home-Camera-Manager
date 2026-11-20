"""Multicast DNS responder and DNS-SD advertiser for the on-site connector (RFC 6762 and RFC 6763)."""

from __future__ import annotations

import asyncio
import re
import socket
import struct
from dataclasses import dataclass

SERVICE = "_sss-connector._tcp.local."
ENUMERATION = "_services._dns-sd._udp.local."
GROUP = "224.0.0.251"
PORT = 5353
TYPE_A = 1
TYPE_PTR = 12
TYPE_TXT = 16
TYPE_SRV = 33
TYPE_ANY = 255
CLASS_IN = 1
CACHE_FLUSH = 0x8000
UNICAST_BIT = 0x8000
RESPONSE_FLAGS = 0x8400
DEFAULT_TTL = 120
ANNOUNCE_COUNT = 3
MAX_LABEL = 63
MAX_JUMPS = 16
HEADER = struct.Struct("!HHHHHH")


def encode_labels(labels: list[str]) -> bytes:
    """Encode a list of labels as an uncompressed DNS name.

    Args:
        labels: Labels in order, without dots; empty labels are skipped.

    Returns:
        The wire-format name ending with the zero-length root label.

    Raises:
        ValueError: If a label is longer than 63 bytes after UTF-8 encoding.
    """
    out = bytearray()
    for label in labels:
        if not label:
            continue
        raw = label.encode("utf-8")
        if len(raw) > MAX_LABEL:
            raise ValueError(f"label longer than {MAX_LABEL} bytes")
        out.append(len(raw))
        out += raw
    out.append(0)
    return bytes(out)


def encode_name(name: str) -> bytes:
    """Encode a dotted domain name as an uncompressed DNS name.

    Args:
        name: Dotted name with or without a trailing dot.

    Returns:
        The wire-format name ending with the zero-length root label.

    Raises:
        ValueError: If a label is longer than 63 bytes or the whole name exceeds 255 bytes.
    """
    out = encode_labels(name.split("."))
    if len(out) > 255:
        raise ValueError("name longer than 255 bytes")
    return out


def decode_name(data: bytes, offset: int) -> tuple[str, int]:
    """Decode a possibly compressed DNS name.

    Args:
        data: The whole packet.
        offset: Position of the first byte of the name.

    Returns:
        The lower-case dotted name with a trailing dot and the offset just after the name in the original position.

    Raises:
        ValueError: If the name is malformed, truncated or follows too many compression pointers.
    """
    labels: list[str] = []
    jumps = 0
    end = -1
    pos = offset
    while True:
        if pos >= len(data):
            raise ValueError("name runs past the packet")
        length = data[pos]
        if length == 0:
            if end < 0:
                end = pos + 1
            break
        if length & 0xC0 == 0xC0:
            if pos + 1 >= len(data):
                raise ValueError("truncated pointer")
            jumps += 1
            if jumps > MAX_JUMPS:
                raise ValueError("too many compression pointers")
            if end < 0:
                end = pos + 2
            pos = ((length & 0x3F) << 8) | data[pos + 1]
            continue
        if length & 0xC0:
            raise ValueError("unsupported label type")
        if pos + 1 + length > len(data):
            raise ValueError("label runs past the packet")
        labels.append(data[pos + 1 : pos + 1 + length].decode("utf-8", errors="replace").lower())
        pos += 1 + length
    return "".join(label + "." for label in labels), end


def parse_query(data: bytes) -> list[tuple[str, int, bool]]:
    """Parse the questions of an mDNS query packet.

    Args:
        data: A received UDP payload.

    Returns:
        One tuple per question holding the lower-case name with a trailing dot, the query type and whether the
        unicast-response bit is set. The list is empty for responses, truncated packets and garbage.
    """
    try:
        if len(data) < HEADER.size:
            return []
        _, flags, qdcount, _, _, _ = HEADER.unpack_from(data, 0)
        if flags & 0x8000:
            return []
        offset = HEADER.size
        questions = []
        for _ in range(qdcount):
            name, offset = decode_name(data, offset)
            qtype, qclass = struct.unpack_from("!HH", data, offset)
            offset += 4
            questions.append((name, qtype, bool(qclass & UNICAST_BIT)))
        return questions
    except (ValueError, struct.error):
        return []


@dataclass(frozen=True)
class Record:
    """One resource record ready for encoding.

    Attributes:
        name: Owner name in wire format.
        rtype: Record type code.
        rdata: Encoded record data.
        unique: Whether the cache-flush bit is set on the record.
    """

    name: bytes
    rtype: int
    rdata: bytes
    unique: bool


def build_response(records: list[Record], ttl: int) -> bytes:
    """Build an authoritative mDNS response packet.

    Args:
        records: Records for the answer section.
        ttl: Time to live in seconds; zero makes a goodbye.

    Returns:
        The encoded packet with flags 0x8400 and id 0.
    """
    out = bytearray(HEADER.pack(0, RESPONSE_FLAGS, 0, len(records), 0, 0))
    for record in records:
        klass = CLASS_IN | (CACHE_FLUSH if record.unique else 0)
        out += record.name
        out += struct.pack("!HHIH", record.rtype, klass, ttl, len(record.rdata))
        out += record.rdata
    return bytes(out)


def encode_txt(txt: dict[str, str]) -> bytes:
    """Encode TXT key=value pairs as TXT record data.

    Args:
        txt: Pairs to publish.

    Returns:
        Length-prefixed strings, or a single empty string when there are no pairs.
    """
    out = bytearray()
    for key, value in txt.items():
        raw = f"{key}={value}".encode("utf-8")[:255]
        out.append(len(raw))
        out += raw
    return bytes(out) or b"\x00"


def default_hostname(name: str) -> str:
    """Derive a host label from an instance name.

    Args:
        name: The instance name.

    Returns:
        A lower-case label of letters, digits and hyphens followed by ".local.".
    """
    label = re.sub(r"[^a-z0-9]+", "-", name.lower()).strip("-")[:MAX_LABEL] or "sss-connector"
    return f"{label}.local."


def truncate_label(name: str) -> str:
    """Cut a label to 63 UTF-8 bytes without splitting a character.

    Args:
        name: The label text.

    Returns:
        The label that fits the DNS limit.
    """
    return name.encode("utf-8")[:MAX_LABEL].decode("utf-8", errors="ignore")


class Advertiser:
    """Advertises one DNS-SD service instance over multicast DNS.

    Attributes:
        name: Instance label after truncation.
        port: Port of the agent API.
        address: IPv4 address carried by the A record.
        txt: Current TXT key=value pairs.
        hostname: Fully qualified host name ending with ".local.".
        interface: Local IPv4 used for the multicast group, or None for the default interface.
        instance: Fully qualified instance name in lower case.
    """

    def __init__(
        self,
        name: str,
        port: int,
        address: str,
        txt: dict[str, str],
        hostname: str | None = None,
        interface: str | None = None,
    ) -> None:
        """Create an advertiser without touching the network.

        Args:
            name: Instance label; spaces are allowed and it is cut to 63 bytes.
            port: Port of the agent API.
            address: IPv4 address for the A record.
            txt: TXT key=value pairs.
            hostname: Host label; derived from name when omitted.
            interface: Local IPv4 to join the group on and send from.

        Raises:
            ValueError: If the address is not a valid IPv4 address or the host name has an oversized label.
        """
        socket.inet_aton(address)
        self.name = truncate_label(name)
        self.port = port
        self.address = address
        self.txt = dict(txt)
        host = hostname if hostname else default_hostname(self.name)
        self.hostname = host if host.endswith(".") else host + "."
        self.interface = interface
        self.instance = f"{self.name}.{SERVICE}".lower()
        self.instance_wire = encode_labels([self.name])[:-1] + encode_name(SERVICE)
        self.host_wire = encode_name(self.hostname)
        self.transport: asyncio.DatagramTransport | None = None
        self.task: asyncio.Task[None] | None = None

    def ptr(self) -> Record:
        """Build the PTR record from the service type to the instance.

        Returns:
            The shared PTR record.
        """
        return Record(encode_name(SERVICE), TYPE_PTR, self.instance_wire, False)

    def srv(self) -> Record:
        """Build the SRV record of the instance.

        Returns:
            The unique SRV record.
        """
        return Record(self.instance_wire, TYPE_SRV, struct.pack("!HHH", 0, 0, self.port) + self.host_wire, True)

    def txt_record(self) -> Record:
        """Build the TXT record of the instance.

        Returns:
            The unique TXT record.
        """
        return Record(self.instance_wire, TYPE_TXT, encode_txt(self.txt), True)

    def a_record(self) -> Record:
        """Build the A record of the host.

        Returns:
            The unique A record.
        """
        return Record(self.host_wire, TYPE_A, socket.inet_aton(self.address), True)

    def records(self) -> list[Record]:
        """List every record the advertiser publishes.

        Returns:
            The PTR, SRV, TXT and A records.
        """
        return [self.ptr(), self.srv(), self.txt_record(), self.a_record()]

    def records_for(self, qname: str, qtype: int) -> list[Record]:
        """Select the records that answer one question.

        Args:
            qname: Lower-case question name with a trailing dot.
            qtype: Question type code.

        Returns:
            The matching records; PTR answers carry the SRV, TXT and A records of the instance as well. The list is
            empty when the question is not for this advertiser.
        """
        qname = qname.lower()
        if qtype in (TYPE_PTR, TYPE_ANY):
            if qname == SERVICE:
                return self.records()
            if qname == ENUMERATION:
                return [Record(encode_name(ENUMERATION), TYPE_PTR, encode_name(SERVICE), False)]
        if qname == self.instance:
            if qtype == TYPE_SRV:
                return [self.srv(), self.a_record()]
            if qtype == TYPE_TXT:
                return [self.txt_record()]
            if qtype == TYPE_ANY:
                return [self.srv(), self.txt_record(), self.a_record()]
        if qname == self.hostname.lower() and qtype in (TYPE_A, TYPE_ANY):
            return [self.a_record()]
        return []

    def send(self, packet: bytes, destination: tuple[str, int] = (GROUP, PORT)) -> None:
        """Send a packet through the open transport.

        Args:
            packet: The encoded packet.
            destination: Target address; the multicast group by default.
        """
        if self.transport is not None:
            self.transport.sendto(packet, destination)

    def announce(self, ttl: int = DEFAULT_TTL) -> None:
        """Multicast every record once.

        Args:
            ttl: Time to live in seconds; zero sends a goodbye.
        """
        self.send(build_response(self.records(), ttl))

    def open_socket(self) -> socket.socket:
        """Create the multicast socket.

        Returns:
            A non-blocking UDP socket bound to port 5353 and joined to the mDNS group.
        """
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        if hasattr(socket, "SO_REUSEPORT"):
            sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEPORT, 1)
        sock.bind(("0.0.0.0", PORT))
        local = socket.inet_aton(self.interface or "0.0.0.0")
        sock.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP, socket.inet_aton(GROUP) + local)
        if self.interface:
            sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_IF, local)
        sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_TTL, 255)
        sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_LOOP, 1)
        sock.setblocking(False)
        return sock

    async def announce_repeatedly(self) -> None:
        """Send the remaining unsolicited announcements one second apart."""
        for _ in range(ANNOUNCE_COUNT - 1):
            await asyncio.sleep(1)
            self.announce()

    async def start(self) -> None:
        """Open the socket, send the first announcement and schedule the other two.

        Raises:
            OSError: If the socket cannot be bound or the group cannot be joined.
        """
        if self.transport is not None:
            return
        loop = asyncio.get_running_loop()
        sock = self.open_socket()
        transport, _ = await loop.create_datagram_endpoint(lambda: Responder(self), sock=sock)
        self.transport = transport
        self.announce()
        self.task = asyncio.ensure_future(self.announce_repeatedly())

    def update(self, txt: dict[str, str]) -> None:
        """Replace the TXT pairs and announce the change.

        Args:
            txt: The new key=value pairs.
        """
        self.txt = dict(txt)
        self.announce()

    async def stop(self) -> None:
        """Send a goodbye and close the socket."""
        if self.task is not None:
            self.task.cancel()
            self.task = None
        if self.transport is not None:
            self.announce(0)
            self.transport.close()
            self.transport = None


class Responder(asyncio.DatagramProtocol):
    """Datagram protocol answering mDNS queries for one advertiser.

    Attributes:
        advertiser: The advertiser whose records are served.
        transport: The transport used to reply.
    """

    def __init__(self, advertiser: Advertiser) -> None:
        """Bind the protocol to an advertiser.

        Args:
            advertiser: The advertiser to serve.
        """
        self.advertiser = advertiser
        self.transport: asyncio.DatagramTransport | None = None

    def connection_made(self, transport: asyncio.BaseTransport) -> None:
        """Remember the transport.

        Args:
            transport: The datagram transport created by the event loop.
        """
        self.transport = transport  # type: ignore[assignment]

    def datagram_received(self, data: bytes, addr: tuple[str, int]) -> None:
        """Answer the questions in a received packet.

        Args:
            data: The UDP payload.
            addr: Sender address and port.
        """
        if self.transport is None:
            return
        unicast: list[Record] = []
        multicast: list[Record] = []
        for qname, qtype, wants_unicast in parse_query(data):
            found = self.advertiser.records_for(qname, qtype)
            target = unicast if wants_unicast else multicast
            for record in found:
                if record not in target:
                    target.append(record)
        if unicast:
            self.transport.sendto(build_response(unicast, DEFAULT_TTL), addr)
        if multicast:
            self.transport.sendto(build_response(multicast, DEFAULT_TTL), (GROUP, PORT))
