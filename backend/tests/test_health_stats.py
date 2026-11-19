from datetime import UTC, datetime, timedelta

import pytest

from app.health.stats import (
    BucketCounts,
    availability,
    bucket_window,
    fill_buckets,
    latency_summary,
    percentile,
)

UNTIL = datetime(2026, 11, 19, 12, 34, 56, 500000, tzinfo=UTC)


def reference_percentile(values: list[float], fraction: float) -> float:
    ordered = sorted(values)
    position = fraction * (len(ordered) - 1)
    lower = int(position)
    upper = min(lower + 1, len(ordered) - 1)
    return ordered[lower] + (ordered[upper] - ordered[lower]) * (position - lower)


def histogram_of(values: list[float]) -> list[tuple[float, int]]:
    counts: dict[float, int] = {}
    for value in values:
        counts[value] = counts.get(value, 0) + 1
    return list(counts.items())


def test_hour_window_has_sixty_minute_buckets_ending_with_the_current_one():
    window = bucket_window(UNTIL, 3600, 60)
    assert window.count == 60
    assert window.since == datetime(2026, 11, 19, 11, 35, tzinfo=UTC)
    assert window.start(59) == datetime(2026, 11, 19, 12, 34, tzinfo=UTC)
    assert window.until == UNTIL


def test_day_and_week_windows_align_to_their_bucket_size():
    day = bucket_window(UNTIL, 86400, 900)
    assert day.count == 96
    assert day.start(95) == datetime(2026, 11, 19, 12, 30, tzinfo=UTC)
    assert day.since == datetime(2026, 11, 18, 12, 45, tzinfo=UTC)
    week = bucket_window(UNTIL, 604800, 7200)
    assert week.count == 84
    assert week.start(83) == datetime(2026, 11, 19, 12, 0, tzinfo=UTC)
    assert week.since == datetime(2026, 11, 12, 14, 0, tzinfo=UTC)


def test_bucket_index_covers_the_window_only():
    window = bucket_window(UNTIL, 3600, 60)
    assert window.index(window.since) == 0
    assert window.index(window.since + timedelta(seconds=59.9)) == 0
    assert window.index(window.since + timedelta(seconds=60)) == 1
    assert window.index(UNTIL) == 59
    assert window.index(window.since - timedelta(seconds=1)) is None
    assert window.index(window.since + timedelta(hours=1)) is None


def test_refine_keeps_the_span_with_smaller_buckets():
    window = bucket_window(UNTIL, 86400, 900)
    fine = window.refine(300)
    assert fine.since == window.since
    assert fine.size == 300
    assert fine.count == 288
    assert fine.start(fine.count) == window.start(window.count)


def test_availability_is_a_percent_of_answered_samples():
    assert availability(0, 0) is None
    assert availability(6, 6) == 100.0
    assert availability(6, 0) == 0.0
    assert availability(3, 2) == 66.67


def test_fill_buckets_keeps_gaps_as_no_data():
    window = bucket_window(UNTIL, 300, 60)
    counts = {
        window.start(0): BucketCounts(samples=6, ok=6, latency_ms=10.04),
        window.start(2): BucketCounts(samples=6, ok=3, latency_ms=20.0),
        window.start(4): BucketCounts(samples=6, ok=0, latency_ms=None),
        window.since - timedelta(minutes=1): BucketCounts(samples=6, ok=6, latency_ms=1.0),
    }
    buckets = fill_buckets(window, counts)
    assert [bucket.start for bucket in buckets] == [window.start(index) for index in range(5)]
    assert [bucket.availability for bucket in buckets] == [100.0, None, 50.0, None, 0.0]
    assert [bucket.latency_ms for bucket in buckets] == [10.0, None, 20.0, None, None]
    assert [bucket.samples for bucket in buckets] == [6, 0, 6, 0, 6]
    assert sum(bucket.ok for bucket in buckets) == 9


@pytest.mark.parametrize("fraction", [0.0, 0.5, 0.95, 1.0])
def test_percentile_matches_linear_interpolation_on_raw_values(fraction):
    values = [7.1, 7.1, 8.0, 9.4, 9.4, 9.4, 10.2, 12.5, 15.0, 48.3, 7.1, 8.0]
    expected = reference_percentile(values, fraction)
    assert percentile(histogram_of(values), fraction) == pytest.approx(expected)


def test_percentile_of_one_to_ten():
    histogram = [(float(value), 1) for value in range(1, 11)]
    assert percentile(histogram, 0.5) == pytest.approx(5.5)
    assert percentile(histogram, 0.95) == pytest.approx(9.55)


def test_percentile_ignores_empty_counts():
    assert percentile([], 0.5) is None
    assert percentile([(3.0, 0)], 0.5) is None
    assert percentile([(3.0, 0), (5.0, 2)], 0.95) == 5.0


def test_latency_summary_from_a_histogram():
    summary = latency_summary([(10.0, 3), (20.0, 1), (5.0, 0)])
    assert summary.avg_ms == 12.5
    assert summary.p50_ms == 10.0
    assert summary.p95_ms == 18.5
    assert summary.max_ms == 20.0


def test_latency_summary_without_samples_is_empty():
    summary = latency_summary([])
    assert (summary.avg_ms, summary.p50_ms, summary.p95_ms, summary.max_ms) == (None, None, None, None)
