"""Sequence parameter sets: emulation prevention, picture size and the low-latency reorder rewrite."""

from dataclasses import dataclass

from camera_adapters.v380.annexb import (
    H264_SPS,
    H265_SPS,
    Codec,
    h264_type,
    h265_type,
    parameter_sets,
    replace_nal,
)

__all__ = [
    "BitReader",
    "BitWriter",
    "H265Sps",
    "SpsError",
    "insert_emulation",
    "parse_h264_size",
    "parse_h265_sps",
    "picture_size",
    "remove_emulation",
    "rewrite_access_unit",
    "rewrite_reorder",
]

HIGH_PROFILES = frozenset({100, 110, 122, 244, 44, 83, 86, 118, 128, 138, 139, 134, 135})


class SpsError(ValueError):
    """A parameter set could not be parsed."""


def remove_emulation(data: bytes) -> bytes:
    """Remove emulation prevention bytes: every 03 that follows two zero bytes.

    Args:
        data: A NAL unit.

    Returns:
        Its raw byte sequence payload.
    """
    out = bytearray()
    zeros = 0
    for byte in data:
        if zeros >= 2 and byte == 3:
            zeros = 0
            continue
        out.append(byte)
        zeros = zeros + 1 if byte == 0 else 0
    return bytes(out)


def insert_emulation(data: bytes) -> bytes:
    """Insert emulation prevention bytes wherever two zero bytes would be followed by a byte of 0 to 3.

    Args:
        data: A raw byte sequence payload.

    Returns:
        The NAL unit bytes.
    """
    out = bytearray()
    zeros = 0
    for byte in data:
        if zeros >= 2 and byte <= 3:
            out.append(3)
            zeros = 0
        out.append(byte)
        zeros = zeros + 1 if byte == 0 else 0
    return bytes(out)


class BitReader:
    """Reads bits most significant first.

    Attributes:
        data: The bytes.
        position: Next bit position.
    """

    def __init__(self, data: bytes, position: int = 0):
        """Create a reader.

        Args:
            data: The bytes.
            position: First bit to read.
        """
        self.data = data
        self.position = position

    def bit(self) -> int:
        """Read one bit.

        Returns:
            The bit.

        Raises:
            SpsError: The data ended.
        """
        if self.position >= len(self.data) * 8:
            raise SpsError("The parameter set ended early")
        value = (self.data[self.position >> 3] >> (7 - (self.position & 7))) & 1
        self.position += 1
        return value

    def bits(self, count: int) -> int:
        """Read an unsigned value.

        Args:
            count: Number of bits.

        Returns:
            The value.
        """
        value = 0
        for _ in range(count):
            value = (value << 1) | self.bit()
        return value

    def skip(self, count: int) -> None:
        """Skip bits.

        Args:
            count: Number of bits.

        Raises:
            SpsError: The data ended.
        """
        if self.position + count > len(self.data) * 8:
            raise SpsError("The parameter set ended early")
        self.position += count

    def ue(self) -> int:
        """Read an unsigned Exp-Golomb value.

        Returns:
            The value.

        Raises:
            SpsError: The code is longer than 31 leading zeros.
        """
        zeros = 0
        while self.bit() == 0:
            zeros += 1
            if zeros > 31:
                raise SpsError("An Exp-Golomb code is too long")
        return (1 << zeros) - 1 + self.bits(zeros)

    def se(self) -> int:
        """Read a signed Exp-Golomb value.

        Returns:
            The value.
        """
        code = self.ue()
        return (code + 1) // 2 if code & 1 else -(code // 2)


class BitWriter:
    """Writes bits most significant first.

    Attributes:
        out: Completed bytes.
        current: Bits of the byte being filled.
        filled: Number of those bits.
    """

    def __init__(self):
        """Create an empty writer."""
        self.out = bytearray()
        self.current = 0
        self.filled = 0

    def bit(self, value: int) -> None:
        """Write one bit.

        Args:
            value: 0 or 1.
        """
        self.current = (self.current << 1) | (value & 1)
        self.filled += 1
        if self.filled == 8:
            self.out.append(self.current)
            self.current = 0
            self.filled = 0

    def finish(self) -> bytes:
        """Write the stop bit, pad with zero bits to a byte boundary and return the bytes.

        Returns:
            The bytes.
        """
        self.bit(1)
        while self.filled:
            self.bit(0)
        return bytes(self.out)


