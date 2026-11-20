"""A V380 camera simulator: discovery, login, stream login, start, encrypted media and control commands.

It plays the camera's side of the V380 LAN protocol for the client tests, the TV tests and the development kit, and
needs only the Python standard library. Events are printed to standard output as JSON lines.
"""

import argparse
import asyncio
import contextlib
import itertools
import json
import os
import random
import sys
import time
from collections.abc import Callable, Iterator
from dataclasses import dataclass, field

from aes import Aes128
from media import (
    PPS,
    SIZES,
    SUB_SPS,
    SUB_VPS,
    AccessUnit,
    adpcm_encode,
    adts_frames,
    alaw_encode,
    file_access_units,
    h264_access_units,
    h265_access_units,
    placeholder_adts,
    sine,
)

__all__ = ["Config", "Simulator", "main", "transcript_media"]

FIXED_KEY = b"macrovideo+*#!^@"
MEDIA_KEY_TAIL = bytes.fromhex("5c79142c46238161f00d8082")
SEARCH = b"NVDEVSEARCH^100"

LOGIN = 1167
LOGIN_REPLY = 1168
STREAM_LOGIN = 301
STREAM_LOGIN_REPLY = 401
START = 303

TRANSCRIPT_TICKET = 0x0BADF00D
FAULTS = (
    "refuse-login",
    "refuse-stream",
    "split-reply",
    "full-reply",
    "silence",
    "close-mid-frame",
    "missing-fragment",
    "repeated-fragment",
    "count-change",
    "invalid-header",
    "unknown-type",
    "leading-bytes",
    "clear-media",
    "comm21",
    "h264",
    "parameter-change",
    "single-session",
    "interleave-audio",
)
AUDIO_PERIODS = {"adpcm": 0.063, "alaw": 0.02, "aac": 0.128}
AUDIO_TYPES = {"adpcm": 0x16, "aac": 0x18, "alaw": 0x1A}


def u32(value: int) -> bytes:
    """Pack a little-endian u32.

    Args:
        value: The value.

    Returns:
        Four bytes.
    """
    return (value & 0xFFFFFFFF).to_bytes(4, "little")


def read_u(data: bytes, offset: int, size: int) -> int:
    """Read a little-endian unsigned integer.

    Args:
        data: The record.
        offset: Byte offset.
        size: Width in bytes.

    Returns:
        The value.
    """
    return int.from_bytes(data[offset : offset + size], "little")


class MediaCrypto:
    """The camera's media encryption for one session.

    Attributes:
        aes: Cipher under the media key.
        comm_version: Communication version; 21 encrypts video in whole blocks.
    """

    def __init__(self, ticket: int, comm_version: int):
        """Derive the media key from a ticket.

        Args:
            ticket: The session's ticket.
            comm_version: Communication version.
        """
        self.aes = Aes128(u32(ticket) + MEDIA_KEY_TAIL)
        self.comm_version = comm_version

    def whole(self, payload: bytes) -> bytes:
        """Encrypt the leading whole blocks and keep the tail.

        Args:
            payload: Plain payload.

        Returns:
            The encrypted payload.
        """
        size = len(payload) // 16 * 16
        return self.aes.encrypt(payload[:size]) + payload[size:]

    def video(self, payload: bytes) -> bytes:
        """Encrypt a video payload: 64-byte runs every 80 bytes, or whole blocks at communication version 21.

        Args:
            payload: Plain payload.

        Returns:
            The encrypted payload.
        """
        if self.comm_version == 21:
            return self.whole(payload)
        out = bytearray(payload)
        offset = 0
        while len(payload) - offset >= 64:
            out[offset : offset + 64] = self.aes.encrypt(payload[offset : offset + 64])
            offset += 80
        return bytes(out)

    def audio(self, payload: bytes) -> bytes:
        """Encrypt an audio payload in whole blocks.

        Args:
            payload: Plain payload.

        Returns:
            The encrypted payload.
        """
        return self.whole(payload)


def frame_header(number: int, inner: int, rate: int, timestamp: int) -> bytes:
    """Build a 16-byte frame header.

    Args:
        number: Frame number.
        inner: Inner frame type.
        rate: Frame rate.
        timestamp: Milliseconds.

    Returns:
        The header.
    """
    return u32(number) + inner.to_bytes(2, "little") + rate.to_bytes(2, "little") + timestamp.to_bytes(8, "little")


