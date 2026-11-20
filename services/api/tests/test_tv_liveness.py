from uuid import UUID

from app.streaming.liveness import COOLDOWN_FIRST_SECONDS, START_GRACE_SECONDS, TvLiveness
from app.streaming.status import StatusStore
from app.streaming.tv import INPUT_AGENT, TvCommand

GATE = UUID(int=1)
YARD = UUID(int=2)


class Clock:
    def __init__(self):
        self.now = 100.0

    def __call__(self) -> float:
        return self.now


class FakeGo2rtc:
    def __init__(self):
        self.alive: dict[str, bool] = {}
        self.agents: dict[str, list[str]] = {}
        self.probed: list[str] = []

    async def probe(self, name: str, timeout: float) -> bool:
        self.probed.append(name)
        return self.alive.get(name, True)

    async def consumer_agents(self) -> dict[str, list[str]]:
        return self.agents

    async def received(self) -> dict[str, int | None]:
        return {}


def liveness():
    go2rtc = FakeGo2rtc()
    clock = Clock()
    return TvLiveness(go2rtc, StatusStore(), clock), go2rtc, clock


async def test_offline_uses_known_status_and_probes():
    tv, go2rtc, _ = liveness()
    go2rtc.alive["yard"] = False
    offline = await tv.offline({GATE: "gate", YARD: "yard"}, set())
    assert offline == {YARD}
    assert await tv.offline({GATE: "gate", YARD: "yard"}, {GATE}) == {GATE, YARD}
    assert go2rtc.probed == ["gate", "yard"]


async def test_probes_are_cached_for_a_while():
    tv, go2rtc, clock = liveness()
    await tv.offline({GATE: "gate"}, set())
    await tv.offline({GATE: "gate"}, set())
    assert go2rtc.probed == ["gate"]
    clock.now += 20
    await tv.offline({GATE: "gate"}, set())
    assert go2rtc.probed == ["gate", "gate"]


async def test_a_lost_input_cools_down_with_backoff():
    tv, go2rtc, clock = liveness()
    command = TvCommand(args=["a"], inputs={GATE: "gate", YARD: "yard"})
    tv.remember("tv_wall", command, poll=False)
    go2rtc.agents = {"gate": [INPUT_AGENT], "yard": ["go2rtc/ffmpeg"]}
    await tv.watch("tv_wall")
    assert tv.cooldowns == {}
    clock.now += START_GRACE_SECONDS
    await tv.watch("tv_wall")
    assert set(tv.cooldowns) == {YARD}
    assert await tv.offline({GATE: "gate", YARD: "yard"}, set()) == {YARD}
    clock.now += COOLDOWN_FIRST_SECONDS
    assert await tv.offline({GATE: "gate", YARD: "yard"}, set()) == set()
    tv.remember("tv_wall", command, poll=False)
    clock.now += START_GRACE_SECONDS
    await tv.watch("tv_wall")
    assert tv.cooldowns[YARD].step == COOLDOWN_FIRST_SECONDS * 2


async def test_a_running_input_clears_its_backoff():
    tv, go2rtc, clock = liveness()
    tv.lose(GATE, clock.now)
    clock.now += COOLDOWN_FIRST_SECONDS + 1
    tv.remember("tv_wall", TvCommand(args=["a"], inputs={GATE: "gate"}), poll=False)
    clock.now += START_GRACE_SECONDS
    go2rtc.agents = {"gate": [INPUT_AGENT]}
    await tv.watch("tv_wall")
    assert tv.cooldowns == {}


def test_polls_keep_the_start_time_of_the_running_command():
    tv, _, clock = liveness()
    command = TvCommand(args=["a"], inputs={GATE: "gate"})
    tv.remember("tv_wall", command, poll=False)
    started = tv.issued["tv_wall"].at
    clock.now += 5
    tv.remember("tv_wall", command, poll=True)
    assert tv.issued["tv_wall"].at == started
    tv.remember("tv_wall", command, poll=False)
    assert tv.issued["tv_wall"].at == clock.now


async def test_fresh_offline_checks_skip_the_cache():
    tv, go2rtc, _ = liveness()
    await tv.offline({GATE: "gate"}, set())
    await tv.offline({GATE: "gate"}, set(), fresh=True)
    assert go2rtc.probed == ["gate", "gate"]


def test_an_input_that_fails_to_open_cools_down():
    tv, _, clock = liveness()
    tv.remember("tv_wall", TvCommand(args=["a"], inputs={GATE: "gate", YARD: "yard"}), poll=False)
    tv.fail("tv_wall", "yard")
    tv.fail("tv_wall", "unknown")
    tv.fail("tv_tile_0", "gate")
    assert set(tv.cooldowns) == {YARD}
    assert tv.cooling(YARD, clock.now)


async def test_running_streams_are_judged_by_their_byte_counters():
    tv, go2rtc, clock = liveness()
    counters = {"gate": 1000, "yard": 5000}

    async def received():
        return dict(counters)

    go2rtc.received = received
    tv.samples = {"gate": (clock.now - 5, 900), "yard": (clock.now - 5, 5000)}
    offline = await tv.offline({GATE: "gate", YARD: "yard"}, set())
    assert offline == {YARD}
    assert go2rtc.probed == []


async def test_idle_streams_fall_back_to_a_probe():
    tv, go2rtc, _ = liveness()

    async def received():
        return {"gate": None}

    go2rtc.received = received
    go2rtc.alive["gate"] = False
    assert await tv.offline({GATE: "gate"}, set()) == {GATE}
    assert go2rtc.probed == ["gate"]
