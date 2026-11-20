import numpy as np

from app.tampering.guard import GuardSettings, TamperGuard, night_from_chroma

STEP = 5.0


def scene(seed=1):
    generator = np.random.default_rng(seed)
    image = np.full((90, 160), 70.0, np.float32)
    image += np.linspace(0, 30, 160, dtype=np.float32)[None, :]
    for _ in range(18):
        x, y = generator.integers(0, 140), generator.integers(0, 70)
        image[y : y + 20, x : x + 20] = generator.integers(20, 250)
    return image


def blank_wall(seed=1):
    generator = np.random.default_rng(seed)
    image = np.linspace(80, 150, 160, dtype=np.float32)[None, :].repeat(90, axis=0)
    image += np.linspace(-20, 20, 90, dtype=np.float32)[:, None]
    image[3:6, 125:155] = generator.integers(170, 230, (3, 30))
    image[0:30, 8:10] = 40.0
    return image


def noisy(image, seed, sigma=2.0):
    generator = np.random.default_rng(seed)
    return np.clip(image + generator.normal(0, sigma, image.shape), 0, 255).astype(np.float32)


def box_blur(image, size=11):
    padded = np.pad(image, size // 2, mode="edge")
    total = np.cumsum(np.cumsum(padded, axis=0), axis=1)
    total = np.pad(total, ((1, 0), (1, 0)))
    height, width = image.shape
    window = (
        total[size : size + height, size : size + width]
        - total[:height, size : size + width]
        - total[size : size + height, :width]
        + total[:height, :width]
    )
    return (window / (size * size)).astype(np.float32)


def feed(guard, frames, start=0.0, night=None):
    events = []
    for number, image in enumerate(frames):
        started, ended = guard.update(image, start + number * STEP, night)
        events.append((started, ended))
    return events


def started_names(events):
    return [name for started, _ in events for name in sorted(started)]


def warm(guard, image, count=10, night=None, seed=0):
    return feed(guard, [noisy(image, seed + number) for number in range(count)], night=night)


def test_a_steady_view_raises_nothing():
    guard = TamperGuard()
    events = warm(guard, scene(), count=40)
    assert started_names(events) == []
    assert guard.last["textured"]
    assert guard.last["regimes"] == 1


def test_samples_at_most_once_per_interval():
    guard = TamperGuard()
    image = noisy(scene(), 1)
    for offset in (0.0, 1.0, 2.5, 4.9):
        guard.update(image, offset)
    assert guard.last_at == 0.0
    guard.update(image, 5.0)
    assert guard.last_at == 5.0


def test_a_black_lens_is_covered_after_it_holds_and_clears_after():
    guard = TamperGuard()
    warm(guard, scene())
    black = [noisy(np.full((90, 160), 3.0, np.float32), 100 + number, 0.5) for number in range(4)]
    events = feed(guard, black, start=100.0)
    assert [sorted(started) for started, _ in events] == [[], [], ["covered"], []]
    back = feed(guard, [noisy(scene(), 200 + number) for number in range(6)], start=200.0)
    assert "covered" in set().union(*(ended for _, ended in back))
    assert started_names(back) == []


def test_a_bright_cloth_over_the_lens_is_covered():
    guard = TamperGuard()
    warm(guard, scene())
    cloth = [noisy(np.full((90, 160), 205.0, np.float32), 300 + number, 0.8) for number in range(4)]
    events = feed(guard, cloth, start=100.0)
    assert started_names(events) == ["covered"]


def test_a_dark_scene_is_dark_not_covered():
    guard = TamperGuard()
    warm(guard, scene())
    dim = [noisy(scene() * 0.12, 400 + number, 0.8) for number in range(4)]
    events = feed(guard, dim, start=100.0)
    assert started_names(events) == ["dark"]


def test_a_smeared_lens_is_blurred_not_moved():
    guard = TamperGuard()
    warm(guard, scene())
    smeared = [noisy(box_blur(scene()), 500 + number) for number in range(12)]
    events = feed(guard, smeared, start=100.0)
    assert started_names(events) == ["blurred"]


def test_a_turned_camera_is_moved_after_the_longer_hold_and_becomes_the_reference():
    guard = TamperGuard()
    warm(guard, scene())
    turned = np.roll(scene(), 45, axis=1)
    events = feed(guard, [noisy(turned, 600 + number) for number in range(5)], start=100.0)
    assert started_names(events) == []
    events = feed(guard, [noisy(turned, 700 + number) for number in range(2)], start=125.0)
    assert started_names(events) == ["moved"]
    later = feed(guard, [noisy(turned, 800 + number) for number in range(60)], start=135.0)
    assert "moved" in set().union(*(ended for _, ended in later))
    after = feed(guard, [noisy(turned, 900 + number) for number in range(20)], start=1000.0)
    assert started_names(after) == []


def test_a_moving_lens_never_reports_moved():
    guard = TamperGuard(moving=True)
    warm(guard, scene())
    turned = np.roll(scene(), 45, axis=1)
    events = feed(guard, [noisy(turned, 1000 + number) for number in range(40)], start=100.0)
    assert "moved" not in started_names(events)


def night_version(image):
    night = image * 0.45 + 18.0
    night[10:30, 10:30] = 200.0
    night[60:80, 120:140] = 15.0
    return night


def test_an_infrared_switch_with_a_hint_raises_nothing():
    guard = TamperGuard()
    warm(guard, scene(), count=12, night=False)
    night = [noisy(night_version(scene()), 1100 + number, 3.0) for number in range(40)]
    events = feed(guard, night, start=100.0, night=True)
    assert started_names(events) == []
    assert guard.last["mode"] == "night"
    day = [noisy(scene(), 1200 + number) for number in range(30)]
    events = feed(guard, day, start=400.0, night=False)
    assert started_names(events) == []
    assert guard.last["mode"] == "day"
    assert guard.last["regimes"] == 2


def test_an_infrared_switch_without_a_hint_raises_nothing():
    guard = TamperGuard()
    warm(guard, scene(), count=12)
    night = [noisy(night_version(scene()), 1300 + number, 3.0) for number in range(40)]
    events = feed(guard, night, start=100.0)
    assert started_names(events) == []
    assert guard.last["regimes"] == 2
    day = [noisy(scene(), 1400 + number) for number in range(30)]
    events = feed(guard, day, start=400.0)
    assert started_names(events) == []
    assert guard.last["regime"] == 0


def test_a_blank_wall_with_noise_raises_nothing():
    guard = TamperGuard()
    frames = []
    for number in range(80):
        image = blank_wall()
        image[3:6, 145:155] = np.random.default_rng(number).integers(170, 230, (3, 10))
        frames.append(noisy(image, 1500 + number, 1.0))
    events = feed(guard, frames)
    assert started_names(events) == []
    assert not guard.last["textured"]


def test_a_blank_wall_still_reports_a_cover():
    guard = TamperGuard()
    feed(guard, [noisy(blank_wall(), 1600 + number, 1.0) for number in range(10)])
    hand = [noisy(np.full((90, 160), 25.0, np.float32), 1700 + number, 1.0) for number in range(4)]
    events = feed(guard, hand, start=100.0)
    assert started_names(events) == ["covered"]


def test_a_dimmer_lamp_on_a_blank_wall_is_not_a_cover():
    guard = TamperGuard()
    feed(guard, [noisy(blank_wall(), 1800 + number, 1.0) for number in range(10)])
    dimmer = [noisy(blank_wall() * 0.8, 1900 + number, 1.0) for number in range(20)]
    events = feed(guard, dimmer, start=100.0)
    assert started_names(events) == []


def test_night_from_chroma():
    neutral = np.full((45, 80), 128, np.uint8)
    assert night_from_chroma(neutral, neutral + 1)
    coloured = np.full((45, 80), 150, np.uint8)
    assert not night_from_chroma(coloured, neutral)


def test_settings_from_view_configuration():
    settings = GuardSettings.from_dict({"interval": "10", "hold": 5, "unknown": 1})
    assert settings.interval == 10.0
    assert settings.hold == 5
    assert isinstance(settings.hold, int)
    assert GuardSettings.from_dict(None) == GuardSettings()
