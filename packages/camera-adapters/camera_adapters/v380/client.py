"""The V380 LAN protocol client: login, stream login, start, media and control commands of one session."""

import asyncio
import logging
import socket
import time
from collections.abc import AsyncIterator, Callable
from dataclasses import dataclass, field

from camera_adapters.v380 import records
from camera_adapters.v380.annexb import Codec, align, identify_codec
from camera_adapters.v380.audio import AudioFormat, adpcm_decode, audio_format, parse_adts, pcm_bytes
from camera_adapters.v380.crypto import MediaCipher, media_key, password_field
from camera_adapters.v380.errors import (
    LoginRefused,
    ProtocolError,
    ReplyTimeout,
    SessionLost,
    StreamRefused,
    Unreachable,
    V380Error,
)
from camera_adapters.v380.framing import (
    AUDIO_TYPES,
    FragmentReader,
    Frame,
    FrameType,
    Reassembler,
)
from camera_adapters.v380.records import LightMode, LoginReply, PictureMode, PtzMove, Stream, StreamLoginReply
from camera_adapters.v380.sps import picture_size, rewrite_access_unit

__all__ = [
    "AudioFrame",
    "Camera",
    "Facts",
    "MediaDecoder",
    "Session",
    "Timeouts",
    "VideoFrame",
    "first_key_frame",
    "login",
    "read_reply",
]

logger = logging.getLogger(__name__)

RECEIVE_BUFFER = 128 * 1024
SEND_BUFFER = 64 * 1024
READ_SIZE = 64 * 1024
SIREN_REPEAT_SECONDS = 0.5
MAX_MOVE_SECONDS = 30.0
MAX_RATE = 120
SIZE_RANGE = range(16, 8193)

H265_TYPES = (FrameType.H265_KEY, FrameType.H265)
H264_TYPES = (FrameType.H264_KEY, FrameType.H264)


@dataclass(frozen=True)
class Camera:
    """How to reach and log in to one camera.

    Attributes:
        host: Address of the camera.
        device_id: Device id from its label.
        password: Its password.
        username: Its user name, admin on these cameras.
        port: TCP port, 8800 unless forwarded.
    """

    host: str
    device_id: int
    password: str
    username: str = "admin"
    port: int = records.DEFAULT_PORT


@dataclass(frozen=True)
class Timeouts:
    """Timers of a session, in seconds.

    Attributes:
        connect: TCP connect, each connection.
        first_byte: First byte of a reply.
        gap: Idle gap that ends a reply.
        silence: Media silence after which the session counts as lost.
    """

    connect: float = 5.0
    first_byte: float = 5.0
    gap: float = 0.25
    silence: float = 15.0


@dataclass
class Facts:
    """What a session learned about its camera and stream.

    Attributes:
        device_version: Device version from the login reply.
        comm_version: Communication version from the stream login reply.
        encrypted: Whether the media is encrypted.
        stream: main or sub.
        sound: Whether audio was asked for.
        codec: Video codec, once the first key frame arrived.
        width: Picture width from the SPS, or the stream login reply as a fallback.
        height: Picture height, the same.
        rate: Frame rate the frame headers report.
        audio: Audio format, once the first audio frame arrived.
        audio_config: AudioSpecificConfig of AAC audio, as hex.
        frames: Video frames delivered.
        dropped: Frames dropped for a missing, repeated or reordered fragment.
        misaligned: Video frames dropped for having no start code.
        foreign: Video frames dropped for being of the other codec.
        resyncs: Times the framing was searched for.
    """

    device_version: int = 0
    comm_version: int = 0
    encrypted: bool = False
    stream: str = "sub"
    sound: bool = False
    codec: str | None = None
    width: int | None = None
    height: int | None = None
    rate: int | None = None
    audio: str | None = None
    audio_config: str | None = None
    frames: int = 0
    dropped: int = 0
    misaligned: int = 0
    foreign: int = 0
    resyncs: int = 0


@dataclass(frozen=True)
class VideoFrame:
    """A decrypted, aligned video access unit in Annex-B format.

    Attributes:
        data: The access unit, from its first start code.
        key: Whether it is a key frame carrying its parameter sets.
        codec: Its codec.
        arrival: Monotonic clock at arrival, the timing source of the output.
        number: Frame number from the frame header.
    """

    data: bytes
    key: bool
    codec: Codec
    arrival: float
    number: int = 0


