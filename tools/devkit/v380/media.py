"""Media the simulator serves: access units from Annex-B files or generated ones, and generated audio."""

import math
from collections.abc import Iterator
from dataclasses import dataclass

__all__ = [
    "AccessUnit",
    "ExpGolomb",
    "adpcm_encode",
    "alaw_encode",
    "file_access_units",
    "h264_access_units",
    "h264_sps",
    "h265_access_units",
    "sine",
    "split_access_units",
]

START = b"\0\0\0\1"

SUB_VPS = bytes.fromhex("40010c01ffff01400000030090000003000003005a95980900")
SUB_SPS = bytes.fromhex(
    "42010101400000030090000003000003005aa0050200b459e96e44a5735010202e10000003001000000300e5457fde103e805dd7c20104"
)
MAIN_SPS = bytes.fromhex(
    "420101014000000300900000030000030096a0012020028859e96e44a5735010202e10000003001000000300e5457fde103e805dd7c20104"
)
PPS = bytes.fromhex("4401c172b46240")
SIZES = {"sub": (640, 720), "main": (2304, 2592)}

H264_PPS = bytes.fromhex("68ce3c80")

ADPCM_STEPS = (
    7, 8, 9, 10, 11, 12, 13, 14, 16, 17, 19, 21, 23, 25, 28, 31, 34, 37, 41, 45, 50, 55, 60, 66, 73, 80, 88, 97,
    107, 118, 130, 143, 157, 173, 190, 209, 230, 253, 279, 307, 337, 371, 408, 449, 494, 544, 598, 658, 724, 796,
    876, 963, 1060, 1166, 1282, 1411, 1552, 1707, 1878, 2066, 2272, 2499, 2749, 3024, 3327, 3660, 4026, 4428,
    4871, 5358, 5894, 6484, 7132, 7845, 8630, 9493, 10442, 11487, 12635, 13899, 15289, 16818, 18500, 20350,
    22385, 24623, 27086, 29794, 32767,
)  # fmt: skip
ADPCM_INDEX = (-1, -1, -1, -1, 2, 4, 6, 8)


@dataclass(frozen=True)
class AccessUnit:
    """One picture's NAL units in Annex-B format.

    Attributes:
        data: The access unit, starting with a start code.
        key: Whether it is a key picture with its parameter sets.
        codec: h265 or h264.
    """

    data: bytes
    key: bool
    codec: str


def nal_units(data: bytes) -> list[bytes]:
    """Split an Annex-B byte stream into NAL units.

    Args:
        data: The byte stream.

    Returns:
        The NAL units without start codes.
    """
    units = []
    positions = []
    index = data.find(b"\0\0\1")
    while index >= 0:
        positions.append(index + 3)
        index = data.find(b"\0\0\1", index + 3)
    for number, begin in enumerate(positions):
        end = positions[number + 1] - 3 if number + 1 < len(positions) else len(data)
        unit = data[begin:end]
        if number + 1 < len(positions):
            unit = unit.rstrip(b"\0")
        if unit:
            units.append(unit)
    return units


def split_access_units(data: bytes, codec: str) -> list[AccessUnit]:
    """Group the NAL units of an elementary stream into access units.

    A picture starts at an H.265 VCL NAL unit with first_slice_segment_in_pic_flag set, or at an H.264 slice with
    first_mb_in_slice 0; parameter sets and other NAL units before it belong to it.

    Args:
        data: The elementary stream.
        codec: h265 or h264.

    Returns:
        The access units.
    """
    units: list[AccessUnit] = []
    current: list[bytes] = []
    pending: list[bytes] = []
    has_picture = False
    key = False

    def flush() -> None:
        """Emit the current access unit."""
        if current and has_picture:
            units.append(AccessUnit(b"".join(START + nal for nal in current), key, codec))

    for nal in nal_units(data):
        if codec == "h265":
            kind = (nal[0] >> 1) & 0x3F
            vcl = kind < 32
            first = vcl and len(nal) > 2 and nal[2] & 0x80
            irap = 16 <= kind <= 23
            suffix = kind in (38, 40)
        else:
            kind = nal[0] & 0x1F
            vcl = 1 <= kind <= 5
            first = vcl and len(nal) > 1 and nal[1] & 0x80
            irap = kind == 5
            suffix = False
        if vcl and first:
            flush()
            current, has_picture, key = pending + [nal], True, irap
            pending = []
        elif vcl:
            current += pending + [nal]
            pending = []
            key = key or irap
        elif suffix and has_picture:
            current.append(nal)
        else:
            pending.append(nal)
    flush()
    return units


