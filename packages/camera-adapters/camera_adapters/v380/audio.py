"""Audio payloads of the V380 LAN protocol: IMA ADPCM blocks, G.711 A-law and AAC in ADTS frames."""

from dataclasses import dataclass
from enum import StrEnum

from camera_adapters.v380.framing import FrameType

__all__ = [
    "AudioFormat",
    "Adts",
    "adpcm_decode",
    "alaw_decode",
    "alaw_encode",
    "audio_format",
    "parse_adts",
    "pcm_bytes",
]

STEPS = (
    7, 8, 9, 10, 11, 12, 13, 14, 16, 17, 19, 21, 23, 25, 28, 31, 34, 37, 41, 45, 50, 55, 60, 66, 73, 80, 88, 97,
    107, 118, 130, 143, 157, 173, 190, 209, 230, 253, 279, 307, 337, 371, 408, 449, 494, 544, 598, 658, 724, 796,
    876, 963, 1060, 1166, 1282, 1411, 1552, 1707, 1878, 2066, 2272, 2499, 2749, 3024, 3327, 3660, 4026, 4428,
    4871, 5358, 5894, 6484, 7132, 7845, 8630, 9493, 10442, 11487, 12635, 13899, 15289, 16818, 18500, 20350,
    22385, 24623, 27086, 29794, 32767,
)  # fmt: skip
INDEX_CHANGES = (-1, -1, -1, -1, 2, 4, 6, 8)

SAMPLE_RATES = (96000, 88200, 64000, 48000, 44100, 32000, 24000, 22050, 16000, 12000, 11025, 8000, 7350)


class AudioFormat(StrEnum):
    """Formats of the audio the client outputs."""

    ALAW = "alaw"
    PCM = "pcm_s16le"
    AAC = "aac_adts"


def audio_format(frame_type: int) -> AudioFormat | None:
    """Map an audio frame type to the output format.

    Args:
        frame_type: Frame type of the fragment header.

    Returns:
        The format, or None for a type that is not audio.
    """
    return {
        FrameType.ALAW: AudioFormat.ALAW,
        FrameType.ADPCM: AudioFormat.PCM,
        FrameType.AAC: AudioFormat.AAC,
    }.get(frame_type)


def adpcm_decode(block: bytes) -> list[int]:
    """Decode one IMA ADPCM block.

    The block starts with the first sample as i16, the step index as u8 and a reserved byte, followed by 4-bit
    codes, the low nibble first.

    Args:
        block: The block, at least 4 bytes.

    Returns:
        The samples, the header sample first.
    """
    if len(block) < 4:
        return []
    sample = int.from_bytes(block[0:2], "little", signed=True)
    index = min(max(block[2], 0), len(STEPS) - 1)
    samples = [sample]
    for byte in block[4:]:
        for code in (byte & 0x0F, byte >> 4):
            step = STEPS[index]
            diff = step >> 3
            if code & 4:
                diff += step
            if code & 2:
                diff += step >> 1
            if code & 1:
                diff += step >> 2
            sample = sample - diff if code & 8 else sample + diff
            sample = min(max(sample, -32768), 32767)
            index = min(max(index + INDEX_CHANGES[code & 7], 0), len(STEPS) - 1)
            samples.append(sample)
    return samples


def pcm_bytes(samples: list[int]) -> bytes:
    """Pack samples as 16-bit little-endian PCM.

    Args:
        samples: The samples.

    Returns:
        The bytes.
    """
    return b"".join(sample.to_bytes(2, "little", signed=True) for sample in samples)


def alaw_decode(data: bytes) -> list[int]:
    """Decode G.711 A-law bytes.

    Args:
        data: One byte per sample.

    Returns:
        The linear samples.
    """
    samples = []
    for byte in data:
        value = byte ^ 0x55
        exponent = (value >> 4) & 0x07
        mantissa = value & 0x0F
        if exponent == 0:
            linear = (mantissa << 4) + 8
        else:
            linear = ((mantissa << 4) + 0x108) << (exponent - 1)
        samples.append(linear if value & 0x80 else -linear)
    return samples


def alaw_encode(samples: list[int]) -> bytes:
    """Encode linear samples as G.711 A-law.

    Args:
        samples: 16-bit samples.

    Returns:
        One byte per sample.
    """
    out = bytearray()
    for sample in samples:
        sign = 0x80 if sample >= 0 else 0x00
        magnitude = min(sample if sample >= 0 else -sample - 1, 32767) >> 3
        if magnitude < 32:
            code = magnitude >> 1
        else:
            exponent = magnitude.bit_length() - 5
            code = (exponent << 4) | ((magnitude >> exponent) & 0x0F)
        out.append((sign | code) ^ 0x55)
    return bytes(out)


@dataclass(frozen=True)
class Adts:
    """An ADTS header.

    Attributes:
        object_type: MPEG-4 audio object type, 2 for AAC LC.
        frequency_index: Sampling frequency index.
        sample_rate: Sampling rate in Hz, 0 for an unknown index.
        channels: Channel configuration.
        header_size: 7 without CRC, 9 with it.
        frame_length: Frame length including the header.
    """

    object_type: int
    frequency_index: int
    sample_rate: int
    channels: int
    header_size: int
    frame_length: int

    @property
    def config(self) -> bytes:
        """The matching AudioSpecificConfig.

        Returns:
            Two bytes: object type, frequency index and channel configuration.
        """
        value = (self.object_type << 11) | (self.frequency_index << 7) | (self.channels << 3)
        return value.to_bytes(2, "big")


def parse_adts(data: bytes) -> Adts | None:
    """Read the ADTS header at the start of a frame.

    Args:
        data: The frame.

    Returns:
        The header, or None without a valid sync word.
    """
    if len(data) < 7 or data[0] != 0xFF or data[1] & 0xF0 != 0xF0:
        return None
    index = (data[2] >> 2) & 0x0F
    return Adts(
        object_type=((data[2] >> 6) & 0x03) + 1,
        frequency_index=index,
        sample_rate=SAMPLE_RATES[index] if index < len(SAMPLE_RATES) else 0,
        channels=((data[2] & 0x01) << 2) | (data[3] >> 6),
        header_size=7 if data[1] & 0x01 else 9,
        frame_length=((data[3] & 0x03) << 11) | (data[4] << 3) | (data[5] >> 5),
    )
