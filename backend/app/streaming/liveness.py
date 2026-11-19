import asyncio
import logging
import time
from collections.abc import Callable
from dataclasses import dataclass
from uuid import UUID

from app.streaming.go2rtc import Go2rtcClient, Go2rtcError
from app.streaming.status import StatusStore
from app.streaming.supervisor import supervisor
from app.streaming.tv import INPUT_AGENT, TvCommand

logger = logging.getLogger(__name__)

PROBE_TIMEOUT_SECONDS = 4.0
PROBE_TTL_SECONDS = 15.0

FLOW_WAIT_SECONDS = 1.0
FLOW_MIN_AGE_SECONDS = 0.5
FLOW_MAX_AGE_SECONDS = 60.0

START_GRACE_SECONDS = 20.0

COOLDOWN_FIRST_SECONDS = 60.0
COOLDOWN_MAX_SECONDS = 600.0


@dataclass
class Issued:
    command: TvCommand
    at: float


@dataclass
class Cooldown:
    until: float
    step: float


class TvLiveness:
    def __init__(self, go2rtc: Go2rtcClient, statuses: StatusStore, clock: Callable[[], float] = time.monotonic):
        self.go2rtc = go2rtc
        self.statuses = statuses
        self.clock = clock

        self.probes: dict[str, tuple[float, bool]] = {}
        self.samples: dict[str, tuple[float, int]] = {}
        self.cooldowns: dict[UUID, Cooldown] = {}
        self.issued: dict[str, Issued] = {}

    def cooling(self, camera_uuid: UUID, now: float) -> bool:
        cooldown = self.cooldowns.get(camera_uuid)
        return cooldown is not None and cooldown.until > now

    def lose(self, camera_uuid: UUID, now: float) -> None:
        previous = self.cooldowns.get(camera_uuid)
        step = COOLDOWN_FIRST_SECONDS if previous is None else min(previous.step * 2, COOLDOWN_MAX_SECONDS)
        self.cooldowns[camera_uuid] = Cooldown(until=now + step, step=step)

    def settle(self, camera_uuid: UUID, now: float) -> None:
        if not self.cooling(camera_uuid, now):
            self.cooldowns.pop(camera_uuid, None)

    async def probe(self, name: str, now: float, fresh: bool = False) -> bool:
        cached = self.probes.get(name)
        if not fresh and cached is not None and now - cached[0] < PROBE_TTL_SECONDS:
            return cached[1]
        alive = await self.go2rtc.probe(name, PROBE_TIMEOUT_SECONDS)
        self.probes[name] = (self.clock(), alive)
        return alive

    async def flowing(self, streams: list[str], wait: bool) -> dict[str, bool | None]:
        try:
            current = await self.go2rtc.received()
        except Go2rtcError as exc:
            logger.warning("Reading the go2rtc counters failed: %s", exc)
            return dict.fromkeys(streams)
        now = self.clock()
        result: dict[str, bool | None] = {}
        unknown = []
        for stream in streams:
            count = current.get(stream)
            previous = self.samples.get(stream)
            if count is None:
                result[stream] = None
                self.samples.pop(stream, None)
                continue
            if previous is not None and FLOW_MIN_AGE_SECONDS <= now - previous[0] <= FLOW_MAX_AGE_SECONDS:
                result[stream] = count != previous[1]
                self.samples[stream] = (now, count)
            else:
                unknown.append(stream)
                if previous is None or now - previous[0] > FLOW_MAX_AGE_SECONDS:
                    self.samples[stream] = (now, count)
        if unknown and wait:
            await asyncio.sleep(FLOW_WAIT_SECONDS)
            return result | await self.flowing(unknown, wait=False)
        result.update(dict.fromkeys(unknown, True))
        return result

    async def offline(self, sources: dict[UUID, str], known_offline: set[UUID], fresh: bool = False) -> set[UUID]:
        now = self.clock()
        result = {uuid for uuid in sources if uuid in known_offline or self.cooling(uuid, now)}
        pending = [(camera_uuid, name) for camera_uuid, name in sources.items() if camera_uuid not in result]
        flows = await self.flowing([name for _, name in pending], wait=fresh)
        idle = [(camera_uuid, name) for camera_uuid, name in pending if flows.get(name) is None]
        result.update(camera_uuid for camera_uuid, name in pending if flows.get(name) is False)
        results = await asyncio.gather(*(self.probe(name, now, fresh) for _, name in idle))
        result.update(camera_uuid for (camera_uuid, _), alive in zip(idle, results) if not alive)
        return result

    async def watch(self, name: str) -> None:
        issued = self.issued.get(name)
        now = self.clock()
        if issued is None or not issued.command.inputs or now - issued.at < START_GRACE_SECONDS:
            return
        try:
            agents = await self.go2rtc.consumer_agents()
        except Go2rtcError as exc:
            logger.warning("Checking the TV inputs failed: %s", exc)
            return
        for camera_uuid, stream in issued.command.inputs.items():
            if INPUT_AGENT in agents.get(stream, []):
                self.settle(camera_uuid, now)
            elif not self.cooling(camera_uuid, now):
                self.lose(camera_uuid, now)
                self.probes.pop(stream, None)
                logger.info("The TV stream %s lost the camera stream %s", name, stream)

    def fail(self, name: str, stream: str) -> None:
        issued = self.issued.get(name)
        if issued is None:
            return
        now = self.clock()
        for camera_uuid, source in issued.command.inputs.items():
            if source == stream and not self.cooling(camera_uuid, now):
                self.lose(camera_uuid, now)
                self.probes.pop(stream, None)
                logger.info("The TV stream %s could not open the camera stream %s", name, stream)

    def remember(self, name: str, command: TvCommand, poll: bool) -> None:
        issued = self.issued.get(name)
        if poll and issued is not None and issued.command == command:
            return
        self.issued[name] = Issued(command=command, at=self.clock())


tv_liveness = TvLiveness(supervisor.go2rtc, supervisor.statuses)
