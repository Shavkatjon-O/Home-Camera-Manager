import pytest

from app.counts.ledger import CountLedger, bucket_start

HOUR = 1_700_000_000 - 1_700_000_000 % 3600


def test_bucket_start():
    assert bucket_start(HOUR + 59.9) == HOUR
    assert bucket_start(HOUR + 3600) == HOUR + 3600


def test_report_carries_absolute_totals_of_changed_buckets_once():
    ledger = CountLedger()
    ledger.add("v", "gate", "in", "person", HOUR + 10)
    ledger.add("v", "gate", "in", "person", HOUR + 20)
    ledger.add("v", "gate", "out", "dog", HOUR + 3700)
    report = ledger.report(HOUR + 3800)
    assert report["boot"] == ledger.boot
    assert report["buckets"] == [
        {"view": "v", "line": "gate", "start": HOUR, "direction": "in", "label": "person", "count": 2},
        {"view": "v", "line": "gate", "start": HOUR + 3660, "direction": "out", "label": "dog", "count": 1},
    ]
    assert ledger.report(HOUR + 3900) is None
    ledger.add("v", "gate", "in", "person", HOUR + 30)
    assert ledger.report(HOUR + 4000)["buckets"] == [
        {"view": "v", "line": "gate", "start": HOUR, "direction": "in", "label": "person", "count": 3}
    ]


def test_a_lost_report_is_restored_and_resent():
    ledger = CountLedger()
    ledger.add("v", "door", "out", "person", HOUR + 5)
    lost = ledger.report(HOUR + 10)
    ledger.restore(lost)
    assert ledger.report(HOUR + 20)["buckets"] == lost["buckets"]


def test_old_buckets_are_dropped_after_retention():
    ledger = CountLedger(retention=3600)
    ledger.add("v", "gate", "in", "car", HOUR)
    ledger.report(HOUR + 10)
    ledger.report(HOUR + 3 * 3600)
    assert ledger.counts == {}


def test_totals_and_direction_check():
    ledger = CountLedger()
    ledger.add("v", "gate", "in", "person", HOUR, count=3)
    ledger.add("v", "gate", "out", "person", HOUR + 4000)
    ledger.add("v", "other", "out", "person", HOUR)
    assert ledger.totals("v", "gate") == {"in": {"person": 3}, "out": {"person": 1}}
    with pytest.raises(ValueError):
        ledger.add("v", "gate", "sideways", "person", HOUR)
    assert CountLedger().boot != ledger.boot
