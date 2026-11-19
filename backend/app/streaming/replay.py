"""Temporary go2rtc streams for SD card playback, one session per camera."""

import asyncio
import logging
import time
from dataclasses import dataclass, field
from datetime import datetime, timedelta
from uuid import UUID, uuid4

from app.streaming.go2rtc import Go2rtcClient, Go2rtcError
from app.streaming.names import stream_sources
from app.streaming.supervisor import supervisor

logger = logging.getLogger(__name__)

WATCH_SECONDS = 2.0
OPEN_GRACE_SECONDS = 30.0
IDLE_SECONDS = 20.0
STALL_SECONDS = 15.0
MAX_SECONDS = 900.0
SAME_START = timedelta(seconds=5)
FAILURES_KEPT = 50


class ReplayBusy(Exception):
    """Error raised when another viewer is playing a recording from the camera."""

    pass


@dataclass
class ReplaySession:
    """One open playback of a recording.

    Attributes:
        id: Session identifier.
        camera_uuid: Camera being played.
        name: go2rtc stream name of the session.
        start: Start time of the recording.
        opened_at: Monotonic time when the session opened.
        task: Task watching the session.
    """

    id: str
    camera_uuid: UUID
    name: str
    start: datetime
    opened_at: float = field(default_factory=time.monotonic)
    task: asyncio.Task | None = None


@dataclass(frozen=True)
class ReplayStatus:
    """Playback state of a camera.

    Attributes:
        active: Whether a session is open.
        session: Identifier of the open session.
        stream: Stream name of the open session.
        start: Start time of the recording being played.
        failure: Reason the last session failed, when no session is open.
    """

    active: bool
    session: str | None
    stream: str | None
    start: datetime | None
    failure: str | None


def replay_name(camera_uuid: UUID) -> str:
    """Build the go2rtc stream name of the playback of a camera.

    Args:
        camera_uuid: Camera identifier.

    Returns:
        The camera UUID in hex followed by replay.
    """
    return f"{camera_uuid.hex}_replay"


def flow(info: dict) -> tuple[int, int]:
    """Measure the activity of a go2rtc stream.

    Args:
        info: go2rtc info of the stream.

    Returns:
        The number of consumers and the bytes received by all producers.
    """
    consumers = len(info.get("consumers") or [])
    received = sum(producer.get("bytes_recv") or 0 for producer in info.get("producers") or [])
    return consumers, received


