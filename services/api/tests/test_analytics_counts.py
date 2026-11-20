from datetime import UTC, datetime, timedelta
from uuid import uuid4
from zoneinfo import ZoneInfo

import pytest
from pydantic import ValidationError

from app.modules.analytics.schemas.counts import AreaCreate, AreaUpdate, CountReportIn
from app.modules.analytics.services.counts import aggregate, local_bucket, occupancy, occupancy_start

ZONE = ZoneInfo("Asia/Tashkent")


def at(hour, minute=0, day=20):
    return datetime(2026, 11, day, hour, minute, tzinfo=ZONE).astimezone(UTC)


def test_local_bucket():
    assert local_bucket(at(5, 37), "hour", ZONE) == datetime(2026, 11, 20, 5, tzinfo=ZONE)
    assert local_bucket(at(0, 10), "day", ZONE) == datetime(2026, 11, 20, tzinfo=ZONE)
    assert local_bucket(at(23, 59, day=19), "day", ZONE) == datetime(2026, 11, 19, tzinfo=ZONE)


def test_aggregate_sums_minutes_into_hours_and_totals():
    gate, door = uuid4(), uuid4()
    rows = [
        (gate, at(5, 1), "in", "person", 2),
        (gate, at(5, 59), "in", "person", 1),
        (gate, at(5, 30), "out", "person", 1),
        (gate, at(6, 0), "in", "dog", 1),
        (door, at(5, 15), "out", "person", 4),
    ]
    buckets, totals = aggregate(rows, "hour", ZONE)
    by_key = {(item.line_uuid, item.at.hour, item.label): (item.in_, item.out) for item in buckets}
    assert by_key[(gate, 5, "person")] == (3, 1)
    assert by_key[(gate, 6, "dog")] == (1, 0)
    assert by_key[(door, 5, "person")] == (0, 4)
    assert [item.at for item in buckets] == sorted(item.at for item in buckets)
    total = {item.line_uuid: item for item in totals}
    assert (total[gate].in_, total[gate].out) == (4, 1)
    assert total[gate].labels == {"person": {"in": 3, "out": 1}, "dog": {"in": 1, "out": 0}}
    dumped = buckets[0].model_dump(by_alias=True)
    assert "in" in dumped and "in_" not in dumped


def test_occupancy_start_prefers_the_latest_of_hand_set_and_daily_reset():
    since = at(2)
    start, hand = occupancy_start(at(5), "04:00", since, ZONE)
    assert (start, hand) == (datetime(2026, 11, 20, 4, tzinfo=ZONE), False)
    start, hand = occupancy_start(at(3), "04:00", since, ZONE)
    assert (start, hand) == (since, True)
    later = at(4, 30)
    assert occupancy_start(at(5), "04:00", later, ZONE) == (later, True)
    assert occupancy_start(at(5), None, since, ZONE) == (since, True)


def test_occupancy_counts_entering_direction_per_line_and_labels():
    door, gate = uuid4(), uuid4()
    lines = {door: "in", gate: "out"}
    rows = [(door, "in", "person", 3), (door, "out", "person", 1), (gate, "out", "person", 2), (gate, "in", "dog", 5)]
    assert occupancy(lines, set(), rows, 0) == (0, 5, 6)
    assert occupancy(lines, {"person"}, rows, 0) == (4, 5, 1)
    assert occupancy(lines, {"person"}, rows, 2) == (6, 5, 1)
    assert occupancy({door: "in"}, set(), [(uuid4(), "in", "person", 9)], 0) == (0, 0, 0)


def test_schemas_validate():
    with pytest.raises(ValidationError):
        AreaCreate(name="House", lines=[], labels=[])
    with pytest.raises(ValidationError):
        AreaCreate(name="House", lines=[{"line_uuid": str(uuid4()), "entering": "in"}], reset_at="25:00")
    area = AreaCreate(name="House", lines=[{"line_uuid": str(uuid4()), "entering": "out"}], labels=["person", "person"])
    assert area.labels == ["person"]
    assert "reset_at" not in AreaUpdate(name="Home").model_fields_set
    report = CountReportIn(
        boot="b",
        at=1.0,
        buckets=[
            {"view": str(uuid4()), "line": str(uuid4()), "start": 60, "direction": "in", "label": "person", "count": 2}
        ],
    )
    assert report.buckets[0].count == 2
    with pytest.raises(ValidationError):
        CountReportIn(
            boot="b",
            at=1.0,
            buckets=[
                {"view": str(uuid4()), "line": str(uuid4()), "start": 60, "direction": "up", "label": "x", "count": 1}
            ],
        )
    assert timedelta(days=2) < timedelta(days=3)
