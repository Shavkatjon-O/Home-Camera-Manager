from datetime import UTC

import numpy as np

from app.objects.background import BackgroundWatch, components, zone_mask
from app.objects.watch import ObjectWatch
from app.objects.zones import DEFAULT_LABELS, ObjectZone, object_zones
from app.rules.model import ArmMode, Box, Detection, Frame

START = 1_700_000_000.0
FPS = 2
WHOLE = [[0, 0], [1, 0], [1, 1], [0, 1]]


def zone(**settings):
    return {"id": "z", "name": "Porch", "polygon": WHOLE, "alert": {"mode": "always"}, **settings}


def box(x, y, width=0.04, height=0.06):
    return Box(x - width / 2, y - height, x + width / 2, y)


def item(track, label, at, confidence=0.8):
    return Detection(track, label, confidence, at)


def run(watch, zones, seconds, objects_at, fps=FPS, arm=ArmMode.AWAY):
    updates = []
    for step in range(int(seconds * fps)):
        at = step / fps
        frame = Frame(START + at, tuple(objects_at(at)))
        updates += [(at, update) for update in watch.update(frame, zones, arm, UTC)]
    return updates


def kinds(updates):
    return [(update.event.kind.value, update.event.label) for _, update in updates]


def test_zone_settings_and_defaults():
    parsed = ObjectZone.from_dict(zone(left_seconds=60, object_labels=["car"]))
    assert parsed.left_seconds == 60
    assert parsed.labels == frozenset({"car"})
    assert ObjectZone.from_dict(zone(left_seconds=60)).labels == DEFAULT_LABELS
    assert object_zones([zone()]) == []
    assert object_zones([zone(taken_seconds=10, enabled=False)]) == []


def test_an_object_set_down_is_left_once_after_the_left_time():
    watch = ObjectWatch("view")
    zones = [zone(left_seconds=60)]

    def objects(at):
        found = []
        if 40 <= at < 46:
            found.append(item(1, "person", box(0.3 + (at - 40) * 0.05, 0.8, 0.08, 0.3)))
        if at >= 42:
            found.append(item(5, "backpack", box(0.4, 0.8)))
        return found

    updates = run(watch, zones, 200, objects)
    assert kinds(updates) == [("object_left", "backpack")]
    at, update = updates[0]
    assert 101 <= at <= 103
    assert update.event.alert
    assert update.event.boxes[0]["label"] == "backpack"


def test_objects_present_at_start_are_never_left():
    watch = ObjectWatch("view")
    updates = run(watch, [zone(left_seconds=30)], 600, lambda at: [item(5, "suitcase", box(0.5, 0.7))])
    assert updates == []


def test_a_present_object_carried_off_is_taken_after_the_grace():
    watch = ObjectWatch("view")
    zones = [zone(taken_seconds=120)]

    def objects(at):
        found = []
        if at < 205:
            found.append(item(5, "suitcase", box(0.5, 0.7)))
        if 198 <= at < 206:
            found.append(item(9, "person", box(0.52, 0.75, 0.1, 0.35)))
        return found

    updates = run(watch, zones, 400, objects)
    assert kinds(updates) == [("object_taken", "suitcase")]
    at, _ = updates[0]
    assert 264 <= at <= 267


def test_a_person_standing_over_the_place_postpones_taken():
    watch = ObjectWatch("view")
    zones = [zone(taken_seconds=120)]

    def objects(at):
        found = []
        if at < 200:
            found.append(item(5, "suitcase", box(0.5, 0.7)))
        if 200 <= at < 300:
            found.append(item(9, "person", box(0.5, 0.72, 0.1, 0.35)))
        return found

    updates = run(watch, zones, 420, objects)
    assert kinds(updates) == [("object_taken", "suitcase")]
    at, _ = updates[0]
    assert at >= 359


def test_an_object_that_comes_back_is_not_taken():
    watch = ObjectWatch("view")
    zones = [zone(taken_seconds=120)]

    def objects(at):
        found = []
        if at < 200 or at >= 240:
            found.append(item(5, "suitcase", box(0.5, 0.7)))
        if 198 <= at < 202:
            found.append(item(9, "person", box(0.52, 0.75, 0.1, 0.35)))
        return found

    assert run(watch, zones, 500, objects) == []