@dataclass(frozen=True)
class H265Sps:
    """What the client reads from an H.265 SPS.

    Attributes:
        width: Picture width after the conformance window.
        height: Picture height after the conformance window.
        chroma_format: chroma_format_idc.
        reorder_fields: Bit position and length of every sps_max_num_reorder_pics, counted in the raw byte sequence
            payload from the first bit of the NAL header.
        reorder_values: The value of each of those fields.
    """

    width: int
    height: int
    chroma_format: int
    reorder_fields: tuple[tuple[int, int], ...]
    reorder_values: tuple[int, ...]


def skip_profile_tier_level(reader: BitReader, max_sub_layers_minus1: int) -> None:
    """Skip a profile_tier_level structure with its general profile present.

    Args:
        reader: Reader positioned at the structure.
        max_sub_layers_minus1: sps_max_sub_layers_minus1.
    """
    reader.skip(96)
    profile_present = []
    level_present = []
    for _ in range(max_sub_layers_minus1):
        profile_present.append(reader.bit())
        level_present.append(reader.bit())
    if max_sub_layers_minus1 > 0:
        reader.skip(2 * (8 - max_sub_layers_minus1))
    for number in range(max_sub_layers_minus1):
        if profile_present[number]:
            reader.skip(88)
        if level_present[number]:
            reader.skip(8)


def sub_sizes(chroma_format: int) -> tuple[int, int]:
    """Return SubWidthC and SubHeightC.

    Args:
        chroma_format: chroma_format_idc.

    Returns:
        The horizontal and vertical chroma subsampling factors.
    """
    width = 2 if chroma_format in (1, 2) else 1
    height = 2 if chroma_format == 1 else 1
    return width, height


def parse_h265_sps(nal: bytes) -> H265Sps:
    """Parse an H.265 SPS NAL unit up to its sub-layer ordering info.

    Args:
        nal: The SPS NAL unit with its two-byte header, without start code.

    Returns:
        The picture size and the reorder fields.

    Raises:
        SpsError: The parameter set is not an H.265 SPS or ends early.
    """
    if len(nal) < 3 or h265_type(nal) != H265_SPS:
        raise SpsError("Not an H.265 SPS")
    reader = BitReader(remove_emulation(nal), 16)
    reader.skip(4)
    max_sub_layers_minus1 = reader.bits(3)
    reader.skip(1)
    skip_profile_tier_level(reader, max_sub_layers_minus1)
    reader.ue()
    chroma_format = reader.ue()
    if chroma_format == 3:
        reader.skip(1)
    width = reader.ue()
    height = reader.ue()
    if reader.bit():
        left, right, top, bottom = reader.ue(), reader.ue(), reader.ue(), reader.ue()
        sub_width, sub_height = sub_sizes(chroma_format)
        width -= sub_width * (left + right)
        height -= sub_height * (top + bottom)
    reader.ue()
    reader.ue()
    reader.ue()
    ordering_present = reader.bit()
    fields = []
    values = []
    for _ in range(0 if ordering_present else max_sub_layers_minus1, max_sub_layers_minus1 + 1):
        reader.ue()
        start = reader.position
        values.append(reader.ue())
        fields.append((start, reader.position - start))
        reader.ue()
    return H265Sps(
        width=width,
        height=height,
        chroma_format=chroma_format,
        reorder_fields=tuple(fields),
        reorder_values=tuple(values),
    )


def stop_bit(rbsp: bytes) -> int:
    """Find the position of the stop bit, the last 1 bit of a raw byte sequence payload.

    Args:
        rbsp: The payload.

    Returns:
        Its bit position.

    Raises:
        SpsError: The payload has no 1 bit.
    """
    for index in range(len(rbsp) - 1, -1, -1):
        byte = rbsp[index]
        if byte:
            return index * 8 + 7 - ((byte & -byte).bit_length() - 1)
    raise SpsError("The parameter set has no stop bit")


