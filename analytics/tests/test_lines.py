from helpers import actions, detection, engine, run, walk

from app.rules.model import ArmMode, Line

GATE = {"id": "gate", "name": "Gate", "points": [[0.2, 0.5], [0.8, 0.5]]}


def lines(**overrides):
    return {"lines": [{**GATE, **overrides}], "tuning": {"cooldown": 10}}


def test_walking_down_across_a_left_to_right_line_is_in():
    rules = engine(lines())
    updates = run(rules, walk(1, "person", (0.5, 0.3), (0.5, 0.7), 3))
    assert actions(updates) == [("instant", "line_crossing")]
    assert updates[0].event.direction == "in"
    assert rules.line_counts["gate"]["in"]["person"] == 1


def test_walking_up_is_out_and_direction_filter_applies():
    rules = engine(lines(direction="in"))
    updates = run(rules, walk(1, "person", (0.5, 0.7), (0.5, 0.3), 3))
    assert updates == []
    assert rules.line_counts["gate"]["out"]["person"] == 1


def test_jitter_on_the_line_does_not_count():
    rules = engine(lines())
    frames = [(step / 5, [detection(1, "person", 0.5, 0.5 + (0.004 if step % 2 else -0.004))]) for step in range(30)]
    assert run(rules, frames) == []


def test_passing_beside_the_segment_does_not_count():
    rules = engine(lines())
    assert run(rules, walk(1, "person", (0.95, 0.3), (0.95, 0.7), 3)) == []


def test_crossing_back_and_forth_is_debounced_per_object():
    rules = engine(lines())
    frames = walk(1, "person", (0.5, 0.3), (0.5, 0.7), 2) + walk(1, "person", (0.5, 0.7), (0.5, 0.3), 2, offset=2.2)
    frames += walk(1, "person", (0.5, 0.3), (0.5, 0.7), 2, offset=4.4)
    updates = run(rules, frames)
    assert [update.event.direction for update in updates] == ["in", "out"]
    assert rules.line_counts["gate"]["in"]["person"] == 2


def test_label_filter_and_alert_policy():
    config = lines(labels=["person"], alert={"mode": "always", "labels": ["person"]})
    rules = engine(config, arm=ArmMode.HOME)
    assert run(rules, walk(1, "dog", (0.5, 0.3), (0.5, 0.7), 2)) == []
    updates = run(rules, walk(2, "person", (0.4, 0.3), (0.4, 0.7), 2, offset=5))
    assert updates[0].event.alert is True


def test_line_validates_direction():
    try:
        Line.from_dict({**GATE, "direction": "sideways"})
    except ValueError:
        return
    raise AssertionError("expected a ValueError")
