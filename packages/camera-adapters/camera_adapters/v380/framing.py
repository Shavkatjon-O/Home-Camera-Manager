"""Media framing of the V380 LAN protocol: fragment headers, resynchronisation, reassembly and frame headers."""

from dataclasses import dataclass, field
from enum import IntEnum

from camera_adapters.v380.errors import FramingLost

__all__ = [
    "AUDIO_TYPES",
    "FRAGMENT_HEADER_SIZE",
    "FRAME_HEADER_SIZE",
    "MAX_FRAGMENT",
    "VIDEO_TYPES",
    "Fragment",
    "FragmentHeader",
    "FragmentReader",
    "Frame",
    "FrameHeader",
    "FrameType",
    "Reassembler",
    "fragment_header",
    "frame_header",
    "parse_fragment_header",
    "parse_frame_header",
]

MARKER = 0x7F
FRAGMENT_HEADER_SIZE = 12
FRAME_HEADER_SIZE = 16
MAX_FRAGMENT = 20000
MAX_INVALID_HEADERS = 64
MAX_SKIPPED_BYTES = 1 << 20


class FrameType(IntEnum):
    """Frame types of the fragment header."""

    H264_KEY = 0x00
    H264 = 0x01
    H265_KEY = 0x28
    H265 = 0x29
    ADPCM = 0x16
    AAC = 0x18
    ALAW = 0x1A


VIDEO_TYPES = frozenset({FrameType.H264_KEY, FrameType.H264, FrameType.H265_KEY, FrameType.H265})
AUDIO_TYPES = frozenset({FrameType.ADPCM, FrameType.AAC, FrameType.ALAW})
KEY_TYPES = frozenset({FrameType.H264_KEY, FrameType.H265_KEY})


@dataclass(frozen=True)
class FragmentHeader:
    """The 12-byte header before each fragment's payload.

    Attributes:
        type: Frame type.
        count: Number of fragments in the frame.
        index: Index of this fragment, from 0.
        length: Payload length in bytes.
    """

    type: int
    count: int
    index: int
    length: int


@dataclass(frozen=True)
class Fragment:
    """A fragment with its payload.

    Attributes:
        header: Its header.
        payload: Its payload.
    """

    header: FragmentHeader
    payload: bytes


def parse_fragment_header(data: bytes) -> FragmentHeader | None:
    """Read and validate a fragment header.

    Args:
        data: At least 12 bytes.

    Returns:
        The header, or None when it is not valid: no marker, a count below 1, an index not below the count, or a
        length outside 1 to 20000.
    """
    if len(data) < FRAGMENT_HEADER_SIZE or data[0] != MARKER:
        return None
    count = int.from_bytes(data[3:5], "little")
    index = int.from_bytes(data[5:7], "little")
    length = int.from_bytes(data[7:9], "little")
    if count < 1 or index >= count or not 1 <= length <= MAX_FRAGMENT:
        return None
    return FragmentHeader(type=data[1], count=count, index=index, length=length)


def fragment_header(header: FragmentHeader) -> bytes:
    """Build a fragment header with the unknown bytes zero.

    Args:
        header: The fields.

    Returns:
        The 12 bytes.
    """
    return (
        bytes([MARKER, header.type, 0])
        + header.count.to_bytes(2, "little")
        + header.index.to_bytes(2, "little")
        + header.length.to_bytes(2, "little")
        + bytes(3)
    )


class FragmentReader:
    """Cuts the stream connection's bytes into fragments, resynchronising on invalid headers.

    On an invalid header the reader scans forward byte by byte for a marker that starts a valid header, and never
    reads a payload for an invalid header. It gives up after 64 consecutive invalid headers that start with the
    marker, or after a megabyte without a valid header.

    Attributes:
        buffer: Bytes received and not yet cut.
        invalid: Consecutive invalid headers seen.
        skipped: Bytes skipped since the last valid header.
        resyncs: Times the reader lost and searched for its place.
    """

    def __init__(self):
        """Create an empty reader."""
        self.buffer = bytearray()
        self.invalid = 0
        self.skipped = 0
        self.resyncs = 0

    def feed(self, data: bytes) -> list[Fragment]:
        """Add received bytes and return the fragments they complete.

        Args:
            data: Bytes from the connection.

        Returns:
            Complete fragments in arrival order.

        Raises:
            FramingLost: The framing could not be recovered within the bounds.
        """
        self.buffer += data
        fragments = []
        while len(self.buffer) >= FRAGMENT_HEADER_SIZE:
            header = parse_fragment_header(self.buffer)
            if header is None:
                self.skip()
                continue
            end = FRAGMENT_HEADER_SIZE + header.length
            if len(self.buffer) < end:
                break
            fragments.append(Fragment(header, bytes(self.buffer[FRAGMENT_HEADER_SIZE:end])))
            del self.buffer[:end]
            self.invalid = 0
            self.skipped = 0
        return fragments

    def skip(self) -> None:
        """Drop bytes up to the next marker after an invalid header.

        Raises:
            FramingLost: Too many invalid headers or skipped bytes.
        """
        if self.invalid == 0 and self.skipped == 0:
            self.resyncs += 1
        if self.buffer[0] == MARKER:
            self.invalid += 1
        position = self.buffer.find(MARKER, 1)
        drop = position if position > 0 else len(self.buffer)
        del self.buffer[:drop]
        self.skipped += drop
        if self.invalid >= MAX_INVALID_HEADERS or self.skipped >= MAX_SKIPPED_BYTES:
            raise FramingLost("The camera's byte stream lost its framing")


