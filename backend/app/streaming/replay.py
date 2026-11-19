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
    pass


@dataclass
class ReplaySession:
    id: str
    camera_uuid: UUID
    name: str
    start: datetime
    opened_at: float = field(default_factory=time.monotonic)
    task: asyncio.Task | None = None


@dataclass(frozen=True)
class ReplayStatus:
    active: bool
    session: str | None
    stream: str | None
    start: datetime | None
    failure: str | None


def replay_name(camera_uuid: UUID) -> str:
    return f"{camera_uuid.hex}_replay"


def flow(info: dict) -> tuple[int, int]:
    consumers = len(info.get("consumers") or [])
    received = sum(producer.get("bytes_recv") or 0 for producer in info.get("producers") or [])
    return consumers, received


class ReplayStreams:
    def __init__(self, go2rtc: Go2rtcClient):
        self.go2rtc = go2rtc
        self.sessions: dict[UUID, ReplaySession] = {}
        self.failures: dict[UUID, str] = {}
        self.locks: dict[UUID, asyncio.Lock] = {}

    def lock(self, camera_uuid: UUID) -> asyncio.Lock:
        return self.locks.setdefault(camera_uuid, asyncio.Lock())

    def status(self, camera_uuid: UUID) -> ReplayStatus:
        session = self.sessions.get(camera_uuid)
        if session is None:
            return ReplayStatus(False, None, None, None, self.failures.get(camera_uuid))
        return ReplayStatus(True, session.id, session.name, session.start, None)

    async def watchers(self, name: str) -> int:
        try:
            info = (await self.go2rtc.snapshot()).get(name)
        except Go2rtcError:
            return 0
        return flow(info)[0] if info else 0

    async def open(self, camera_uuid: UUID, url: str, start: datetime, session_id: str | None) -> ReplaySession:
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
        async with self.lock(camera_uuid):
            current = self.sessions.get(camera_uuid)
            if current is None or (session_id and session_id != current.id):
                return
            await self.end(current, None)

    async def end(self, session: ReplaySession, failure: str | None) -> None:
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
