from datetime import UTC

import numpy as np

from app.falls.detector import FallDetector, FallSettings
from app.falls.posture import PoseSample, posture
from app.rules.model import ArmMode, Box

ASPECT = 16 / 9
FPS = 8
HEIGHT = 0.5
FLOOR = 0.9
X = 0.9


def landmarks(name):
    h = HEIGHT
    if name == "upright":
        return {
            "head": (X, FLOOR - 0.93 * h),
            "shoulders": (X, FLOOR - 0.8 * h),
            "hips": (X, FLOOR - 0.5 * h),
            "knees": (X, FLOOR - 0.25 * h),
            "ankles": (X, FLOOR),
            "side": (0.1 * h, 0.0),
        }
    if name == "lying":
        return {
            "head": (X + 0.45 * h, FLOOR - 0.07 * h),
            "shoulders": (X + 0.3 * h, FLOOR - 0.06 * h),
            "hips": (X, FLOOR - 0.05 * h),
            "knees": (X - 0.25 * h, FLOOR - 0.03 * h),
            "ankles": (X - 0.5 * h, FLOOR - 0.02 * h),
            "side": (0.0, 0.04 * h),
        }
    if name == "sitting":
        return {
            "head": (X, FLOOR - 0.68 * h),
            "shoulders": (X, FLOOR - 0.55 * h),
            "hips": (X, FLOOR - 0.25 * h),
            "knees": (X + 0.25 * h, FLOOR - 0.25 * h),
            "ankles": (X + 0.25 * h, FLOOR),
            "side": (0.1 * h, 0.0),
        }
    if name == "bent":
        return {
            "head": (X + 0.42 * h, FLOOR - 0.5 * h),
            "shoulders": (X + 0.29 * h, FLOOR - 0.56 * h),
            "hips": (X, FLOOR - 0.48 * h),
            "knees": (X, FLOOR - 0.24 * h),
            "ankles": (X, FLOOR),
            "side": (0.08 * h, 0.0),
        }
    raise ValueError(name)


def blend(first, second, fraction):
    result = {}
    for key in first:
        a, b = np.array(first[key]), np.array(second[key])
        result[key] = tuple(a + (b - a) * fraction)
    return result


def keypoints(marks, score=0.9, jitter=0.0, seed=0):
    generator = np.random.default_rng(seed)
    side = np.array(marks["side"])
    points = np.zeros((17, 3), np.float32)
    head = np.array(marks["head"])
    shoulders, hips = np.array(marks["shoulders"]), np.array(marks["hips"])
    knees, ankles = np.array(marks["knees"]), np.array(marks["ankles"])
    layout = [
        head,
        head - side * 0.3,
        head + side * 0.3,
        head - side * 0.6,
        head + side * 0.6,
        shoulders - side,
        shoulders + side,
        (shoulders + hips) / 2 - side * 1.3,
        (shoulders + hips) / 2 + side * 1.3,
        hips - side * 1.4,
        hips + side * 1.4,
        hips - side * 0.8,
        hips + side * 0.8,
        knees - side * 0.8,
        knees + side * 0.8,
        ankles - side * 0.8,
        ankles + side * 0.8,
    ]
    for index, point in enumerate(layout):
        noise = generator.normal(size=2) * jitter if jitter else np.zeros(2)
        points[index, 0] = (point[0] + noise[0]) / ASPECT
        points[index, 1] = point[1] + noise[1]
        points[index, 2] = score
    return points


def box_of(points):
    margin = 0.03
    xs, ys = points[:, 0], points[:, 1]
    return Box(
        float(xs.min()) - margin / ASPECT,
        float(ys.min()) - margin,
        float(xs.max()) + margin / ASPECT,
        float(ys.max()) + margin,
    )


def sample(marks, at, track=1, score=0.9, jitter=0.0):
    points = keypoints(marks, score, jitter, seed=int(at * 1000))
    return PoseSample("hall", track, at, box_of(points), points, ASPECT)


class Script:
    def __init__(self):
        self.at = 0.0
        self.samples = []

    def hold(self, name, seconds, score=0.9, jitter=0.002):
        for _ in range(int(seconds * FPS)):
            self.at += 1 / FPS
            self.samples.append(sample(landmarks(name), self.at, score=score, jitter=jitter))
        return self

    def change(self, start, end, seconds, score=0.9):
        steps = max(1, int(seconds * FPS))
        for step in range(1, steps + 1):
            self.at += 1 / FPS
            marks = blend(landmarks(start), landmarks(end), step / steps)
            self.samples.append(sample(marks, self.at, score=score))
        return self