def file_access_units(path: str) -> list[AccessUnit]:
    """Read an Annex-B H.265 or H.264 file whose key pictures repeat their parameter sets.

    Args:
        path: The file.

    Returns:
        Its access units, starting at the first key picture.

    Raises:
        ValueError: The file holds no key picture.
    """
    with open(path, "rb") as handle:
        data = handle.read()
    first = nal_units(data[:4096])
    codec = "h265" if first and ((first[0][0] >> 1) & 0x3F) in (32, 33, 34, 35, 39) else "h264"
    units = split_access_units(data, codec)
    while units and not units[0].key:
        units.pop(0)
    if not units:
        raise ValueError(f"{path} holds no key picture")
    return units


def filler(seed: int, size: int) -> bytes:
    """Make deterministic slice bytes without zero bytes, so no start code or emulation can appear.

    Args:
        seed: Frame number.
        size: Number of bytes.

    Returns:
        The bytes.
    """
    return bytes(1 + (seed * 31 + index * 7) % 255 for index in range(size))


def h265_access_units(stream: str, gop: int, key_size: int, size: int) -> Iterator[AccessUnit]:
    """Generate synthetic H.265 access units that carry real parameter sets and placeholder slices.

    Args:
        stream: main or sub, which selects the SPS and size.
        gop: Frames per key frame.
        key_size: Slice bytes of a key frame.
        size: Slice bytes of another frame.

    Yields:
        Access units without end.
    """
    sps = MAIN_SPS if stream == "main" else SUB_SPS
    number = 0
    while True:
        if number % gop == 0:
            data = START + SUB_VPS + START + sps + START + PPS + START + b"\x26\x01\x80" + filler(number, key_size)
            yield AccessUnit(data, True, "h265")
        else:
            yield AccessUnit(START + b"\x02\x01\x80" + filler(number, size), False, "h265")
        number += 1


class ExpGolomb:
    """Writes bits and Exp-Golomb codes most significant first.

    Attributes:
        bits: The bits written.
    """

    def __init__(self):
        """Create an empty writer."""
        self.bits: list[int] = []

    def put(self, value: int, count: int) -> None:
        """Write an unsigned value.

        Args:
            value: The value.
            count: Number of bits.
        """
        self.bits += [(value >> shift) & 1 for shift in range(count - 1, -1, -1)]

    def ue(self, value: int) -> None:
        """Write an unsigned Exp-Golomb code.

        Args:
            value: The value.
        """
        code = value + 1
        self.put(0, code.bit_length() - 1)
        self.put(code, code.bit_length())

    def bytes(self) -> bytes:
        """Finish with the stop bit and zero padding.

        Returns:
            The bytes.
        """
        bits = self.bits + [1]
        bits += [0] * (-len(bits) % 8)
        return bytes(int("".join(map(str, bits[index : index + 8])), 2) for index in range(0, len(bits), 8))