@dataclass(frozen=True)
class Frame:
    """A reassembled frame: its 16-byte frame header and media payload.

    Attributes:
        type: Frame type.
        data: The whole frame, header included.
    """

    type: int
    data: bytes

    @property
    def video(self) -> bool:
        """Whether the frame is video.

        Returns:
            True for the video frame types.
        """
        return self.type in VIDEO_TYPES

    @property
    def key(self) -> bool:
        """Whether the frame is a key frame.

        Returns:
            True for the key frame types.
        """
        return self.type in KEY_TYPES

    @property
    def header(self) -> "FrameHeader":
        """The frame header.

        Returns:
            Its fields.
        """
        return parse_frame_header(self.data)

    @property
    def payload(self) -> bytes:
        """The media payload after the frame header.

        Returns:
            The payload, still encrypted when the session is.
        """
        return self.data[FRAME_HEADER_SIZE:]


@dataclass
class Partial:
    """A frame being reassembled.

    Attributes:
        type: Frame type.
        count: Fragment count.
        next: Next expected index.
        parts: Payloads so far.
    """

    type: int
    count: int
    next: int = 0
    parts: list[bytes] = field(default_factory=list)


class Reassembler:
    """Reassembles video and audio frames independently and strictly in index order.

    Attributes:
        partial: The frame being built per kind, video or audio.
        dropped: Frames dropped because of a missing, repeated or reordered fragment or a changed count.
        short: Complete frames dropped for being shorter than the frame header.
    """

    def __init__(self):
        """Create an empty reassembler."""
        self.partial: dict[str, Partial | None] = {"video": None, "audio": None}
        self.dropped = 0
        self.short = 0

    def push(self, fragment: Fragment) -> Frame | None:
        """Add a fragment.

        Args:
            fragment: The fragment; types other than video and audio are ignored.

        Returns:
            The completed frame, or None.
        """
        header = fragment.header
        if header.type in VIDEO_TYPES:
            kind = "video"
        elif header.type in AUDIO_TYPES:
            kind = "audio"
        else:
            return None
        current = self.partial[kind]
        if header.index == 0:
            current = Partial(type=header.type, count=header.count)
        elif current is None or header.count != current.count or header.index != current.next:
            if current is not None:
                self.dropped += 1
            self.partial[kind] = None
            return None
        current.parts.append(fragment.payload)
        current.next += 1
        if current.next < current.count:
            self.partial[kind] = current
            return None
        self.partial[kind] = None
        data = b"".join(current.parts)
        if len(data) < FRAME_HEADER_SIZE:
            self.short += 1
            return None
        return Frame(type=current.type, data=data)


@dataclass(frozen=True)
class FrameHeader:
    """The 16-byte header that starts every frame.

    Attributes:
        number: Frame number, assumed to count up.
        inner_type: Inner frame type, meaning unknown.
        rate: Frame rate in frames per second, unverified.
        timestamp: Camera timestamp, assumed milliseconds; never used as presentation time unchecked.
    """

    number: int
    inner_type: int
    rate: int
    timestamp: int


def parse_frame_header(data: bytes) -> FrameHeader:
    """Read a frame header.

    Args:
        data: At least 16 bytes.

    Returns:
        The fields.
    """
    return FrameHeader(
        number=int.from_bytes(data[0:4], "little"),
        inner_type=int.from_bytes(data[4:6], "little"),
        rate=int.from_bytes(data[6:8], "little"),
        timestamp=int.from_bytes(data[8:16], "little"),
    )


def frame_header(header: FrameHeader) -> bytes:
    """Build a frame header.

    Args:
        header: The fields.

    Returns:
        The 16 bytes.
    """
    return (
        header.number.to_bytes(4, "little")
        + header.inner_type.to_bytes(2, "little")
        + header.rate.to_bytes(2, "little")
        + header.timestamp.to_bytes(8, "little")
    )