def test_detections_fading_at_night_are_not_taken():
    watch = ObjectWatch("view")
    zones = [zone(taken_seconds=120)]
    updates = run(watch, zones, 1200, lambda at: [item(5, "bicycle", box(0.5, 0.7))] if at < 300 else [])
    assert updates == []


def test_a_parking_area_stays_silent_all_night():
    watch = ObjectWatch("view")
    zones = [zone(left_seconds=300, taken_seconds=600)]
    generator = np.random.default_rng(3)
    cars = [box(0.2, 0.6, 0.2, 0.15), box(0.45, 0.6, 0.2, 0.15), box(0.7, 0.6, 0.2, 0.15)]
    track = [100]

    def objects(at):
        found = [item(10 + index, "car", car) for index, car in enumerate(cars)]
        if at < 4 * 3600 or at > 6 * 3600:
            if generator.random() < 0.3:
                track[0] += 1 if generator.random() < 0.1 else 0
                found.append(item(track[0], "bicycle", box(0.85, 0.75, 0.05, 0.08), 0.45))
        if 3600 <= at % 7200 < 3610:
            found.append(item(500 + int(at // 7200), "person", box(0.1 + (at % 10) * 0.02, 0.9, 0.06, 0.3)))
        return found

    assert run(watch, zones, 8 * 3600, objects, fps=0.5) == []


def test_a_car_driving_off_is_taken_when_cars_are_watched():
    watch = ObjectWatch("view")
    zones = [zone(taken_seconds=300, object_labels=["car"])]

    def objects(at):
        if at < 600:
            return [item(3, "car", box(0.4, 0.6, 0.2, 0.15))]
        if at < 610:
            return [item(3, "car", box(0.4 + (at - 600) * 0.05, 0.6, 0.2, 0.15))]
        return []

    updates = run(watch, zones, 800, objects)
    assert kinds(updates) == [("object_taken", "car")]
    assert updates[0][1].event.boxes[0]["box"] == box(0.4, 0.6, 0.2, 0.15).rounded()


def plain(seed):
    generator = np.random.default_rng(seed)
    image = np.full((90, 160), 100.0, np.float32)
    image[:, 80:] = 140.0
    return image + generator.normal(0, 1.5, image.shape).astype(np.float32)


def feed_background(watch, zones, seconds, picture, boxes=lambda at: [], step=2.0):
    updates = []
    for number in range(int(seconds / step)):
        at = START + number * step
        image = picture(number * step, number)
        updates += [
            (number * step, update)
            for update in watch.update(image, at, zones, ArmMode.AWAY, UTC, boxes(number * step))
        ]
    return updates


def test_background_fallback_finds_an_unclassed_box_left_and_taken():
    watch = BackgroundWatch("view")
    zones = [zone(left_seconds=60, taken_seconds=100, background=True)]

    def picture(at, number):
        image = plain(number)
        if 100 <= at < 300:
            image[40:50, 30:40] = 210.0
        return image

    updates = feed_background(watch, zones, 400, picture)
    assert kinds(updates) == [("object_left", "object"), ("object_taken", "object")]
    left_at, left = updates[0]
    assert 158 <= left_at <= 166
    assert left.event.boxes[0]["box"] == [0.1875, 0.4444, 0.25, 0.5556]
    assert 300 <= updates[1][0] <= 310


def test_background_fallback_ignores_detected_objects_and_brightness_steps():
    watch = BackgroundWatch("view")
    zones = [zone(left_seconds=60, background=True)]

    def picture(at, number):
        image = plain(number)
        if at >= 100:
            image[40:50, 30:40] = 210.0
        if at >= 300:
            image += 45.0
        return image

    def boxes(at):
        return [Box(0.18, 0.43, 0.26, 0.57)] if at < 300 else []

    assert feed_background(watch, zones, 340, picture, boxes) == []


def test_background_fallback_is_off_without_the_zone_setting():
    watch = BackgroundWatch("view")
    assert feed_background(watch, [zone(left_seconds=60)], 100, lambda at, number: plain(number)) == []
    assert watch.background is None


def test_masks_and_components():
    mask = zone_mask(((0.0, 0.0), (0.5, 0.0), (0.5, 1.0), (0.0, 1.0)), 9, 16)
    assert mask[:, :8].all() and not mask[:, 8:].any()
    grid = np.zeros((6, 6), dtype=bool)
    grid[0:2, 0:2] = True
    grid[4:6, 3:6] = True
    assert sorted(len(part) for part in components(grid)) == [4, 6]