def rewrite_reorder(nal: bytes) -> bytes:
    """Rewrite every sps_max_num_reorder_pics of an H.265 SPS to 0.

    Only valid for streams that never reorder pictures; every other field stays as it is.

    Args:
        nal: The SPS NAL unit, without start code.

    Returns:
        The rewritten NAL unit, or the same bytes when every field is already 0.
    """
    parsed = parse_h265_sps(nal)
    if not any(parsed.reorder_values):
        return nal
    rbsp = remove_emulation(nal)
    reader = BitReader(rbsp)
    writer = BitWriter()
    end = stop_bit(rbsp)
    position = 0
    for start, length in parsed.reorder_fields:
        while position < start:
            writer.bit(reader.bit())
            position += 1
        writer.bit(1)
        reader.skip(length)
        position += length
    while position < end:
        writer.bit(reader.bit())
        position += 1
    return insert_emulation(writer.finish())


def parse_h264_size(nal: bytes) -> tuple[int, int]:
    """Read the picture size of an H.264 SPS.

    Args:
        nal: The SPS NAL unit with its header byte, without start code.

    Returns:
        Width and height after cropping.

    Raises:
        SpsError: The parameter set is not an H.264 SPS or ends early.
    """
    if len(nal) < 4 or h264_type(nal) != H264_SPS:
        raise SpsError("Not an H.264 SPS")
    reader = BitReader(remove_emulation(nal), 8)
    profile = reader.bits(8)
    reader.skip(16)
    reader.ue()
    chroma_format = 1
    separate_planes = 0
    if profile in HIGH_PROFILES:
        chroma_format = reader.ue()
        if chroma_format == 3:
            separate_planes = reader.bit()
        reader.ue()
        reader.ue()
        reader.skip(1)
        if reader.bit():
            for number in range(8 if chroma_format != 3 else 12):
                if reader.bit():
                    size = 16 if number < 6 else 64
                    last = next_scale = 8
                    for _ in range(size):
                        if next_scale:
                            next_scale = (last + reader.se() + 256) % 256
                        last = next_scale or last
    reader.ue()
    order_type = reader.ue()
    if order_type == 0:
        reader.ue()
    elif order_type == 1:
        reader.skip(1)
        reader.se()
        reader.se()
        for _ in range(reader.ue()):
            reader.se()
    reader.ue()
    reader.skip(1)
    width_mbs = reader.ue() + 1
    height_units = reader.ue() + 1
    frame_mbs_only = reader.bit()
    if not frame_mbs_only:
        reader.skip(1)
    reader.skip(1)
    width = width_mbs * 16
    height = (2 - frame_mbs_only) * height_units * 16
    if reader.bit():
        left, right, top, bottom = reader.ue(), reader.ue(), reader.ue(), reader.ue()
        if chroma_format == 0 or separate_planes:
            unit_x, unit_y = 1, 2 - frame_mbs_only
        else:
            sub_width, sub_height = sub_sizes(chroma_format)
            unit_x, unit_y = sub_width, sub_height * (2 - frame_mbs_only)
        width -= unit_x * (left + right)
        height -= unit_y * (top + bottom)
    return width, height


def picture_size(access_unit: bytes, codec: Codec) -> tuple[int, int] | None:
    """Read the picture size from the SPS of a key access unit.

    Args:
        access_unit: The access unit.
        codec: Its codec.

    Returns:
        Width and height, or None when it has no SPS that parses.
    """
    sets = parameter_sets(access_unit, codec)
    try:
        if codec == Codec.H265 and H265_SPS in sets:
            parsed = parse_h265_sps(sets[H265_SPS])
            return parsed.width, parsed.height
        if codec == Codec.H264 and H264_SPS in sets:
            return parse_h264_size(sets[H264_SPS])
    except SpsError:
        return None
    return None


def rewrite_access_unit(access_unit: bytes) -> bytes:
    """Apply the reorder rewrite to the H.265 SPS of an access unit.

    Args:
        access_unit: An H.265 key access unit.

    Returns:
        The access unit with its SPS rewritten, or unchanged when it has none or it does not parse.
    """
    sets = parameter_sets(access_unit, Codec.H265)
    if H265_SPS not in sets:
        return access_unit
    try:
        rewritten = rewrite_reorder(sets[H265_SPS])
    except SpsError:
        return access_unit
    if rewritten == sets[H265_SPS]:
        return access_unit
    return replace_nal(access_unit, sets[H265_SPS], rewritten)
