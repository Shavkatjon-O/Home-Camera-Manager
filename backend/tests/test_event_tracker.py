from datetime import UTC, datetime, timedelta
from uuid import uuid4

from app.camera_events.tracker import EventTracker

T0 = datetime(2026, 11, 19, 21, 44, 8, tzinfo=UTC)
CAMERA = uuid4()
MOTION = "RuleEngine/CellMotionDetector/Motion"
ALARM = "VideoSource/MotionAlarm"


def at(seconds: float) -> datetime:
    return T0 + timedelta(seconds=seconds)


def test_two_topics_share_one_event_until_both_stop():
    tracker = EventTracker()
    opened = tracker.start(CAMERA, "motion", ALARM, at(0))
    assert opened is not None
    assert tracker.start(CAMERA, "motion", MOTION, at(0)) is None
    tracker.stop(CAMERA, ALARM, at(12))
    assert tracker.due(at(30)) == []
    tracker.stop(CAMERA, MOTION, at(12))
    assert tracker.due(at(16)) == []
    closing = tracker.due(at(17))
    assert [(item.event.uuid, item.ended_at, item.capped) for item in closing] == [(opened.uuid, at(12), False)]


def test_restart_within_five_seconds_merges():
    tracker = EventTracker()
    first = tracker.start(CAMERA, "motion", MOTION, at(0))
    tracker.stop(CAMERA, MOTION, at(3))
    assert tracker.start(CAMERA, "motion", MOTION, at(6)) is None
    tracker.stop(CAMERA, MOTION, at(9))
    assert tracker.due(at(13)) == []
    closing = tracker.due(at(14))
    assert closing[0].event.uuid == first.uuid
    assert closing[0].ended_at == at(9)


def test_restart_after_five_seconds_opens_a_new_event():
    tracker = EventTracker()
    first = tracker.start(CAMERA, "motion", MOTION, at(0))
    tracker.stop(CAMERA, MOTION, at(3))
    assert [item.event.uuid for item in tracker.due(at(8))] == [first.uuid]
    second = tracker.start(CAMERA, "motion", MOTION, at(9))
    assert second is not None and second.uuid != first.uuid


def test_open_event_is_capped_at_ten_minutes():
    tracker = EventTracker()
    opened = tracker.start(CAMERA, "motion", MOTION, at(0))
    assert tracker.due(at(599)) == []
    closing = tracker.due(at(600))
    assert closing[0].event.uuid == opened.uuid
    assert closing[0].ended_at == at(600)
    assert closing[0].capped is True


def test_keep_only_extends_an_open_event():
    tracker = EventTracker()
    assert tracker.keep(CAMERA, "motion", MOTION) is False
    tracker.start(CAMERA, "motion", ALARM, at(0))
    assert tracker.keep(CAMERA, "motion", MOTION) is True
    tracker.stop(CAMERA, ALARM, at(1))
    assert tracker.due(at(10)) == []


def test_stop_closes_events_of_every_kind_holding_the_topic():
    tracker = EventTracker()
    tracker.start(CAMERA, "person", MOTION, at(0))
    tracker.stop(CAMERA, MOTION, at(2))
    closing = tracker.due(at(7))
    assert [item.event.kind for item in closing] == ["person"]


def test_closing_remembers_every_topic_seen():
    tracker = EventTracker()
    tracker.start(CAMERA, "motion", ALARM, at(0))
    tracker.start(CAMERA, "motion", MOTION, at(0))
    tracker.stop(CAMERA, ALARM, at(1))
    tracker.stop(CAMERA, MOTION, at(1))
    closing = tracker.due(at(6))
    assert closing[0].event.seen == {ALARM, MOTION}
