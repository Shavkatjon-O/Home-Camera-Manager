import io
import json
import urllib.error

import pytest

from app.follow.controller import Command, CommandKind, FollowController
from app.follow.mover import BackendMover, RecordingMover, execute
from app.follow.settings import FollowSettings
from app.rules.model import Box, Detection


class Clock:
    def __init__(self):
        self.now = 0.0

    def __call__(self):
        return self.now

    def sleep(self, seconds):
        self.now += seconds


class FakeCamera:
    def __init__(self, clock, presets=False, rate=0.5):
        self.clock = clock
        self.presets = presets
        self.rate = rate
        self.position = [0.0, 0.0]
        self.velocity = (0.0, 0.0)
        self.last = clock()
        self.saved = None
        self.calls = []

    def advance(self):
        now = self.clock()
        elapsed = now - self.last
        self.position[0] += self.velocity[0] * self.rate * elapsed
        self.position[1] += self.velocity[1] * self.rate * elapsed
        self.last = now

    def move(self, pan, tilt):
        self.advance()
        self.velocity = (pan, tilt)
        self.calls.append(("move", pan, tilt))

    def stop(self):
        self.advance()
        self.velocity = (0.0, 0.0)
        self.calls.append(("stop",))

    def save_home(self):
        self.advance()
        self.calls.append(("save_home",))
        if self.presets:
            self.saved = list(self.position)
        return self.presets

    def return_home(self):
        self.advance()
        self.calls.append(("return_home",))
        self.position = list(self.saved)


def person(track, x, y, height=0.4, width=0.12):
    return Detection(track, "person", 0.9, Box(x - width / 2, y - height / 2, x + width / 2, y + height / 2))


def settings(**values):
    return FollowSettings.from_dict({"enabled": True, **values})


def view_point(world, camera):
    return 0.5 + (world[0] - camera.position[0]), 0.45 - (world[1] - camera.position[1])


def simulate(controller, mover, camera, clock, world, seconds, fps=8):
    commands = []
    for _ in range(int(seconds * fps)):
        clock.now += 1 / fps
        camera.advance()
        x, y = view_point(world, camera)
        command = controller.update([person(1, x, y)], clock.now)
        if command is not None:
            commands.append(command)
            execute(mover, command)
    return commands


def test_disabled_by_default():
    assert not FollowSettings.from_view({}).enabled
    controller = FollowController(FollowSettings())
    assert controller.update([person(1, 0.9, 0.45)], 1.0) is None


def test_settings_from_view():
    parsed = FollowSettings.from_view(
        {"follow": {"enabled": True, "dead_zone": [0.1, 0.2], "gain": 2, "invert_pan": True, "labels": ["dog"]}}
    )
    assert parsed.enabled
    assert parsed.dead_zone == (0.1, 0.2)
    assert parsed.gain == 2.0
    assert parsed.invert_pan
    assert parsed.labels == frozenset({"dog"})
    assert parsed.max_speed == 0.5


def test_person_to_the_right_is_followed_and_centred():
    clock = Clock()
    camera = FakeCamera(clock)
    mover = RecordingMover(camera, clock=clock, sleep=clock.sleep)
    controller = FollowController(settings(), clock.now)
    commands = simulate(controller, mover, camera, clock, (0.3, 0.0), 10)
    assert commands[0].kind == CommandKind.SAVE_HOME
    moves = [command for command in commands if command.kind == CommandKind.MOVE]
    assert moves and moves[0].pan > 0
    assert all(0.15 <= abs(command.pan) <= 0.5 for command in moves if command.pan)
    assert commands[-1].kind == CommandKind.STOP
    x, _ = view_point((0.3, 0.0), camera)
    assert abs(x - 0.5) <= 0.08
    assert not controller.moving