class ReplayStreams:
    """Opens, watches and ends the playback streams of the cameras.

    Attributes:
        go2rtc: Client used to register and remove the streams.
        sessions: Open session of each camera.
        failures: Reason the latest session of a camera failed, newest last and limited in number.
        locks: Lock of each camera that serializes opening and closing.
    """

    def __init__(self, go2rtc: Go2rtcClient):
        """Create the manager with no sessions.

        Args:
            go2rtc: Client used to register and remove the streams.
        """
        self.go2rtc = go2rtc
        self.sessions: dict[UUID, ReplaySession] = {}
        self.failures: dict[UUID, str] = {}
        self.locks: dict[UUID, asyncio.Lock] = {}

    def lock(self, camera_uuid: UUID) -> asyncio.Lock:
        """Return the lock of a camera, creating it on first use.

        Args:
            camera_uuid: Camera identifier.

        Returns:
            The lock that serializes changes to the playback of the camera.
        """
        return self.locks.setdefault(camera_uuid, asyncio.Lock())

    def status(self, camera_uuid: UUID) -> ReplayStatus:
        """Describe the playback state of a camera.

        Args:
            camera_uuid: Camera identifier.

        Returns:
            The open session, or the last failure when none is open.
        """
        session = self.sessions.get(camera_uuid)
        if session is None:
            return ReplayStatus(False, None, None, None, self.failures.get(camera_uuid))
        return ReplayStatus(True, session.id, session.name, session.start, None)

    async def watchers(self, name: str) -> int:
        """Count the consumers of a stream.

        Args:
            name: Stream name.

        Returns:
            The number of consumers, or zero when the stream is missing or go2rtc cannot be read.
        """
        try:
            info = (await self.go2rtc.snapshot()).get(name)
        except Go2rtcError:
            return 0
        return flow(info)[0] if info else 0

    async def open(self, camera_uuid: UUID, url: str, start: datetime, session_id: str | None) -> ReplaySession:
        """Open the playback of a recording, replacing the camera's current one.

        Only one session exists per camera. A request for nearly the same start time returns the current session.
        Replacing a session that has viewers is refused unless the request comes from that session.

        Args:
            camera_uuid: Camera identifier.
            url: RTSP URL of the recording.
            start: Start time of the recording.
            session_id: Identifier of the session the caller already holds, if any.

        Returns:
            The session now playing.

        Raises:
            ReplayBusy: When another viewer is playing a recording from the camera.
        """
        async with self.lock(camera_uuid):
            current = self.sessions.get(camera_uuid)
            if current is not None:
                if abs(current.start - start) <= SAME_START:
                    return current
                if session_id != current.id and await self.watchers(current.name) > 0:
                    raise ReplayBusy("Another viewer is playing a recording from this camera")
                await self.end(current, None)
            self.failures.pop(camera_uuid, None)
            session = ReplaySession(id=uuid4().hex, camera_uuid=camera_uuid, name=replay_name(camera_uuid), start=start)
            await self.go2rtc.put(session.name, stream_sources(session.name, url))
            self.sessions[camera_uuid] = session
            session.task = asyncio.create_task(self.watch(session), name=f"replay-{camera_uuid.hex[:8]}")
            return session

    async def close(self, camera_uuid: UUID, session_id: str | None) -> None:
        """Close the playback of a camera.

        Args:
            camera_uuid: Camera identifier.
            session_id: Identifier of the session to close, or None to close whichever is open. A different identifier
                leaves the session open.
        """
        async with self.lock(camera_uuid):
            current = self.sessions.get(camera_uuid)
            if current is None or (session_id and session_id != current.id):
                return
            await self.end(current, None)

    async def end(self, session: ReplaySession, failure: str | None) -> None:
        """End a session, stop its watcher and remove its stream.

        Args:
            session: Session to end.
            failure: Reason to remember when the session failed.
        """
        if self.sessions.get(session.camera_uuid) is session:
            del self.sessions[session.camera_uuid]
        if failure:
            self.failures[session.camera_uuid] = failure
            while len(self.failures) > FAILURES_KEPT:
                self.failures.pop(next(iter(self.failures)))
        task = session.task
        session.task = None
        if task is not None and task is not asyncio.current_task():
            task.cancel()
        try:
            await self.go2rtc.delete(session.name)
        except Go2rtcError as exc:
            logger.warning("Removing the replay stream %s failed: %s", session.name, exc)

    async def watch(self, session: ReplaySession) -> None:
        """Watch a session and end it when its stream disappears, stalls, idles or exceeds its maximum length.

        Args:
            session: Session to watch.
        """
        received = 0
        changed_at = time.monotonic()
        seen_at = time.monotonic()
        failure = None
        while True:
            await asyncio.sleep(WATCH_SECONDS)
            now = time.monotonic()
            age = now - session.opened_at
            try:
                info = (await self.go2rtc.snapshot()).get(session.name)
            except Go2rtcError:
                continue
            if info is None:
                failure = "The replay stream disappeared"
                break
            consumers, total = flow(info)
            if total > received:
                received = total
                changed_at = now
            if consumers:
                seen_at = now
                if now - changed_at >= STALL_SECONDS and age >= STALL_SECONDS:
                    failure = "The camera sent no recording for this time"
                    break
            elif now - seen_at >= IDLE_SECONDS and age >= OPEN_GRACE_SECONDS:
                break
            if age >= MAX_SECONDS:
                break
        async with self.lock(session.camera_uuid):
            if self.sessions.get(session.camera_uuid) is session:
                logger.info("Replay %s ended: %s", session.name, failure or "finished")
                await self.end(session, failure)


replay_streams = ReplayStreams(supervisor.go2rtc)
