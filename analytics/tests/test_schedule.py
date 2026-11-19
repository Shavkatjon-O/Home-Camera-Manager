from datetime import datetime

import pytest

from app.rules.schedule import Schedule, Window, parse_clock


def test_empty_schedule_is_always_active():
    assert Schedule.from_list(None).active(datetime(2026, 11, 20, 12, 0))


def test_window_within_one_day():
    window = Window.from_dict({"start": "08:00", "end": "18:00"})
    assert window.contains(datetime(2026, 11, 20, 8, 0))
    assert not window.contains(datetime(2026, 11, 20, 18, 0))


def test_window_across_midnight_belongs_to_its_start_day():
    window = Window.from_dict({"start": "23:00", "end": "06:00", "days": [4]})
    assert window.contains(datetime(2026, 11, 20, 23, 30))
    assert window.contains(datetime(2026, 11, 21, 5, 59))
    assert not window.contains(datetime(2026, 11, 21, 6, 0))
    assert not window.contains(datetime(2026, 11, 20, 5, 0))
    assert not window.contains(datetime(2026, 11, 21, 23, 30))


def test_schedule_with_several_windows():
    schedule = Schedule.from_list([{"start": "00:00", "end": "06:00"}, {"start": "22:00", "end": "23:00"}])
    assert schedule.active(datetime(2026, 11, 20, 3, 0))
    assert schedule.active(datetime(2026, 11, 20, 22, 30))
    assert not schedule.active(datetime(2026, 11, 20, 12, 0))


def test_parse_clock_rejects_garbage():
    with pytest.raises(ValueError):
        parse_clock("25:00")
