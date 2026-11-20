import pytest

from app.rules.animals import ANIMALS, AnimalMode, AnimalPolicy, is_animal
from app.rules.engine import kind_of
from app.rules.model import EventKind


def test_animal_labels_include_birds():
    assert ANIMALS == {"dog", "cat", "bird"}
    assert is_animal("bird")
    assert not is_animal("person")


def test_animals_get_their_own_event_kind():
    assert kind_of("cat") == EventKind.ANIMAL
    assert kind_of("bird") == EventKind.ANIMAL
    assert kind_of("person") == EventKind.INTRUSION
    assert kind_of("car") == EventKind.VEHICLE


def test_animals_are_recorded_without_alerts_by_default():
    policy = AnimalPolicy.from_dict({"id": "yard"})
    assert policy.mode == AnimalMode.RECORD
    assert policy.produces("cat")
    assert not policy.may_alert("cat")
    assert policy.may_alert("person")


def test_included_animals_may_alert_and_excluded_ones_produce_nothing():
    included = AnimalPolicy.from_dict({"animals": "include"})
    assert included.may_alert("dog")
    excluded = AnimalPolicy.from_dict({"animals": "exclude"})
    assert not excluded.produces("bird")
    assert excluded.produces("person")
    assert excluded.may_alert("person")


def test_unknown_animal_mode_is_rejected():
    with pytest.raises(ValueError):
        AnimalPolicy.from_dict({"animals": "sometimes"})


def test_animal_events_alert_only_when_the_zone_includes_them():
    from tests.helpers import engine, run, walk

    square = [[0.0, 0.0], [1.0, 0.0], [1.0, 1.0], [0.0, 1.0]]
    alert = {"mode": "always"}
    for animals, expected in (("record", False), ("include", True)):
        rules = engine({"zones": [{"id": "yard", "polygon": square, "alert": alert, "animals": animals}]})
        updates = run(rules, walk(9, "cat", (0.2, 0.5), (0.6, 0.5), 3))
        opened = [update.event for update in updates if update.action == "open"]
        assert [event.kind for event in opened] == ["animal"]
        assert opened[0].alert is expected
    rules = engine({"zones": [{"id": "yard", "polygon": square, "alert": alert, "animals": "exclude"}]})
    assert run(rules, walk(9, "cat", (0.2, 0.5), (0.6, 0.5), 3)) == []
    rules = engine({"zones": [{"id": "yard", "polygon": square, "alert": alert}]})
    person = run(rules, walk(4, "person", (0.2, 0.5), (0.6, 0.5), 3))
    assert [update.event.alert for update in person if update.action == "open"] == [True]


def test_line_crossings_are_counted_through_the_hook():
    from tests.helpers import engine, run, walk

    crossings = []
    rules = engine({"lines": [{"id": "gate", "points": [[0.0, 0.5], [1.0, 0.5]], "animals": "exclude"}]})
    rules.on_crossing = lambda line, direction, label, at: crossings.append((line, direction, label))
    updates = run(rules, walk(5, "dog", (0.5, 0.2), (0.5, 0.8), 3))
    assert crossings == [("gate", "in", "dog")]
    assert updates == []