def fragment(frame_type: int, count: int, index: int, payload: bytes) -> bytes:
    """Build a fragment: its 12-byte header and payload.

    Args:
        frame_type: Frame type.
        count: Fragments in the frame.
        index: This fragment's index.
        payload: Its payload.

    Returns:
        The fragment.
    """
    return (
        bytes([0x7F, frame_type, 0])
        + count.to_bytes(2, "little")
        + index.to_bytes(2, "little")
        + len(payload).to_bytes(2, "little")
        + bytes(3)
        + payload
    )


def split(frame: bytes, size: int) -> list[bytes]:
    """Cut a frame into fragment payloads of at most a size.

    Args:
        frame: The frame.
        size: Largest payload.

    Returns:
        The payloads.
    """
    return [frame[offset : offset + size] for offset in range(0, len(frame), size)] or [b""]


def transcript_media() -> bytes:
    """Build the media byte stream of the specification's session transcript.

    Returns:
        The 1408 bytes the camera sends after the start request.
    """
    crypto = MediaCrypto(TRANSCRIPT_TICKET, 20)
    key_unit = (
        b"\0\0\0\1"
        + SUB_VPS
        + b"\0\0\0\1"
        + SUB_SPS
        + b"\0\0\0\1"
        + PPS
        + b"\0\0\0\1\x26\x01"
        + bytes(index % 256 for index in range(300))
    )
    non_key = b"\xab\xcd\0\0\0\1\x02\x01" + bytes(range(120))
    block = bytes.fromhex("e8030a00") + bytes(range(252))
    adts = bytes.fromhex("fff96c4020fffc") + bytes(range(256))
    alaw = bytes(range(160))
    frame_a = frame_header(1, 0, 15, 1700000000000) + crypto.video(key_unit)
    frame_b = frame_header(2, 1, 15, 1700000000066) + crypto.video(non_key)
    frame_c = frame_header(3, 0, 0, 1700000000070) + crypto.audio(block)
    frame_d = frame_header(4, 0, 0, 1700000000080) + crypto.audio(adts)
    frame_e = frame_header(5, 0, 0, 1700000000090) + crypto.audio(alaw)
    return b"".join(
        [
            fragment(0x28, 3, 0, frame_a[0:200]),
            fragment(0x16, 1, 0, frame_c),
            fragment(0x28, 3, 1, frame_a[200:400]),
            fragment(0x5B, 1, 0, bytes(range(8))),
            fragment(0x28, 3, 2, frame_a[400:]),
            fragment(0x29, 1, 0, frame_b),
            fragment(0x18, 1, 0, frame_d),
            fragment(0x1A, 2, 0, frame_e[0:100]),
            fragment(0x1A, 2, 1, frame_e[100:]),
        ]
    )


@dataclass
class Config:
    """How the simulated camera behaves.

    Attributes:
        host: Address to listen on.
        port: TCP port, 0 for any free port.
        discovery_port: UDP discovery port, 0 for none.
        device_id: Device id.
        username: User name.
        password: Password.
        device_version: Device version; 30 or lower sends clear media.
        comm_version: Communication version; 21 encrypts video in whole blocks.
        ticket: Fixed ticket, or None for a fresh random one per login.
        videos: Annex-B file per stream, main and sub; generated video for a stream without one.
        audio: none, adpcm, alaw or aac.
        aac_file: ADTS file for aac audio; placeholder frames without one.
        fps: Frame rate.
        fragment_size: Largest fragment payload.
        faults: Fault switches with an optional value.
        fault_every: Frames between two faults of the media.
        transcript: Whether to serve exactly the specification's session transcript.
        mac: Hardware address in discovery replies.
        address: Address in discovery replies.
        seed: Seed of the random tickets.
    """

    host: str = "0.0.0.0"
    port: int = 8800
    discovery_port: int = 10008
    device_id: int = 12345678
    username: str = "admin"
    password: str = "secret123"
    device_version: int = 32
    comm_version: int = 20
    ticket: int | None = None
    videos: dict[str, str] = field(default_factory=dict)
    audio: str = "adpcm"
    aac_file: str | None = None
    fps: int = 15
    fragment_size: int = 8000
    faults: dict[str, str] = field(default_factory=dict)
    fault_every: int = 30
    transcript: bool = False
    mac: str = "02:00:00:38:00:01"
    address: str = "127.0.0.1"
    seed: int | None = None


