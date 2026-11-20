"""Fixed-size records of the V380 LAN protocol: login, stream login, start and control commands.

Every integer is little-endian and many fields sit at unaligned offsets, so records are packed and read with
int.to_bytes and int.from_bytes at explicit offsets.
"""

from dataclasses import dataclass
from enum import IntEnum, StrEnum

from camera_adapters.v380.errors import ProtocolError

__all__ = [
    "ACCEPTED",
    "DEFAULT_PORT",
    "LOGIN_REPLY_SIZE",
    "LOGIN_SIZE",
    "STREAM_LOGIN_REPLY_SIZE",
    "STREAM_LOGIN_SIZE",
    "LightMode",
    "LoginReply",
    "PictureMode",
    "PtzMove",
    "Stream",
    "StreamLoginReply",
    "flip_record",
    "light_record",
    "login_request",
    "parse_login_reply",
    "parse_stream_login_reply",
    "picture_record",
    "ptz_record",
    "siren_record",
    "start_request",
    "stream_login_request",
]

DEFAULT_PORT = 8800

LOGIN_COMMAND = 1167
LOGIN_REPLY_COMMAND = 1168
STREAM_LOGIN_COMMAND = 301
STREAM_LOGIN_REPLY_COMMAND = 401
START_COMMAND = 303

LOGIN_SIZE = 520
LOGIN_REPLY_SIZE = 256
LOGIN_REPLY_MINIMUM = 21
STREAM_LOGIN_SIZE = 256
STREAM_LOGIN_REPLY_SIZE = 412
STREAM_LOGIN_REPLY_MINIMUM = 8
START_SIZE = 256
CONTROL_SIZE = 16

ACCEPTED = 1001
STREAM_REFUSALS = (-11, -12)

SOUND_ON = 4097
SOUND_OFF = 4096

PTZ_COMMAND = 0xAA
PTZ_IDLE = 1000
LIGHT_COMMAND = 0xC4
SIREN_COMMAND = 0xB9
PICTURE_COMMAND = 0xC5
FLIP_COMMAND = 0xBE


class Stream(IntEnum):
    """Stream value of the stream login."""

    SUB = 0
    MAIN = 1


class PtzMove(StrEnum):
    """Moves of the PTZ command; one axis at a time."""

    LEFT = "left"
    RIGHT = "right"
    UP = "up"
    DOWN = "down"
    STOP = "stop"


class LightMode(StrEnum):
    """Modes of the light command."""

    ON = "on"
    OFF = "off"
    AUTO = "auto"


class PictureMode(StrEnum):
    """Modes of the picture command."""

    COLOUR = "colour"
    BLACK_AND_WHITE = "black_and_white"
    AUTO = "auto"


PTZ_AXES = {
    PtzMove.LEFT: (1001, PTZ_IDLE),
    PtzMove.RIGHT: (1002, PTZ_IDLE),
    PtzMove.UP: (PTZ_IDLE, 1003),
    PtzMove.DOWN: (PTZ_IDLE, 1004),
    PtzMove.STOP: (PTZ_IDLE, PTZ_IDLE),
}
LIGHT_VALUES = {LightMode.ON: 1001, LightMode.OFF: 1002, LightMode.AUTO: 1003}
PICTURE_VALUES = {PictureMode.COLOUR: 1001, PictureMode.BLACK_AND_WHITE: 1002, PictureMode.AUTO: 1003}


def put(record: bytearray, offset: int, size: int, value: int, signed: bool = False) -> None:
    """Write an integer into a record.

    Args:
        record: The record.
        offset: Byte offset.
        size: Width in bytes.
        value: The value.
        signed: Whether the field is two's complement.
    """
    record[offset : offset + size] = value.to_bytes(size, "little", signed=signed)


def get(data: bytes, offset: int, size: int, signed: bool = False) -> int:
    """Read an integer from a record, reading bytes past the end as zero.

    Args:
        data: The record.
        offset: Byte offset.
        size: Width in bytes.
        signed: Whether the field is two's complement.

    Returns:
        The value.
    """
    return int.from_bytes(data[offset : offset + size].ljust(size, b"\0"), "little", signed=signed)