@dataclass(frozen=True)
class AudioFrame:
    """A decrypted audio frame in the output format of its type.

    Attributes:
        format: alaw, pcm_s16le or aac_adts.
        data: A-law bytes, 16-bit little-endian PCM decoded from IMA ADPCM, or the ADTS frame as received.
        arrival: Monotonic clock at arrival.
    """

    format: AudioFormat
    data: bytes
    arrival: float


@dataclass
class MediaDecoder:
    """Turns the stream connection's bytes into output frames: framing, reassembly, decryption and alignment.

    Attributes:
        cipher: Media cipher, None for clear media.
        sound: Whether audio was asked for; audio frames are ignored otherwise.
        low_latency: Whether to apply the reorder rewrite to every key frame, for a client that renders live.
        facts: Facts it keeps up to date.
        fallback: Picture size from the stream login reply.
        reader: Fragment reader.
        assembler: Frame reassembler.
        started: Whether the first key frame has been delivered.
        family: Codec family of the first key frame's frame type, which later frame types must match.
        clock: Source of arrival times.
    """

    cipher: MediaCipher | None
    sound: bool
    low_latency: bool = False
    facts: Facts = field(default_factory=Facts)
    fallback: tuple[int, int] | None = None
    reader: FragmentReader = field(default_factory=FragmentReader)
    assembler: Reassembler = field(default_factory=Reassembler)
    started: bool = False
    family: Codec | None = None
    clock: Callable[[], float] = time.monotonic

    def feed(self, data: bytes) -> list[VideoFrame | AudioFrame]:
        """Add bytes from the stream connection.

        Args:
            data: The bytes.

        Returns:
            The frames they complete, in completion order.

        Raises:
            FramingLost: The framing could not be recovered.
        """
        out = []
        try:
            fragments = self.reader.feed(data)
        finally:
            self.facts.resyncs = self.reader.resyncs
        for fragment in fragments:
            frame = self.assembler.push(fragment)
            self.facts.dropped = self.assembler.dropped
            if frame is None:
                continue
            result = self.video(frame) if frame.video else self.audio(frame)
            if result is not None:
                out.append(result)
        return out

    def video(self, frame: Frame) -> VideoFrame | None:
        """Decrypt, align and check a video frame.

        Args:
            frame: The reassembled frame.

        Returns:
            The output frame, or None when it is dropped.
        """
        if not self.started and not frame.key:
            return None
        payload = self.cipher.decrypt_video(frame.payload) if self.cipher else frame.payload
        aligned = align(payload)
        if aligned is None:
            self.facts.misaligned += 1
            return None
        codec = self.codec(frame, aligned)
        if codec is None:
            return None
        if frame.key:
            size = picture_size(aligned, codec) or self.fallback
            if size:
                self.facts.width, self.facts.height = size
            if self.low_latency and codec == Codec.H265:
                aligned = rewrite_access_unit(aligned)
        header = frame.header
        if 0 < header.rate <= MAX_RATE:
            self.facts.rate = header.rate
        self.started = True
        self.facts.frames += 1
        return VideoFrame(data=aligned, key=frame.key, codec=codec, arrival=self.clock(), number=header.number)

    def codec(self, frame: Frame, aligned: bytes) -> Codec | None:
        """Fix the session's codec and frame type family at the first key frame and keep the other codec out.

        The codec comes from the first key frame's NAL units, or from its frame type when they name none. Later
        frames whose frame type is of the other family are dropped, and so are later key frames whose NAL units
        name another codec.

        Args:
            frame: The frame.
            aligned: Its aligned payload.

        Returns:
            The codec, or None when the frame must be dropped.
        """
        by_type = Codec.H265 if frame.type in H265_TYPES else Codec.H264
        current = Codec(self.facts.codec) if self.facts.codec else None
        if current is None:
            current = identify_codec(aligned) or by_type
            self.facts.codec = current.value
            self.family = by_type
            return current
        if by_type != self.family or (frame.key and (identify_codec(aligned) or current) != current):
            self.facts.foreign += 1
            return None
        return current

    def audio(self, frame: Frame) -> AudioFrame | None:
        """Decrypt and decode an audio frame.

        Args:
            frame: The reassembled frame.

        Returns:
            The output frame, or None when audio was not asked for.
        """
        if not self.sound or frame.type not in AUDIO_TYPES:
            return None
        payload = self.cipher.decrypt_audio(frame.payload) if self.cipher else frame.payload
        kind = audio_format(frame.type)
        if kind == AudioFormat.PCM:
            payload = pcm_bytes(adpcm_decode(payload))
        elif kind == AudioFormat.AAC and self.facts.audio_config is None:
            adts = parse_adts(payload)
            if adts is not None:
                self.facts.audio_config = adts.config.hex()
        self.facts.audio = kind.value
        return AudioFrame(format=kind, data=payload, arrival=self.clock())