def test_target_below_centre_tilts_down_and_inversion_flips():
    controller = FollowController(settings())
    controller.update([], 0.0)
    command = controller.update([person(1, 0.5, 0.8)], 0.1)
    assert command.kind == CommandKind.MOVE
    assert command.pan == 0.0 and command.tilt < 0
    inverted = FollowController(settings(invert_tilt=True, invert_pan=True))
    inverted.update([], 0.0)
    command = inverted.update([person(1, 0.9, 0.8)], 0.1)
    assert command.tilt > 0 and command.pan < 0


def test_dead_zone_sends_nothing():
    controller = FollowController(settings())
    assert controller.update([person(1, 0.55, 0.47)], 0.0) == Command(CommandKind.SAVE_HOME)
    for step in range(1, 20):
        assert controller.update([person(1, 0.55, 0.47)], step * 0.125) is None


def test_lost_target_stops_after_lost_seconds():
    controller = FollowController(settings())
    controller.update([], 0.0)
    assert controller.update([person(1, 0.9, 0.45)], 0.1).kind == CommandKind.MOVE
    assert controller.update([], 0.5) is None
    assert controller.update([], 1.05) is None
    assert controller.update([], 1.15).kind == CommandKind.STOP
    assert controller.update([], 1.3) is None


def test_idle_returns_home_once():
    controller = FollowController(settings(idle_seconds=30))
    controller.update([], 0.0)
    controller.update([person(1, 0.9, 0.45)], 0.1)
    assert controller.update([], 2.0).kind == CommandKind.STOP
    assert controller.update([], 29.0) is None
    assert controller.update([], 30.2).kind == CommandKind.RETURN_HOME
    for step in range(10):
        assert controller.update([], 31.0 + step) is None


def test_idle_without_movement_sends_no_return():
    controller = FollowController(settings(idle_seconds=5))
    controller.update([], 0.0)
    for step in range(100):
        assert controller.update([], 0.5 + step * 0.5) is None


def test_rate_limit_and_flip():
    controller = FollowController(settings(smoothing=1.0))
    controller.update([], 0.0)
    assert controller.update([person(1, 0.9, 0.45)], 0.1).kind == CommandKind.MOVE
    assert controller.update([person(1, 0.7, 0.45)], 0.2) is None
    flipped = controller.update([person(1, 0.2, 0.45)], 0.25)
    assert flipped.kind == CommandKind.MOVE and flipped.pan < 0


def test_reacquires_a_new_track_near_the_lost_target():
    controller = FollowController(settings())
    controller.update([], 0.0)
    controller.update([person(1, 0.8, 0.45)], 0.1)
    assert controller.target == 1
    controller.update([], 0.3)
    controller.update([person(2, 0.82, 0.45), person(3, 0.2, 0.45, height=0.7, width=0.3)], 0.5)
    assert controller.target == 2


def test_largest_person_is_chosen_first():
    controller = FollowController(settings())
    controller.update([], 0.0)
    controller.update([person(1, 0.8, 0.45, height=0.2), person(2, 0.2, 0.45, height=0.5)], 0.1)
    assert controller.target == 2


def test_disable_stops_and_returns():
    controller = FollowController(settings())
    controller.update([], 0.0)
    controller.update([person(1, 0.9, 0.45)], 0.1)
    commands = controller.disable()
    assert [command.kind for command in commands] == [CommandKind.STOP, CommandKind.RETURN_HOME]
    assert controller.update([person(1, 0.9, 0.45)], 0.2) is None
    assert controller.configure(settings(), 1.0) == []
    assert controller.update([], 1.1).kind == CommandKind.SAVE_HOME


def test_retrace_returns_exactly_to_the_start():
    clock = Clock()
    camera = FakeCamera(clock, presets=False)
    mover = RecordingMover(camera, clock=clock, sleep=clock.sleep)
    assert mover.save_home() is False
    mover.move(0.5, 0.0)
    clock.now += 1.3
    mover.move(0.3, -0.2)
    clock.now += 0.7
    mover.stop()
    clock.now += 2.0
    mover.move(-0.15, 0.4)
    clock.now += 0.4
    camera.advance()
    assert camera.position != [0.0, 0.0]
    mover.return_home()
    camera.advance()
    assert camera.position[0] == pytest.approx(0.0, abs=1e-9)
    assert camera.position[1] == pytest.approx(0.0, abs=1e-9)
    assert camera.calls[-1] == ("stop",)
    assert mover.segments == []