def text(record: bytearray, offset: int, size: int, value: str) -> None:
    """Write zero-padded ASCII text into a record, truncating what does not fit.

    Args:
        record: The record.
        offset: Byte offset.
        size: Field size.
        value: The text.
    """
    record[offset : offset + size] = value.encode("ascii")[:size].ljust(size, b"\0")


def login_request(device_id: int, username: str, field: bytes) -> bytes:
    """Build the 520-byte login request.

    Args:
        device_id: Device id from the camera's label.
        username: User name, admin on these cameras.
        field: The 64-byte encrypted password field.

    Returns:
        The record.
    """
    record = bytearray(LOGIN_SIZE)
    put(record, 0, 4, LOGIN_COMMAND)
    put(record, 4, 4, 120)
    put(record, 8, 1, 31)
    put(record, 9, 4, 1)
    put(record, 13, 4, device_id)
    text(record, 49, 32, username)
    record[81:145] = field
    return bytes(record)


@dataclass(frozen=True)
class LoginReply:
    """The camera's login reply.

    Attributes:
        result: 1001 when accepted.
        device_version: Device version, which selects the media encryption.
        ticket: Ticket the stream login carries and the media key derives from.
        session_id: Session id, unused on the LAN.
        device_type: Device type, meaning unknown.
        camera_type: Camera type, meaning unknown.
        vendor_id: Vendor id, meaning unknown.
        domain: Domain name, when the reply carries one.
    """

    result: int
    device_version: int
    ticket: int
    session_id: int
    device_type: int = 0
    camera_type: int = 0
    vendor_id: int = 0
    domain: str = ""

    @property
    def accepted(self) -> bool:
        """Whether the login was accepted.

        Returns:
            True for result 1001.
        """
        return self.result == ACCEPTED

    @property
    def encrypted(self) -> bool:
        """Whether the session's media is encrypted.

        Returns:
            True for a device version above 30.
        """
        return self.device_version > 30


def parse_login_reply(data: bytes) -> LoginReply:
    """Read a login reply of at least 21 bytes.

    Args:
        data: The bytes received.

    Returns:
        The reply.

    Raises:
        ProtocolError: The reply is shorter than 21 bytes or of another command.
    """
    if len(data) < LOGIN_REPLY_MINIMUM or get(data, 0, 4) != LOGIN_REPLY_COMMAND:
        raise ProtocolError("The camera sent no valid login reply")
    domain = b""
    if get(data, 25, 1) == 1:
        domain = data[26:58].split(b"\0", 1)[0]
    return LoginReply(
        result=get(data, 4, 4),
        device_version=get(data, 12, 1),
        ticket=get(data, 13, 4),
        session_id=get(data, 17, 4),
        device_type=get(data, 21, 1),
        camera_type=get(data, 22, 1),
        vendor_id=get(data, 23, 2),
        domain=domain.decode("ascii", "replace"),
    )


def stream_login_request(device_id: int, ticket: int, sound: bool, stream: Stream) -> bytes:
    """Build the 256-byte stream login request.

    Args:
        device_id: Device id.
        ticket: Ticket of the preceding login.
        sound: Whether to ask for audio.
        stream: Main or sub stream.

    Returns:
        The record.
    """
    record = bytearray(STREAM_LOGIN_SIZE)
    put(record, 0, 4, STREAM_LOGIN_COMMAND)
    put(record, 4, 4, device_id)
    put(record, 12, 2, 20)
    put(record, 14, 4, ticket)
    put(record, 22, 4, SOUND_ON if sound else SOUND_OFF)
    put(record, 26, 4, int(stream))
    return bytes(record)