def h264_sps(width: int, height: int) -> bytes:
    """Build a baseline H.264 SPS for a size that is a multiple of 16.

    Args:
        width: Picture width.
        height: Picture height.

    Returns:
        The SPS NAL unit with its header byte.
    """
    writer = ExpGolomb()
    writer.put(66, 8)
    writer.put(0, 8)
    writer.put(30, 8)
    writer.ue(0)
    writer.ue(0)
    writer.ue(2)
    writer.ue(1)
    writer.put(0, 1)
    writer.ue(width // 16 - 1)
    writer.ue(height // 16 - 1)
    writer.put(1, 1)
    writer.put(1, 1)
    writer.put(0, 1)
    writer.put(0, 1)
    return b"\x67" + writer.bytes()


def h264_access_units(gop: int, key_size: int, size: int) -> Iterator[AccessUnit]:
    """Generate synthetic H.264 access units, 640x480, with placeholder slices.

    Args:
        gop: Frames per key frame.
        key_size: Slice bytes of a key frame.
        size: Slice bytes of another frame.

    Yields:
        Access units without end.
    """
    sps = h264_sps(640, 480)
    number = 0
    while True:
        if number % gop == 0:
            data = START + sps + START + H264_PPS + START + b"\x65\x88" + filler(number, key_size)
            yield AccessUnit(data, True, "h264")
        else:
            yield AccessUnit(START + b"\x41\x9a" + filler(number, size), False, "h264")
        number += 1


def sine(count: int, start: int, frequency: float = 440.0, rate: int = 8000, level: int = 8000) -> list[int]:
    """Make samples of a tone.

    Args:
        count: Number of samples.
        start: Index of the first sample, so blocks continue each other.
        frequency: Tone frequency.
        rate: Sample rate.
        level: Peak amplitude.

    Returns:
        16-bit samples.
    """
    return [int(level * math.sin(2 * math.pi * frequency * (start + index) / rate)) for index in range(count)]


def adpcm_encode(samples: list[int], index: int = 0) -> bytes:
    """Encode one IMA ADPCM block: the first sample, the step index, a reserved byte and 4-bit codes.

    Args:
        samples: An odd number of samples; the first goes into the header.
        index: Starting step index.

    Returns:
        The block.
    """
    predicted = samples[0]
    out = bytearray(predicted.to_bytes(2, "little", signed=True) + bytes([index, 0]))
    codes = []
    for sample in samples[1:]:
        step = ADPCM_STEPS[index]
        diff = sample - predicted
        code = 8 if diff < 0 else 0
        diff = abs(diff)
        delta = step >> 3
        if diff >= step:
            code |= 4
            diff -= step
            delta += step
        if diff >= step >> 1:
            code |= 2
            diff -= step >> 1
            delta += step >> 1
        if diff >= step >> 2:
            code |= 1
            delta += step >> 2
        predicted = predicted - delta if code & 8 else predicted + delta
        predicted = min(max(predicted, -32768), 32767)
        index = min(max(index + ADPCM_INDEX[code & 7], 0), len(ADPCM_STEPS) - 1)
        codes.append(code)
    if len(codes) % 2:
        codes.append(0)
    for low, high in zip(codes[0::2], codes[1::2]):
        out.append(low | (high << 4))
    return bytes(out)


def alaw_encode(samples: list[int]) -> bytes:
    """Encode samples as G.711 A-law.

    Args:
        samples: 16-bit samples.

    Returns:
        One byte per sample.
    """
    out = bytearray()
    for sample in samples:
        sign = 0x80 if sample >= 0 else 0
        magnitude = min(sample if sample >= 0 else -sample - 1, 32767) >> 3
        if magnitude < 32:
            code = magnitude >> 1
        else:
            exponent = magnitude.bit_length() - 5
            code = (exponent << 4) | ((magnitude >> exponent) & 0x0F)
        out.append((sign | code) ^ 0x55)
    return bytes(out)


def adts_frames(path: str) -> list[bytes]:
    """Read the ADTS frames of an AAC file.

    Args:
        path: The file.

    Returns:
        The frames, headers included.
    """
    with open(path, "rb") as handle:
        data = handle.read()
    frames = []
    offset = 0
    while offset + 7 <= len(data) and data[offset] == 0xFF and data[offset + 1] & 0xF0 == 0xF0:
        length = ((data[offset + 3] & 0x03) << 11) | (data[offset + 4] << 3) | (data[offset + 5] >> 5)
        if length < 7:
            break
        frames.append(data[offset : offset + length])
        offset += length
    return frames


def placeholder_adts(number: int) -> bytes:
    """Make an ADTS frame of AAC LC, 8 kHz, mono, 263 bytes, with a placeholder payload.

    Args:
        number: Frame number, which varies the payload.

    Returns:
        The frame.
    """
    return bytes.fromhex("fff96c4020fffc") + bytes((number + index) % 256 for index in range(256))