def run(script, settings=None, arm=ArmMode.HOME):
    detector = FallDetector("hall", settings or FallSettings(enabled=True), UTC, lambda: arm)
    updates = []
    for item in script.samples:
        updates += detector.update([item], item.at)
    return updates


def test_posture_features():
    upright = posture(sample(landmarks("upright"), 0.0), 0.3)
    lying = posture(sample(landmarks("lying"), 0.0), 0.3)
    assert upright.angle < 5 and upright.aspect < 0.8
    assert lying.angle > 80 and lying.aspect > 1.3
    assert lying.hip_y - upright.hip_y > 0.4 * HEIGHT


def test_settings_from_view():
    settings = FallSettings.from_view({"falls": {"enabled": True, "still_seconds": 12, "alert": {"mode": "off"}}})
    assert settings.enabled and settings.still_seconds == 12.0
    assert settings.alert.mode == "off"
    assert not FallSettings.from_view({}).enabled
    assert FallSettings().alert.mode == "always"


def test_fast_fall_followed_by_stillness_fires_once():
    script = Script().hold("upright", 3).change("upright", "lying", 0.75).hold("lying", 12)
    updates = run(script)
    assert [(update.action, update.event.kind.value, update.event.label) for update in updates] == [
        ("instant", "fall", "person")
    ]
    event = updates[0].event
    assert 3.0 < event.started_at < 4.0
    assert event.ended_at - event.started_at >= 8.0
    assert event.objects == [1] and event.boxes[0]["object"] == 1
    assert event.alert


def test_fall_alerts_when_disarmed_unless_turned_off():
    script = Script().hold("upright", 3).change("upright", "lying", 0.75).hold("lying", 10)
    assert run(script, arm=ArmMode.DISARMED)[0].event.alert
    quiet = FallSettings.from_dict({"enabled": True, "alert_disarmed": False})
    assert not run(script, quiet, arm=ArmMode.DISARMED)[0].event.alert
    off = FallSettings.from_dict({"enabled": True, "alert": {"mode": "off"}})
    assert not run(script, off, arm=ArmMode.HOME)[0].event.alert


def test_slow_lying_down_does_not_fire():
    script = (
        Script()
        .hold("upright", 2)
        .change("upright", "sitting", 2.0)
        .hold("sitting", 3)
        .change("sitting", "lying", 3.0)
        .hold("lying", 15)
    )
    assert run(script) == []


def test_getting_up_before_the_still_time_does_not_fire():
    script = (
        Script()
        .hold("upright", 3)
        .change("upright", "lying", 0.75)
        .hold("lying", 4)
        .change("lying", "upright", 1.0)
        .hold("upright", 10)
    )
    assert run(script) == []


def test_bending_over_does_not_fire():
    script = Script().hold("upright", 2).change("upright", "bent", 0.8).hold("bent", 12).change("bent", "upright", 1)
    assert run(script) == []


def test_low_keypoint_scores_fall_back_to_the_box():
    script = (
        Script().hold("upright", 3, score=0.1).change("upright", "lying", 0.75, score=0.1).hold("lying", 10, score=0.1)
    )
    updates = run(script)
    assert len(updates) == 1 and updates[0].event.kind.value == "fall"


def test_moving_on_the_floor_delays_the_event_until_still():
    script = Script().hold("upright", 3).change("upright", "lying", 0.75)
    for _ in range(3):
        script.change("lying", "sitting", 0.5).change("sitting", "lying", 0.5)
    script.hold("lying", 10)
    updates = run(script)
    assert len(updates) == 1
    assert updates[0].event.ended_at >= script.samples[-1].at - 2.5


def test_no_second_event_while_still_lying_and_tracks_expire():
    detector = FallDetector("hall", FallSettings(enabled=True), UTC, lambda: ArmMode.HOME)
    script = Script().hold("upright", 3).change("upright", "lying", 0.75).hold("lying", 40)
    updates = []
    for item in script.samples:
        updates += detector.update([item], item.at)
    assert len(updates) == 1
    assert detector.status()["tracks"] == 1
    assert detector.tick(script.at + 30) == []
    assert detector.status()["tracks"] == 0
