"""A camera stream kept alive across reconnects, with its control commands and its output."""

import asyncio
import logging
from collections.abc import Awaitable, Callable
from dataclasses import asdict, replace

from camera_adapters.v380.client import AudioFrame, Camera, Facts, Session, Timeouts, VideoFrame
from camera_adapters.v380.discovery import find
from camera_adapters.v380.errors import LoginRefused, SessionLost, Unreachable, V380Error
from camera_adapters.v380.records import LightMode, PictureMode, PtzMove, Stream

__all__ = ["Backoff", "Streamer"]

logger = logging.getLogger(__name__)

BACKOFF_SECONDS = (1.0, 2.0, 5.0, 10.0)
BACKOFF_LIMIT = 30.0
REFUSED_SECONDS = 300.0

Sink = Callable[[VideoFrame | AudioFrame], Awaitable[None]]


class Backoff:
    """Delays between reconnects: 1, 2, 5 and 10 s, then every 30 s.

    Attributes:
        attempt: Reconnects since the last session that delivered media.
    """

    def __init__(self):
        """Start at the first delay."""
        self.attempt = 0

    def next(self) -> float:
        """Return the next delay and advance.

        Returns:
            Seconds to wait.
        """
        delay = BACKOFF_SECONDS[self.attempt] if self.attempt < len(BACKOFF_SECONDS) else BACKOFF_LIMIT
        self.attempt += 1
        return delay

    def reset(self) -> None:
        """Start again at the first delay, after a session delivered media."""
        self.attempt = 0


class Streamer:
    """Keeps one stream session of a camera open, reconnecting as the protocol requires, and serves its controls.

    Every reconnect repeats the whole sequence: login, stream login with the new ticket, start. A camera that is
    unreachable is searched for once by its device id, in case it moved to another address.

    Attributes:
        camera: The camera; its host changes when discovery finds it elsewhere.
        stream: Main or sub stream.
        sound: Whether to ask for audio.
        low_latency: Whether to rewrite the reorder declaration of every key frame.
        timeouts: Timers.
        sink: Coroutine that receives every output frame.
        broadcasts: Directed broadcast addresses for discovery.
        discover: Whether to search for a camera that moved.
        session: The open session, if any.
        facts: Facts of the latest session.
        backoff: Reconnect delays.
        stopping: Set to end the stream.
        searched: Whether discovery already ran during the current outage.
    """

    def __init__(
        self,
        camera: Camera,
        sink: Sink,
        stream: Stream = Stream.SUB,
        sound: bool = False,
        low_latency: bool = False,
        timeouts: Timeouts = Timeouts(),
        broadcasts: tuple[str, ...] = (),
        discover: bool = True,
    ):
        """Create the streamer, not yet running.

        Args:
            camera: The camera.
            sink: Coroutine that receives every output frame.
            stream: Main or sub stream.
            sound: Whether to ask for audio.
            low_latency: Whether to rewrite the reorder declaration of every key frame.
            timeouts: Timers.
            broadcasts: Directed broadcast addresses for discovery.
            discover: Whether to search for a camera that moved.
        """
        self.camera = camera
        self.sink = sink
        self.stream = Stream(stream)
        self.sound = sound
        self.low_latency = low_latency
        self.timeouts = timeouts
        self.broadcasts = broadcasts
        self.discover = discover
        self.session: Session | None = None
        self.facts: Facts | None = None
        self.backoff = Backoff()
        self.stopping = asyncio.Event()
        self.searched = False

    async def run(self, sessions: int | None = None) -> None:
        """Stream until stopped, reconnecting after every loss.

        Args:
            sessions: Stop after this many session attempts, for tests; None runs until stopped.
        """
        attempts = 0
        while not self.stopping.is_set() and (sessions is None or attempts < sessions):
            attempts += 1
            delay = await self.once()
            if self.stopping.is_set() or (sessions is not None and attempts >= sessions):
                break
            logger.info("Reconnecting to %s in %g s", self.camera.host, delay)
            try:
                await asyncio.wait_for(self.stopping.wait(), delay)
            except TimeoutError:
                pass

    async def once(self) -> float:
        """Run one session until it ends.

        Returns:
            Seconds to wait before the next attempt.
        """
        session = Session(self.camera, self.stream, self.sound, self.low_latency, self.timeouts)
        delivered = False
        try:
            await session.open()
            self.session = session
            self.facts = session.facts
            logger.info("Session open: %s", asdict(session.facts))
            async for frame in session.frames():
                if not delivered:
                    delivered = True
                    self.backoff.reset()
                    self.searched = False
                await self.sink(frame)
                if self.stopping.is_set():
                    break
        except LoginRefused as exc:
            logger.error("%s; retrying in %g s", exc.message, REFUSED_SECONDS)
            return REFUSED_SECONDS
        except Unreachable as exc:
            logger.warning("%s", exc.message)
            await self.relocate()
        except SessionLost as exc:
            logger.warning("Session lost: %s", exc.message)
        except V380Error as exc:
            logger.warning("Session failed: %s", exc.message)
        finally:
            self.session = None
            await session.close()
        return self.backoff.next()

    async def relocate(self) -> None:
        """Search once per outage for a camera that moved, and use its new address."""
        if not self.discover or self.searched:
            return
        self.searched = True
        try:
            found = await find(str(self.camera.device_id), self.broadcasts)
        except OSError as exc:
            logger.warning("Discovery failed: %s", exc)
            return
        if found is not None and found.host != self.camera.host:
            logger.info("Camera %s moved to %s", self.camera.device_id, found.host)
            self.camera = replace(self.camera, host=found.host)

    def stop(self) -> None:
        """Ask the stream to end after the current frame."""
        self.stopping.set()

    async def command(self, request: dict) -> dict:
        """Carry out a control command on the open session.

        Args:
            request: command ptz with move, light with mode, siren with seconds, picture with mode, flip, or facts.

        Returns:
            ok, with facts for the facts command or error on failure.
        """
        name = request.get("command")
        if name == "facts":
            return {"ok": True, "facts": asdict(self.facts) if self.facts else None, "open": self.session is not None}
        session = self.session
        if session is None:
            return {"ok": False, "error": "no_session"}
        try:
            if name == "ptz":
                await session.ptz(PtzMove(str(request.get("move"))))
            elif name == "light":
                await session.light(LightMode(str(request.get("mode"))))
            elif name == "siren":
                await session.siren(float(request.get("seconds") or 0))
            elif name == "picture":
                await session.picture(PictureMode(str(request.get("mode"))))
            elif name == "flip":
                await session.flip()
            else:
                return {"ok": False, "error": "unknown_command"}
        except ValueError:
            return {"ok": False, "error": "invalid"}
        except SessionLost:
            return {"ok": False, "error": "no_session"}
        return {"ok": True}