class StreamSession:
    """One stream connection of the simulator.

    Attributes:
        writer: The connection.
        stream: main or sub.
        sound: Whether the client asked for audio.
        crypto: Media encryption, None for clear media.
        closed: Set when the session ends.
    """

    def __init__(self, writer: asyncio.StreamWriter, stream: str, sound: bool, crypto: MediaCrypto | None):
        """Create the session.

        Args:
            writer: The connection.
            stream: main or sub.
            sound: Whether the client asked for audio.
            crypto: Media encryption.
        """
        self.writer = writer
        self.stream = stream
        self.sound = sound
        self.crypto = crypto
        self.closed = asyncio.Event()


class Simulator:
    """The simulated camera.

    Attributes:
        config: Its behaviour.
        events: Every event so far.
        printer: Called with each event, such as a JSON line printer.
        tickets: Tickets issued by logins.
        sessions: Open stream sessions.
        pan: Simulated pan position in seconds of movement.
        tilt: Simulated tilt position, the same.
        motion: Current pan and tilt direction.
        moved_at: When the position was last updated.
        server: TCP server.
        discovery: UDP transport.
        random: Source of tickets.
    """

    def __init__(self, config: Config, printer: Callable[[dict], None] | None = None):
        """Create the simulator, not yet listening.

        Args:
            config: Its behaviour.
            printer: Called with each event.
        """
        self.config = config
        self.printer = printer
        self.events: list[dict] = []
        self.tickets: set[int] = set()
        self.sessions: list[StreamSession] = []
        self.pan = 0.0
        self.tilt = 0.0
        self.motion = (0, 0)
        self.moved_at = time.monotonic()
        self.server: asyncio.base_events.Server | None = None
        self.discovery: asyncio.DatagramTransport | None = None
        self.random = random.Random(config.seed)

    def emit(self, event: str, **values) -> None:
        """Record an event.

        Args:
            event: Event name.
            **values: Its values.
        """
        item = {"event": event, **values}
        self.events.append(item)
        if self.printer is not None:
            self.printer(item)

    async def start(self) -> int:
        """Listen for connections and discovery.

        Returns:
            The TCP port.
        """
        self.server = await asyncio.start_server(self.connection, self.config.host, self.config.port)
        port = self.server.sockets[0].getsockname()[1]
        discovery_port = None
        if self.config.discovery_port:
            loop = asyncio.get_running_loop()
            self.discovery, _ = await loop.create_datagram_endpoint(
                lambda: Discovery(self), local_addr=(self.config.host, self.config.discovery_port), reuse_port=True
            )
            discovery_port = self.discovery.get_extra_info("sockname")[1]
        self.emit("listening", port=port, discovery_port=discovery_port)
        return port

    async def stop(self) -> None:
        """Close every session and stop listening."""
        for session in list(self.sessions):
            session.closed.set()
            session.writer.close()
        if self.discovery is not None:
            self.discovery.close()
        if self.server is not None:
            self.server.close()
            with contextlib.suppress(OSError):
                await self.server.wait_closed()

    def discovery_reply(self) -> bytes:
        """Build the discovery reply.

        Returns:
            The reply text.
        """
        fields = ["NVDEVRESULT", "1", self.config.mac, self.config.address, "255.255.255.0", "0.0.0.0"]
        fields += ["x"] * 6 + [str(self.config.device_id), "x"]
        return "^".join(fields).encode()

    async def connection(self, reader: asyncio.StreamReader, writer: asyncio.StreamWriter) -> None:
        """Serve one TCP connection, a login or a stream connection by its first command.

        Args:
            reader: The connection reader.
            writer: The connection writer.
        """
        try:
            head = await reader.readexactly(4)
            command = read_u(head, 0, 4)
            if command == LOGIN:
                await self.login(head + await reader.readexactly(516), reader, writer)
            elif command == STREAM_LOGIN:
                await self.stream(head + await reader.readexactly(252), reader, writer)
            else:
                self.emit("unknown_command", command=command)
        except (asyncio.IncompleteReadError, ConnectionError, OSError):
            pass
        finally:
            writer.close()

    def check_login(self, request: bytes) -> int:
        """Check a login request.

        Args:
            request: The 520-byte request.

        Returns:
            The result code.
        """
        if "refuse-login" in self.config.faults:
            return int(self.config.faults["refuse-login"] or 1012)
        constants = (read_u(request, 4, 4), request[8], read_u(request, 9, 4))
        if constants != (120, 31, 1) or read_u(request, 13, 4) != self.config.device_id:
            return 1018
        if request[49:81].split(b"\0", 1)[0].decode("ascii", "replace") != self.config.username:
            return 1011
        key = request[81:97]
        plain = Aes128(FIXED_KEY).decrypt(Aes128(key).decrypt(request[97:145]))
        if plain != self.config.password.encode()[:48].ljust(48, b"\0"):
            return 1012
        return 1001

    async def login(self, request: bytes, reader: asyncio.StreamReader, writer: asyncio.StreamWriter) -> None:
        """Answer a login and wait for the client to close.

        Args:
            request: The request.
            reader: The connection reader.
            writer: The connection writer.
        """
        result = self.check_login(request)
        ticket = 0
        if result == 1001:
            if self.config.transcript:
                ticket = TRANSCRIPT_TICKET
            elif self.config.ticket is not None:
                ticket = self.config.ticket
            else:
                ticket = self.random.getrandbits(32)
            self.tickets.add(ticket)
        key = request[81:97]
        version = 30 if "clear-media" in self.config.faults else self.config.device_version
        reply = bytearray(256)
        reply[0:4] = u32(LOGIN_REPLY)
        reply[4:8] = u32(result)
        reply[12] = 32 if self.config.transcript else version
        reply[13:17] = u32(ticket)
        reply[17:21] = u32(119)
        reply[21:25] = bytes([1, 2, 2, 1])
        writer.write(bytes(reply))
        await writer.drain()
        self.emit(
            "login",
            result=result,
            random_key_ok=all(chr(byte).isascii() and chr(byte).isalnum() for byte in key),
        )
        with contextlib.suppress(TimeoutError):
            await asyncio.wait_for(reader.read(1), 2.0)

    async def stream(self, request: bytes, reader: asyncio.StreamReader, writer: asyncio.StreamWriter) -> None:
        """Answer a stream login, wait for the start request and stream media.

        Args:
            request: The 256-byte stream login.
            reader: The connection reader.
            writer: The connection writer.
        """
        ticket = read_u(request, 14, 4)
        sound = read_u(request, 22, 4) == 4097
        stream = "main" if read_u(request, 26, 4) == 1 else "sub"
        valid = read_u(request, 4, 4) == self.config.device_id and ticket in self.tickets
        self.emit("stream_login", stream=read_u(request, 26, 4), sound=sound, ticket=ticket, valid=valid)
        if not valid:
            return
        comm = 21 if "comm21" in self.config.faults else self.config.comm_version
        if self.config.transcript:
            comm = 20
        result = -11 if "refuse-stream" in self.config.faults else 1001
        width, height = SIZES["main" if stream == "main" else "sub"]
        reply = bytearray(412 if "full-reply" in self.config.faults else 32)
        reply[0:4] = u32(STREAM_LOGIN_REPLY)
        reply[4:8] = result.to_bytes(4, "little", signed=True)
        reply[8:10] = comm.to_bytes(2, "little")
        reply[10:14] = u32(width)
        reply[14:18] = u32(height)
        if "split-reply" in self.config.faults:
            writer.write(bytes(reply[:10]))
            await writer.drain()
            await asyncio.sleep(0.1)
            writer.write(bytes(reply[10:]))
        else:
            writer.write(bytes(reply))
        await writer.drain()
        if result != 1001:
            return
        start = await reader.readexactly(256)
        if read_u(start, 0, 4) != START or read_u(start, 4, 2) != 0x3001:
            self.emit("bad_start", command=read_u(start, 0, 4))
            return
        self.emit("start")
        clear = "clear-media" in self.config.faults or self.config.device_version <= 30
        crypto = None if clear and not self.config.transcript else MediaCrypto(ticket, comm)
        session = StreamSession(writer, stream, sound, crypto)
        if "single-session" in self.config.faults:
            for other in list(self.sessions):
                other.closed.set()
                other.writer.close()
        self.sessions.append(session)
        controls = asyncio.create_task(self.controls(reader, session))
        try:
            if self.config.transcript:
                writer.write(transcript_media())
                await writer.drain()
                self.emit("media_done")
                await session.closed.wait()
            else:
                await self.media(session)
        except (ConnectionError, OSError):
            pass
        finally:
            session.closed.set()
            controls.cancel()
            await asyncio.gather(controls, return_exceptions=True)
            if session in self.sessions:
                self.sessions.remove(session)
            self.emit("stream_closed", stream=stream)

    async def controls(self, reader: asyncio.StreamReader, session: StreamSession) -> None:
        """Read control records for as long as the session lasts.

        Args:
            reader: The connection reader.
            session: The session.
        """
        try:
            while True:
                record = await reader.readexactly(16)
                self.control(record)
        except (asyncio.IncompleteReadError, ConnectionError, OSError):
            session.closed.set()

    def control(self, record: bytes) -> None:
        """Log a control record and move the simulated position.

        Args:
            record: The 16-byte record.
        """
        now = time.monotonic()
        self.pan += self.motion[0] * (now - self.moved_at)
        self.tilt += self.motion[1] * (now - self.moved_at)
        self.moved_at = now
        command = read_u(record, 0, 4)
        if command == 0xAA:
            pan = {1001: -1, 1002: 1}.get(read_u(record, 8, 2), 0)
            tilt = {1003: 1, 1004: -1}.get(read_u(record, 10, 2), 0)
            self.motion = (pan, tilt)
        self.emit(
            "control",
            hex=record.hex(),
            command=command,
            moving=self.motion != (0, 0),
            pan=round(self.pan, 3),
            tilt=round(self.tilt, 3),
        )

    def video_source(self, stream: str) -> Iterator[AccessUnit]:
        """Choose the access units of a stream.

        Args:
            stream: main or sub.

        Returns:
            Access units without end, looping a file from its first key picture.
        """
        gop = max(1, self.config.fps * 2)
        if "h264" in self.config.faults:
            return h264_access_units(gop, 12000, 1500)
        if "parameter-change" in self.config.faults:
            main = h265_access_units("main", gop, 20000, 2000)
            sub = h265_access_units("sub", gop, 8000, 1000)
            return (next(main if (number // gop) % 2 else sub) for number in itertools.count())
        path = self.config.videos.get(stream)
        if path:
            units = file_access_units(path)
            return itertools.cycle(units)
        return h265_access_units(stream, gop, 30000 if stream == "main" else 12000, 3000 if stream == "main" else 1200)

    def audio_source(self) -> Iterator[tuple[int, bytes]]:
        """Generate the audio frames of the configured type.

        Returns:
            Frame type and plain payload, without end.
        """
        kind = self.config.audio
        frames = adts_frames(self.config.aac_file) if kind == "aac" and self.config.aac_file else []

        def generate() -> Iterator[tuple[int, bytes]]:
            """Make frames of the configured type.

            Yields:
                Frame type and payload.
            """
            for number in itertools.count():
                if kind == "adpcm":
                    yield 0x16, adpcm_encode(sine(505, number * 505))
                elif kind == "alaw":
                    yield 0x1A, alaw_encode(sine(160, number * 160))
                elif frames:
                    yield 0x18, frames[number % len(frames)]
                else:
                    yield 0x18, placeholder_adts(number)

        return generate()

    def fault_now(self, name: str, number: int) -> bool:
        """Tell whether a media fault applies to a frame.

        Args:
            name: Fault switch.
            number: Frame number.

        Returns:
            True when the switch is on and the frame is due.
        """
        return name in self.config.faults and number % self.config.fault_every == self.config.fault_every - 1

    async def send(self, session: StreamSession, data: bytes) -> None:
        """Write bytes to a session.

        Args:
            session: The session.
            data: The bytes.

        Raises:
            ConnectionError: The session is closed.
        """
        if session.closed.is_set():
            raise ConnectionError("closed")
        session.writer.write(data)
        await session.writer.drain()

    async def media(self, session: StreamSession) -> None:
        """Send video and, when asked for, audio at their rates until the session closes.

        Args:
            session: The session.
        """
        videos = self.video_source(session.stream)
        sounds = self.audio_source() if session.sound and self.config.audio in AUDIO_TYPES else None
        period = 1.0 / max(1, self.config.fps)
        audio_period = AUDIO_PERIODS.get(self.config.audio, 1.0)
        start = time.monotonic()
        next_video = start
        next_audio = start
        number = 0
        audio_number = 0
        while not session.closed.is_set():
            now = time.monotonic()
            if sounds is not None and next_audio <= next_video:
                await asyncio.sleep(max(0.0, next_audio - now))
                frame_type, payload = next(sounds)
                audio_number += 1
                await self.send(session, self.audio_frame(session, frame_type, payload, audio_number))
                next_audio += audio_period
                continue
            await asyncio.sleep(max(0.0, next_video - now))
            unit = next(videos)
            number += 1
            if self.fault_now("silence", number):
                self.emit("fault", name="silence")
                await asyncio.sleep(float(self.config.faults["silence"] or 16))
                next_video = next_audio = time.monotonic()
            extra = None
            if sounds is not None and self.fault_now("interleave-audio", number):
                audio_number += 1
                extra = self.audio_frame(session, *next(sounds), audio_number)
                next_audio += audio_period
            await self.send(session, self.video_fragments(session, unit, number, extra))
            if self.fault_now("close-mid-frame", number):
                return
            next_video += period

    def audio_frame(self, session: StreamSession, frame_type: int, payload: bytes, number: int) -> bytes:
        """Build the fragments of an audio frame.

        Args:
            session: The session.
            frame_type: Audio frame type.
            payload: Plain payload.
            number: Frame number.

        Returns:
            The fragments.
        """
        body = session.crypto.audio(payload) if session.crypto else payload
        frame = frame_header(number, 0, 0, int(time.time() * 1000)) + body
        parts = split(frame, self.config.fragment_size)
        return b"".join(fragment(frame_type, len(parts), index, part) for index, part in enumerate(parts))

    def video_fragments(self, session: StreamSession, unit: AccessUnit, number: int, audio: bytes | None) -> bytes:
        """Build the fragments of a video frame, applying the media faults that are due.

        Args:
            session: The session.
            unit: The access unit.
            number: Frame number.
            audio: Audio fragments to put between two video fragments, if any.

        Returns:
            The bytes to send.
        """
        data = unit.data
        if self.fault_now("leading-bytes", number):
            data = b"\xab\xcd" + data
        body = session.crypto.video(data) if session.crypto else data
        frame = frame_header(number, 0 if unit.key else 1, self.config.fps, int(time.time() * 1000)) + body
        if unit.codec == "h264":
            frame_type = 0x00 if unit.key else 0x01
        else:
            frame_type = 0x28 if unit.key else 0x29
        parts = split(frame, self.config.fragment_size)
        fragments = [fragment(frame_type, len(parts), index, part) for index, part in enumerate(parts)]
        if len(fragments) > 1:
            if self.fault_now("missing-fragment", number):
                self.emit("fault", name="missing-fragment", frame=number)
                del fragments[1]
            elif self.fault_now("repeated-fragment", number):
                self.emit("fault", name="repeated-fragment", frame=number)
                fragments.insert(1, fragments[1])
            elif self.fault_now("count-change", number):
                self.emit("fault", name="count-change", frame=number)
                fragments[1] = fragment(frame_type, len(parts) + 1, 1, parts[1])
        if self.fault_now("close-mid-frame", number):
            self.emit("fault", name="close-mid-frame", frame=number)
            return fragments[0][: 12 + len(parts[0]) // 2]
        if self.fault_now("invalid-header", number):
            self.emit("fault", name="invalid-header", frame=number)
            fragments.insert(0, bytes([0x7F, 0x29, 0, 2, 0, 5, 0, 4, 0, 0, 0, 0]) + b"junk")
        if self.fault_now("unknown-type", number):
            fragments.insert(len(fragments) // 2, fragment(0x5B, 1, 0, bytes(range(8))))
        if audio is not None and len(fragments) > 1:
            fragments.insert(1, audio)
        elif audio is not None:
            fragments.append(audio)
        return b"".join(fragments)


class Discovery(asyncio.DatagramProtocol):
    """Answers discovery searches.

    Attributes:
        simulator: The simulator.
        transport: The UDP transport.
    """

    def __init__(self, simulator: Simulator):
        """Bind the responder to its simulator.

        Args:
            simulator: The simulator.
        """
        self.simulator = simulator
        self.transport: asyncio.DatagramTransport | None = None

    def connection_made(self, transport: asyncio.DatagramTransport) -> None:
        """Keep the transport.

        Args:
            transport: The UDP transport.
        """
        self.transport = transport

    def datagram_received(self, data: bytes, addr) -> None:
        """Answer a search to its sender.

        Args:
            data: The datagram.
            addr: The sender.
        """
        if data == SEARCH and self.transport is not None:
            self.transport.sendto(self.simulator.discovery_reply(), addr)
            self.simulator.emit("discovery", sender=addr[0])


def parse(argv: list[str] | None) -> Config:
    """Read the command line.

    Args:
        argv: Arguments without the program name.

    Returns:
        The configuration.
    """
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--host", default=os.environ.get("V380_SIM_HOST", "0.0.0.0"))
    parser.add_argument("--port", type=int, default=int(os.environ.get("V380_SIM_PORT", "8800")))
    parser.add_argument("--discovery-port", type=int, default=int(os.environ.get("V380_SIM_DISCOVERY_PORT", "10008")))
    parser.add_argument("--device-id", type=int, default=int(os.environ.get("V380_SIM_DEVICE_ID", "12345678")))
    parser.add_argument("--username", default=os.environ.get("V380_SIM_USERNAME", "admin"))
    parser.add_argument("--password", default=os.environ.get("V380_SIM_PASSWORD", "secret123"))
    parser.add_argument("--device-version", type=int, default=int(os.environ.get("V380_SIM_DEVICE_VERSION", "32")))
    parser.add_argument("--comm-version", type=int, default=int(os.environ.get("V380_SIM_COMM_VERSION", "20")))
    parser.add_argument("--ticket", type=lambda value: int(value, 0), default=None)
    parser.add_argument("--video", default=os.environ.get("V380_SIM_VIDEO"), help="Annex-B file of the main stream")
    parser.add_argument("--sub-video", default=os.environ.get("V380_SIM_SUB_VIDEO"), help="Annex-B file of the sub")
    parser.add_argument(
        "--audio", choices=("none", "adpcm", "alaw", "aac"), default=os.environ.get("V380_SIM_AUDIO", "adpcm")
    )
    parser.add_argument("--aac-file", default=os.environ.get("V380_SIM_AAC_FILE"))
    parser.add_argument("--fps", type=int, default=int(os.environ.get("V380_SIM_FPS", "15")))
    parser.add_argument("--fragment-size", type=int, default=8000)
    parser.add_argument("--fault", action="append", default=[], help=f"one of {', '.join(FAULTS)}, as NAME[=VALUE]")
    parser.add_argument("--fault-every", type=int, default=30)
    parser.add_argument("--transcript", action="store_true", help="serve exactly the specification's transcript")
    parser.add_argument("--mac", default=os.environ.get("V380_SIM_MAC", "02:00:00:38:00:01"))
    parser.add_argument("--address", default=os.environ.get("V380_SIM_ADDRESS", "127.0.0.1"))
    parser.add_argument("--seed", type=int, default=None)
    args = parser.parse_args(argv)
    faults = {}
    for item in args.fault + [item for item in os.environ.get("V380_SIM_FAULTS", "").split(",") if item]:
        name, _, value = item.partition("=")
        if name not in FAULTS:
            parser.error(f"unknown fault {name}")
        faults[name] = value
    videos = {name: path for name, path in (("main", args.video), ("sub", args.sub_video or args.video)) if path}
    return Config(
        host=args.host,
        port=args.port,
        discovery_port=args.discovery_port,
        device_id=args.device_id,
        username=args.username,
        password=args.password,
        device_version=args.device_version,
        comm_version=args.comm_version,
        ticket=args.ticket,
        videos=videos,
        audio=args.audio,
        aac_file=args.aac_file,
        fps=args.fps,
        fragment_size=args.fragment_size,
        faults=faults,
        fault_every=max(1, args.fault_every),
        transcript=args.transcript,
        mac=args.mac,
        address=args.address,
        seed=args.seed,
    )


def print_event(event: dict) -> None:
    """Print an event as a JSON line.

    Args:
        event: The event.
    """
    sys.stdout.write(json.dumps(event) + "\n")
    sys.stdout.flush()


async def serve(config: Config) -> None:
    """Run the simulator until cancelled.

    Args:
        config: Its behaviour.
    """
    simulator = Simulator(config, print_event)
    await simulator.start()
    try:
        await asyncio.Event().wait()
    finally:
        await simulator.stop()


def main(argv: list[str] | None = None) -> None:
    """Run the simulator from the command line.

    Args:
        argv: Arguments without the program name.
    """
    with contextlib.suppress(KeyboardInterrupt):
        asyncio.run(serve(parse(argv)))


if __name__ == "__main__":
    main()
