from helpers import START, actions, detection, engine, run, walk

from app.rules.model import EventKind

YARD = {"id": "yard", "name": "Yard", "polygon": [[0.0, 0.3], [1.0, 0.3], [1.0, 1.0], [0.0, 1.0]]}


def zone(**overrides):
    return {"zones": [{**YARD, **overrides}], "tuning": {"close_after": 3, "cooldown": 10}}


def test_intrusion_opens_after_dwell_and_closes_after_delay():
    rules = engine(zone(labels=["person"], min_dwell=1.0))
    updates = run(rules, walk(1, "person", (0.1, 0.5), (0.9, 0.6), 4))
    assert actions(updates) == [("open", "intrusion")]
    opened = updates[0].event
    assert opened.started_at == START + 1.0
    assert opened.label == "person"
    assert opened.zone_name == "Yard"
    assert opened.boxes[0]["object"] == 1
    closing = rules.tick(START + 8)
    assert actions(closing) == [("close", "intrusion")]
    assert closing[0].event.ended_at == START + 4


def test_short_visit_below_dwell_does_not_open():
    rules = engine(zone(min_dwell=2.0))
    assert run(rules, walk(1, "person", (0.1, 0.5), (0.3, 0.5), 1)) == []


def test_class_filter():
    rules = engine(zone(labels=["person"]))
    assert run(rules, walk(1, "dog", (0.1, 0.5), (0.9, 0.5), 4)) == []


def test_objects_outside_the_polygon_are_ignored():
    rules = engine(zone())
    assert run(rules, walk(1, "person", (0.1, 0.1), (0.9, 0.2), 4)) == []


def test_parked_vehicle_never_opens_but_a_moving_one_does():
    rules = engine(zone(labels=["vehicle"]))
    parked = [(step / 5, [detection(7, "car", 0.5, 0.6)]) for step in range(50)]
    assert run(rules, parked) == []
    updates = run(rules, walk(8, "car", (0.1, 0.9), (0.4, 0.7), 4, offset=10))
    assert actions(updates) == [("open", "vehicle")]


def test_object_present_while_warming_up_must_move():
    rules = engine({**zone(), "tuning": {"close_after": 3, "cooldown": 10, "warmup": 8}})
    standing = [(step / 5, [detection(1, "person", 0.5, 0.6)]) for step in range(40)]
    assert run(rules, standing) == []
    updates = run(rules, walk(1, "person", (0.5, 0.6), (0.9, 0.6), 4, offset=8))
    assert actions(updates) == [("open", "intrusion")]


def test_one_episode_per_label_and_a_crowd_needs_its_count():
    rules = engine(zone(crowd_count=4))
    frames = []
    for step in range(20):
        at = step / 5
        frames.append(
            (
                at,
                [
                    detection(1, "person", 0.2 + at / 20, 0.6),
                    detection(2, "person", 0.5 + at / 20, 0.7),
                    detection(3, "dog", 0.6 + at / 20, 0.8),
                ],
            )
        )
    updates = run(rules, frames)
    assert sorted(set(actions(updates))) == [("open", "intrusion"), ("update", "intrusion")]
    labels = sorted(update.event.label for update in updates if update.action == "open")
    assert labels == ["dog", "person"]
    person = next(update.event for update in updates if update.event.label == "person")
    assert person.objects == [1, 2]
    assert person.count == 2


def test_crowd_opens_when_enough_objects_are_inside():
    rules = engine(zone(crowd_count=2))
    frames = [
        (step / 5, [detection(1, "person", 0.2 + step / 100, 0.6), detection(2, "person", 0.6 + step / 100, 0.6)])
        for step in range(20)
    ]
    updates = run(rules, frames)
    crowd = [update for update in updates if update.event.kind == EventKind.CROWD]
    assert crowd[0].action == "open"
    assert crowd[0].event.count == 2


def test_cooldown_blocks_an_immediate_new_episode():
    rules = engine(zone())
    first = run(rules, walk(1, "person", (0.1, 0.5), (0.5, 0.5), 2))
    assert actions(first) == [("open", "intrusion")]
    rules.tick(START + 6)
    second = run(rules, walk(2, "person", (0.9, 0.5), (0.6, 0.5), 2, offset=8))
    assert second == []
    third = run(rules, walk(3, "person", (0.9, 0.5), (0.6, 0.5), 2, offset=30))
    assert actions(third) == [("open", "intrusion")]