@dataclass(frozen=True)
class StreamLoginReply:
    """The camera's stream login reply; fields past the received length read as zero.

    Attributes:
        result: Result; -11 and -12 mean refused.
        comm_version: Communication version.
        width: Picture width, a fallback when the parameter sets cannot be read.
        height: Picture height, the same.
        packet_size: Largest packet size, meaning unverified.
        audio_rate_code: Audio sample rate code, meaning unverified.
        audio_sample_size: Audio sample size, meaning unverified.
        audio_channels: Audio channels, meaning unverified.
    """

    result: int
    comm_version: int
    width: int = 0
    height: int = 0
    packet_size: int = 0
    audio_rate_code: int = 0
    audio_sample_size: int = 0
    audio_channels: int = 0

    @property
    def accepted(self) -> bool:
        """Whether the stream login was accepted.

        Returns:
            False for -11 and -12, True for every other result.
        """
        return self.result not in STREAM_REFUSALS


def parse_stream_login_reply(data: bytes) -> StreamLoginReply:
    """Read a stream login reply of at least 8 bytes.

    Args:
        data: The bytes received, up to 412.

    Returns:
        The reply.

    Raises:
        ProtocolError: The reply is shorter than 8 bytes or of another command.
    """
    if len(data) < STREAM_LOGIN_REPLY_MINIMUM or get(data, 0, 4) != STREAM_LOGIN_REPLY_COMMAND:
        raise ProtocolError("The camera sent no valid stream login reply")
    return StreamLoginReply(
        result=get(data, 4, 4, signed=True),
        comm_version=get(data, 8, 2),
        width=get(data, 10, 4),
        height=get(data, 14, 4),
        packet_size=get(data, 18, 4),
        audio_rate_code=get(data, 22, 1),
        audio_sample_size=get(data, 23, 1),
        audio_channels=get(data, 24, 1),
    )


def start_request() -> bytes:
    """Build the 256-byte start request.

    Returns:
        The record.
    """
    record = bytearray(START_SIZE)
    put(record, 0, 4, START_COMMAND)
    put(record, 4, 2, 0x3001)
    return bytes(record)


def ptz_record(move: PtzMove) -> bytes:
    """Build a 16-byte PTZ record.

    Args:
        move: The move, or stop.

    Returns:
        The record.
    """
    pan, tilt = PTZ_AXES[PtzMove(move)]
    record = bytearray(CONTROL_SIZE)
    put(record, 0, 4, PTZ_COMMAND)
    put(record, 4, 2, PTZ_IDLE)
    put(record, 6, 2, PTZ_IDLE)
    put(record, 8, 2, pan)
    put(record, 10, 2, tilt)
    put(record, 14, 2, 1)
    return bytes(record)


def switch_record(command: int, value: int, second: int) -> bytes:
    """Build a 16-byte record of four u32 fields: command, value, second value and zero.

    Args:
        command: Command code.
        value: Value.
        second: Second value.

    Returns:
        The record.
    """
    record = bytearray(CONTROL_SIZE)
    put(record, 0, 4, command)
    put(record, 4, 4, value)
    put(record, 8, 4, second)
    return bytes(record)


def light_record(mode: LightMode) -> bytes:
    """Build a light record.

    Args:
        mode: on, off or auto.

    Returns:
        The record.
    """
    return switch_record(LIGHT_COMMAND, LIGHT_VALUES[LightMode(mode)], 256)


def siren_record(on: bool) -> bytes:
    """Build a siren record.

    Args:
        on: Whether the record keeps the siren sounding; siren on must repeat every 500 ms.

    Returns:
        The record.
    """
    return switch_record(SIREN_COMMAND, 1001, 2) if on else switch_record(SIREN_COMMAND, 1002, 1)


def picture_record(mode: PictureMode) -> bytes:
    """Build a picture mode record.

    Args:
        mode: colour, black_and_white or auto.

    Returns:
        The record.
    """
    return switch_record(PICTURE_COMMAND, PICTURE_VALUES[PictureMode(mode)], 256)


def flip_record() -> bytes:
    """Build the flip record, which turns the picture by 180 degrees.

    Returns:
        The record.
    """
    return switch_record(FLIP_COMMAND, 1000, 0)