async def read_reply(reader: asyncio.StreamReader, maximum: int, timeouts: Timeouts) -> bytes:
    """Read a control-plane reply, which has no length field.

    The read ends when the maximum size has arrived, when the connection closes, or when no byte follows for the
    idle gap after the first one.

    Args:
        reader: The connection.
        maximum: Expected maximum size.
        timeouts: Timers.

    Returns:
        The bytes received.

    Raises:
        ReplyTimeout: No byte arrived in time.
    """
    data = bytearray()
    while len(data) < maximum:
        try:
            chunk = await asyncio.wait_for(
                reader.read(maximum - len(data)), timeouts.gap if data else timeouts.first_byte
            )
        except TimeoutError:
            if not data:
                raise ReplyTimeout("The camera did not reply in time")
            break
        if not chunk:
            break
        data += chunk
    if not data:
        raise ReplyTimeout("The camera closed the connection without a reply")
    return bytes(data)


async def connect(camera: Camera, timeouts: Timeouts) -> tuple[asyncio.StreamReader, asyncio.StreamWriter]:
    """Open a TCP connection to a camera.

    Args:
        camera: The camera.
        timeouts: Timers.

    Returns:
        The reader and writer.

    Raises:
        Unreachable: The connection failed or timed out.
    """
    try:
        return await asyncio.wait_for(asyncio.open_connection(camera.host, camera.port), timeouts.connect)
    except (OSError, TimeoutError) as exc:
        raise Unreachable(f"No V380 camera answers at {camera.host}:{camera.port} ({type(exc).__name__})")


async def close(writer: asyncio.StreamWriter) -> None:
    """Close a connection, ignoring errors.

    Args:
        writer: Its writer.
    """
    writer.close()
    try:
        await writer.wait_closed()
    except OSError:
        pass


async def login(camera: Camera, timeouts: Timeouts = Timeouts(), key: bytes | None = None) -> LoginReply:
    """Log in on a login connection of its own and close it.

    Args:
        camera: The camera.
        timeouts: Timers.
        key: Random key of the password field, drawn fresh when omitted.

    Returns:
        The accepted reply.

    Raises:
        Unreachable: The camera did not accept the connection.
        ReplyTimeout: It did not reply.
        ProtocolError: The reply was short or of another command, or the password is not printable ASCII.
        LoginRefused: It refused the login.
    """
    try:
        field = password_field(camera.password, key)
    except ValueError as exc:
        raise ProtocolError(str(exc))
    request = records.login_request(camera.device_id, camera.username, field)
    reader, writer = await connect(camera, timeouts)
    try:
        writer.write(request)
        await writer.drain()
        reply = records.parse_login_reply(await read_reply(reader, records.LOGIN_REPLY_SIZE, timeouts))
    except OSError as exc:
        raise ProtocolError(f"The login connection failed ({type(exc).__name__})")
    finally:
        await close(writer)
    if not reply.accepted:
        raise LoginRefused(reply.result)
    return reply


