"""Annex-B handling of decrypted video payloads: start code alignment, NAL units and codec identification."""

from enum import StrEnum

__all__ = [
    "Codec",
    "align",
    "h264_type",
    "h265_type",
    "identify_codec",
    "nal_units",
    "parameter_sets",
    "replace_nal",
]

START_CODE = b"\0\0\1"
ALIGN_WINDOW = 16

H265_VPS = 32
H265_SPS = 33
H265_PPS = 34
H265_PARAMETER_SETS = (H265_VPS, H265_SPS, H265_PPS)
H264_SPS = 7
H264_PPS = 8
H264_PARAMETER_SETS = (H264_SPS, H264_PPS)


class Codec(StrEnum):
    """Video codec of a session."""

    H264 = "h264"
    H265 = "h265"


def align(payload: bytes) -> bytes | None:
    """Drop the bytes before the first start code of a payload.

    The start code must begin within the first 16 bytes; a zero byte before a three-byte match makes it a four-byte
    start code.

    Args:
        payload: Decrypted video payload.

    Returns:
        The payload from its start code, or None when there is none within the window, which drops the frame.
    """
    position = payload.find(START_CODE, 0, ALIGN_WINDOW + len(START_CODE) - 1)
    if position < 0:
        return None
    if position > 0 and payload[position - 1] == 0:
        position -= 1
    return payload[position:]


def nal_units(data: bytes) -> list[tuple[int, int, int]]:
    """Find the NAL units of an Annex-B access unit.

    Args:
        data: The access unit.

    Returns:
        For each NAL unit, the offset of its start code, the offset of its first byte and its end offset.
    """
    units = []
    starts = []
    position = data.find(START_CODE)
    while position >= 0:
        code = position - 1 if position > 0 and data[position - 1] == 0 else position
        starts.append((code, position + len(START_CODE)))
        position = data.find(START_CODE, position + len(START_CODE))
    for number, (code, begin) in enumerate(starts):
        end = starts[number + 1][0] if number + 1 < len(starts) else len(data)
        while end > begin and data[end - 1] == 0 and number + 1 < len(starts):
            end -= 1
        units.append((code, begin, end))
    return units


def h265_type(nal: bytes) -> int:
    """Read the H.265 NAL unit type.

    Args:
        nal: The NAL unit from its header.

    Returns:
        Bits 1 to 6 of the first header byte.
    """
    return (nal[0] >> 1) & 0x3F


def h264_type(nal: bytes) -> int:
    """Read the H.264 NAL unit type.

    Args:
        nal: The NAL unit from its header.

    Returns:
        The low five bits of the first byte.
    """
    return nal[0] & 0x1F


def identify_codec(access_unit: bytes) -> Codec | None:
    """Identify the codec from the parameter sets at the start of a key access unit.

    The first NAL unit that is an H.265 parameter set with 0x01 as second header byte means H.265; otherwise the
    first one that is an H.264 parameter set means H.264.

    Args:
        access_unit: An aligned key access unit.

    Returns:
        The codec, or None when the access unit carries no parameter sets.
    """
    for _, begin, end in nal_units(access_unit):
        nal = access_unit[begin:end]
        if not nal:
            continue
        if len(nal) >= 2 and h265_type(nal) in H265_PARAMETER_SETS and nal[1] == 0x01:
            return Codec.H265
        if h264_type(nal) in H264_PARAMETER_SETS:
            return Codec.H264
    return None


def parameter_sets(access_unit: bytes, codec: Codec) -> dict[int, bytes]:
    """Collect the parameter set NAL units of an access unit.

    Args:
        access_unit: The access unit.
        codec: Its codec.

    Returns:
        NAL unit type to the first NAL unit of that type, without start code.
    """
    wanted = H265_PARAMETER_SETS if codec == Codec.H265 else H264_PARAMETER_SETS
    reader = h265_type if codec == Codec.H265 else h264_type
    found = {}
    for _, begin, end in nal_units(access_unit):
        nal = access_unit[begin:end]
        if nal and reader(nal) in wanted and reader(nal) not in found:
            found[reader(nal)] = nal
    return found


def replace_nal(access_unit: bytes, old: bytes, new: bytes) -> bytes:
    """Replace one NAL unit of an access unit, keeping its start code.

    Args:
        access_unit: The access unit.
        old: The NAL unit to replace, without start code.
        new: Its replacement.

    Returns:
        The new access unit, or the old one when the NAL unit is not found.
    """
    for _, begin, end in nal_units(access_unit):
        if access_unit[begin:end] == old:
            return access_unit[:begin] + new + access_unit[end:]
    return access_unit