def test_schedule_gates_new_episodes():
    rules = engine(zone(schedule=[{"start": "00:00", "end": "00:01"}]))
    assert run(rules, walk(1, "person", (0.1, 0.5), (0.5, 0.5), 3)) == []


def test_suspended_zone_is_silent_and_reconfiguring_closes_episodes():
    rules = engine(zone())
    updates = run(rules, walk(1, "person", (0.1, 0.5), (0.5, 0.5), 2))
    assert actions(updates) == [("open", "intrusion")]
    closed = rules.configure(rules.rules.__class__.from_dict(zone(suspended=True)))
    assert actions(closed) == [("close", "intrusion")]
    assert run(rules, walk(2, "person", (0.1, 0.5), (0.5, 0.5), 2, offset=40)) == []


def test_static_false_positive_stops_counting():
    rules = engine({"zones": [YARD], "tuning": {"static_seconds": 5, "close_after": 2}})
    standing = [(step / 5, [detection(1, "person", 0.3 + (step % 2) * 0.001, 0.6)]) for step in range(60)]
    updates = run(rules, standing)
    assert actions(updates) == [("open", "intrusion"), ("close", "intrusion")]


def test_loitering_fires_once_per_stay():
    rules = engine(zone(loiter_seconds=5))
    frames = [(step / 5, [detection(1, "person", 0.3 + step / 1000, 0.6)]) for step in range(60)]
    updates = run(rules, frames)
    loitering = [update for update in updates if update.event.kind == EventKind.LOITERING]
    assert [update.action for update in loitering] == ["instant"]
    assert loitering[0].event.started_at == START + 5


def test_lost_track_rejoins_and_keeps_its_dwell():
    rules = engine(zone(loiter_seconds=4, min_dwell=0.5))
    frames = [(step / 5, [detection(1, "person", 0.3 + step / 500, 0.6)]) for step in range(12)]
    frames += [(3.0 + step / 5, [detection(9, "person", 0.33 + step / 500, 0.6)]) for step in range(10)]
    updates = run(rules, frames)
    assert [update.event.kind.value for update in updates if update.action in ("open", "instant")] == [
        "intrusion",
        "loitering",
    ]
    intrusion = next(update.event for update in updates if update.event.kind == EventKind.INTRUSION)
    assert intrusion.objects == [1]


def test_box_jitter_of_a_partly_visible_car_is_not_movement():
    from app.rules.model import Box, Detection

    rules = engine(zone(labels=["vehicle"], polygon=[[0.0, 0.0], [1.0, 0.0], [1.0, 1.0], [0.0, 1.0]]))
    frames = []
    for step in range(100):
        grow = 0.04 if step % 7 == 0 else 0.0
        box = Box(0.47, 0.0, 0.63, 0.06 + grow + (step % 3) * 0.01)
        frames.append((step / 5, [Detection(4, "car", 0.8, box)]))
    assert run(rules, frames) == []


def test_parked_car_that_became_static_stays_silent_when_its_box_shifts():
    from app.rules.model import Box, Detection

    rules = engine({"zones": [{**YARD, "labels": ["vehicle"], "loiter_seconds": 5}], "tuning": {"static_seconds": 20}})
    frames = []
    for step in range(400):
        shift = 0.03 if step > 150 and step % 5 == 0 else 0.0
        frames.append((step / 5, [Detection(3, "car", 0.9, Box(0.3, 0.4 + shift, 0.45, 0.62 + shift))]))
    assert run(rules, frames) == []


def test_vehicles_never_loiter():
    rules = engine(zone(labels=["vehicle"], loiter_seconds=2))
    frames = walk(8, "car", (0.1, 0.9), (0.4, 0.7), 3)
    frames += [(3.2 + step / 5, [detection(8, "car", 0.4, 0.7)]) for step in range(40)]
    kinds = {update.event.kind.value for update in run(rules, frames)}
    assert kinds == {"vehicle"}