def test_preset_return_when_the_camera_keeps_presets():
    clock = Clock()
    camera = FakeCamera(clock, presets=True)
    mover = RecordingMover(camera, clock=clock, sleep=clock.sleep, use_presets=True)
    assert mover.save_home() is True
    mover.move(0.5, 0.5)
    clock.now += 2.0
    mover.return_home()
    assert camera.calls[-1] == ("return_home",)
    assert camera.position == [0.0, 0.0]


def test_full_follow_and_retrace_round_trip():
    clock = Clock()
    camera = FakeCamera(clock, presets=False)
    mover = RecordingMover(camera, clock=clock, sleep=clock.sleep)
    controller = FollowController(settings(idle_seconds=5), clock.now)
    simulate(controller, mover, camera, clock, (0.35, -0.2), 8)
    assert camera.position[0] > 0.2
    for _ in range(80):
        clock.now += 0.125
        camera.advance()
        command = controller.update([], clock.now)
        if command is not None:
            execute(mover, command)
    camera.advance()
    assert camera.position[0] == pytest.approx(0.0, abs=1e-9)
    assert camera.position[1] == pytest.approx(0.0, abs=1e-9)


class Response:
    def __init__(self, status=204):
        self.status = status

    def __enter__(self):
        return self

    def __exit__(self, *args):
        return False

    def read(self):
        return b""


def test_backend_mover_posts_to_the_internal_endpoints():
    sent = []

    def opener(request, timeout):
        sent.append((request.full_url, request.get_method(), request.get_header("Authorization"), request.data))
        return Response()

    mover = BackendMover("http://backend:8000/", "secret", "cam-1", opener)
    mover.move(0.25, -0.5)
    mover.stop()
    assert mover.save_home() is True
    mover.return_home()
    urls = [item[0] for item in sent]
    assert urls == [
        "http://backend:8000/internal/analytics/ptz/cam-1/move",
        "http://backend:8000/internal/analytics/ptz/cam-1/stop",
        "http://backend:8000/internal/analytics/ptz/cam-1/home",
        "http://backend:8000/internal/analytics/ptz/cam-1/home",
    ]
    assert all(item[1] == "POST" and item[2] == "Bearer secret" for item in sent)
    assert json.loads(sent[0][3]) == {"pan": 0.25, "tilt": -0.5}
    assert json.loads(sent[2][3]) == {"action": "save"}
    assert json.loads(sent[3][3]) == {"action": "return"}


def test_backend_mover_reports_no_presets_and_swallows_errors():
    def no_presets(request, timeout):
        raise urllib.error.HTTPError(request.full_url, 409, "Conflict", {}, io.BytesIO(b""))

    mover = BackendMover("http://backend:8000", "secret", "cam-1", no_presets)
    assert mover.save_home() is False
    assert mover.errors == 0

    def unreachable(request, timeout):
        raise urllib.error.URLError("refused")

    mover = BackendMover("http://backend:8000", "secret", "cam-1", unreachable)
    mover.move(0.2, 0.0)
    assert mover.save_home() is False
    assert mover.errors == 2
    assert "move" in mover.last_error or "home" in mover.last_error


def test_retrace_is_the_default_even_when_the_camera_keeps_presets():
    clock = Clock()
    camera = FakeCamera(clock, presets=True)
    mover = RecordingMover(camera, clock=clock, sleep=clock.sleep)
    assert mover.save_home() is False
    assert ("save_home",) not in camera.calls
    mover.move(0.5, 0.0)
    clock.now += 1.0
    camera.advance()
    mover.stop()
    mover.return_home()
    camera.advance()
    assert camera.position[0] == pytest.approx(0.0, abs=1e-9)
    assert ("return_home",) not in camera.calls
