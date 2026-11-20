import pytest

from app.rules.animals import ANIMALS, AnimalMode, AnimalPolicy, event_kind, is_animal
from app.rules.kinds import ExtraKind
from app.rules.model import EventKind


def test_animal_labels_include_birds():
    assert ANIMALS == {"dog", "cat", "bird"}
    assert is_animal("bird")
    assert not is_animal("person")


def test_animals_get_their_own_event_kind():
    assert event_kind("cat", EventKind.INTRUSION) == ExtraKind.ANIMAL
    assert event_kind("person", EventKind.INTRUSION) == EventKind.INTRUSION
    assert event_kind("car", EventKind.VEHICLE) == EventKind.VEHICLE


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