class Session:
    """One stream session: a login, then a stream connection carrying media and control commands.

    Use it as an async context manager or call open and close. The session writes control records one at a time,
    sends a stop before closing while a move runs, and stops a move by itself after MAX_MOVE_SECONDS.

    Attributes:
        camera: The camera.
        stream: Main or sub stream.
        sound: Whether to ask for audio.
        low_latency: Whether to rewrite the reorder declaration of every key frame.
        timeouts: Timers.
        facts: What the session learned.
        login_reply: The login reply.
        stream_reply: The stream login reply.
        decoder: Media decoder.
        reader: Stream connection reader.
        writer: Stream connection writer.
        lock: Serialises control writes.
        moving: Whether a move runs.
        move_stop: Task that stops a forgotten move.
        siren_task: Task that keeps the siren sounding.
        max_move: Seconds after which a move stops by itself, None for never.
    """

    def __init__(
        self,
        camera: Camera,
        stream: Stream = Stream.SUB,
        sound: bool = False,
        low_latency: bool = False,
        timeouts: Timeouts = Timeouts(),
        max_move: float | None = MAX_MOVE_SECONDS,
    ):
        """Create a session, not yet open.

        Args:
            camera: The camera.
            stream: Main or sub stream.
            sound: Whether to ask for audio.
            low_latency: Whether to rewrite the reorder declaration of every key frame.
            timeouts: Timers.
            max_move: Seconds after which a move stops by itself, None for never.
        """
        self.camera = camera
        self.stream = Stream(stream)
        self.sound = sound
        self.low_latency = low_latency
        self.timeouts = timeouts
        self.max_move = max_move
        self.facts = Facts(stream="main" if self.stream == Stream.MAIN else "sub", sound=sound)
        self.login_reply: LoginReply | None = None
        self.stream_reply: StreamLoginReply | None = None
        self.decoder: MediaDecoder | None = None
        self.reader: asyncio.StreamReader | None = None
        self.writer: asyncio.StreamWriter | None = None
        self.lock = asyncio.Lock()
        self.moving = False
        self.move_stop: asyncio.Task | None = None
        self.siren_task: asyncio.Task | None = None

    async def __aenter__(self) -> "Session":
        """Open the session.

        Returns:
            The session.
        """
        await self.open()
        return self

    async def __aexit__(self, *exc) -> None:
        """Close the session.

        Args:
            *exc: Exception details, unused.
        """
        await self.close()

    async def open(self) -> None:
        """Log in, open the stream connection, log in to the stream and start it.

        Raises:
            V380Error: A step failed; the session is closed again.
        """
        self.login_reply = await login(self.camera, self.timeouts)
        self.facts.device_version = self.login_reply.device_version
        self.facts.encrypted = self.login_reply.encrypted
        self.reader, self.writer = await connect(self.camera, self.timeouts)
        sock = self.writer.get_extra_info("socket")
        if sock is not None:
            try:
                sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
                sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, RECEIVE_BUFFER)
                sock.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, SEND_BUFFER)
            except OSError:
                pass
        try:
            request = records.stream_login_request(
                self.camera.device_id, self.login_reply.ticket, self.sound, self.stream
            )
            self.writer.write(request)
            await self.writer.drain()
            reply = records.parse_stream_login_reply(
                await read_reply(self.reader, records.STREAM_LOGIN_REPLY_SIZE, self.timeouts)
            )
            if not reply.accepted:
                raise StreamRefused(reply.result)
            self.stream_reply = reply
            self.facts.comm_version = reply.comm_version
            cipher = MediaCipher(media_key(self.login_reply.ticket), reply.comm_version)
            self.decoder = MediaDecoder(
                cipher=cipher if self.login_reply.encrypted else None,
                sound=self.sound,
                low_latency=self.low_latency,
                facts=self.facts,
                fallback=(reply.width, reply.height)
                if reply.width in SIZE_RANGE and reply.height in SIZE_RANGE
                else None,
            )
            self.writer.write(records.start_request())
            await self.writer.drain()
        except OSError as exc:
            await self.abort()
            raise SessionLost(f"The stream connection failed ({type(exc).__name__})")
        except V380Error:
            await self.abort()
            raise

    async def abort(self) -> None:
        """Close the stream connection without sending anything."""
        if self.writer is not None:
            await close(self.writer)
        self.writer = None
        self.reader = None

    async def frames(self) -> AsyncIterator[VideoFrame | AudioFrame]:
        """Yield the session's output frames until the session is lost.

        Yields:
            Video and audio frames in arrival order, starting with the first key frame.

        Raises:
            SessionLost: The camera closed the connection, went silent, or the framing was lost.
        """
        if self.reader is None or self.decoder is None:
            raise SessionLost("The session is not open")
        while True:
            try:
                data = await asyncio.wait_for(self.reader.read(READ_SIZE), self.timeouts.silence)
            except TimeoutError:
                raise SessionLost(f"No media for {self.timeouts.silence:g} s")
            except OSError as exc:
                raise SessionLost(f"The stream connection failed ({type(exc).__name__})")
            if not data:
                raise SessionLost("The camera closed the stream connection")
            for frame in self.decoder.feed(data):
                yield frame

    async def send(self, record: bytes) -> None:
        """Write one control record on the stream connection.

        Args:
            record: A 16-byte record.

        Raises:
            SessionLost: The session is not open or the write failed.
        """
        async with self.lock:
            if self.writer is None or self.writer.is_closing():
                raise SessionLost("The session is not open")
            try:
                self.writer.write(record)
                await self.writer.drain()
            except OSError as exc:
                raise SessionLost(f"The stream connection failed ({type(exc).__name__})")

    async def ptz(self, move: PtzMove) -> None:
        """Start a move along one axis, or stop.

        Args:
            move: The move.
        """
        move = PtzMove(move)
        if self.move_stop is not None and self.move_stop is not asyncio.current_task():
            self.move_stop.cancel()
            self.move_stop = None
        await self.send(records.ptz_record(move))
        self.moving = move != PtzMove.STOP
        if self.moving and self.max_move:
            self.move_stop = asyncio.create_task(self.forgotten_move(self.max_move))

    async def forgotten_move(self, seconds: float) -> None:
        """Stop a move nobody stopped.

        Args:
            seconds: Seconds to wait.
        """
        await asyncio.sleep(seconds)
        logger.warning("Stopping a move that was not stopped within %g s", seconds)
        try:
            await self.ptz(PtzMove.STOP)
        except SessionLost:
            pass

    async def light(self, mode: LightMode) -> None:
        """Switch the light.

        Args:
            mode: on, off or auto.
        """
        await self.send(records.light_record(LightMode(mode)))

    async def picture(self, mode: PictureMode) -> None:
        """Switch the picture between colour, black and white and automatic.

        Args:
            mode: The mode.
        """
        await self.send(records.picture_record(PictureMode(mode)))

    async def flip(self) -> None:
        """Turn the picture by 180 degrees."""
        await self.send(records.flip_record())

    async def siren(self, seconds: float) -> None:
        """Sound the siren for a time, repeating siren on every 500 ms, or silence it.

        Args:
            seconds: How long to sound it; 0 silences it at once.
        """
        if self.siren_task is not None:
            self.siren_task.cancel()
            await asyncio.gather(self.siren_task, return_exceptions=True)
            self.siren_task = None
        if seconds <= 0:
            await self.send(records.siren_record(False))
            return
        await self.send(records.siren_record(True))
        self.siren_task = asyncio.create_task(self.keep_siren(seconds))

    async def keep_siren(self, seconds: float) -> None:
        """Repeat siren on until the time is up, then send siren off once.

        Args:
            seconds: How long to sound it.
        """
        end = time.monotonic() + seconds
        try:
            while time.monotonic() + SIREN_REPEAT_SECONDS < end:
                await asyncio.sleep(SIREN_REPEAT_SECONDS)
                await self.send(records.siren_record(True))
            await asyncio.sleep(max(0.0, end - time.monotonic()))
            await self.send(records.siren_record(False))
        except SessionLost:
            pass

    async def close(self) -> None:
        """Stop a running move and a sounding siren, then close the stream connection."""
        for task in (self.move_stop, self.siren_task):
            if task is not None and task is not asyncio.current_task():
                task.cancel()
                await asyncio.gather(task, return_exceptions=True)
        if self.siren_task is not None:
            try:
                await self.send(records.siren_record(False))
            except SessionLost:
                pass
        if self.moving:
            try:
                await self.send(records.ptz_record(PtzMove.STOP))
            except SessionLost:
                pass
            self.moving = False
        self.move_stop = None
        self.siren_task = None
        await self.abort()

    @property
    def is_open(self) -> bool:
        """Whether the stream connection is open.

        Returns:
            True while it is.
        """
        return self.writer is not None and not self.writer.is_closing()


async def first_key_frame(session: Session, seconds: float) -> VideoFrame:
    """Wait for the first key frame of an open session.

    Args:
        session: The session.
        seconds: Seconds to wait.

    Returns:
        The key frame.

    Raises:
        SessionLost: None arrived in time.
    """

    async def wait() -> VideoFrame:
        """Read frames until a key frame.

        Returns:
            The key frame.

        Raises:
            SessionLost: The session ended first.
        """
        async for frame in session.frames():
            if isinstance(frame, VideoFrame) and frame.key:
                return frame
        raise SessionLost("The session ended before a key frame")

    try:
        return await asyncio.wait_for(wait(), seconds)
    except TimeoutError:
        raise SessionLost(f"No key frame within {seconds:g} s")
