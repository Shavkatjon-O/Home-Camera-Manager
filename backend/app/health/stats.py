import math
from dataclasses import dataclass
from datetime import UTC, datetime, timedelta

PERCENT_DECIMALS = 2
LATENCY_DECIMALS = 1


@dataclass(frozen=True)
class Window:
    since: datetime
    until: datetime
    size: int
    count: int

    def start(self, index: int) -> datetime:
        return self.since + timedelta(seconds=index * self.size)

    def index(self, at: datetime) -> int | None:
        offset = (at - self.since).total_seconds()
        if offset < 0:
            return None
        position = int(offset // self.size)
        return position if position < self.count else None

    def refine(self, size: int) -> "Window":
        return Window(since=self.since, until=self.until, size=size, count=self.count * self.size // size)


@dataclass(frozen=True)
class BucketCounts:
    samples: int
    ok: int
    latency_ms: float | None


@dataclass(frozen=True)
class Bucket:
    start: datetime
    samples: int
    ok: int
    availability: float | None
    latency_ms: float | None


@dataclass(frozen=True)
class LatencySummary:
    avg_ms: float | None
    p50_ms: float | None
    p95_ms: float | None
    max_ms: float | None


EMPTY_LATENCY = LatencySummary(avg_ms=None, p50_ms=None, p95_ms=None, max_ms=None)


def bucket_window(until: datetime, span_seconds: int, size: int) -> Window:
    count = max(1, span_seconds // size)
    epoch = math.floor(until.timestamp())
    last = epoch - epoch % size
    since = datetime.fromtimestamp(last - (count - 1) * size, UTC)
    return Window(since=since, until=until, size=size, count=count)


def availability(samples: int, ok: int) -> float | None:
    if samples <= 0:
        return None
    return round(ok * 100 / samples, PERCENT_DECIMALS)


def fill_buckets(window: Window, counts: dict[datetime, BucketCounts]) -> list[Bucket]:
    by_index: dict[int, BucketCounts] = {}
    for start, value in counts.items():
        index = window.index(start)
        if index is not None:
            by_index[index] = value
    buckets = []
    for index in range(window.count):
        value = by_index.get(index)
        if value is None:
            buckets.append(Bucket(start=window.start(index), samples=0, ok=0, availability=None, latency_ms=None))
            continue
        latency = round(value.latency_ms, LATENCY_DECIMALS) if value.latency_ms is not None else None
        buckets.append(
            Bucket(
                start=window.start(index),
                samples=value.samples,
                ok=value.ok,
                availability=availability(value.samples, value.ok),
                latency_ms=latency,
            )
        )
    return buckets


def value_at(histogram: list[tuple[float, int]], rank: int) -> float:
    seen = 0
    for value, count in histogram:
        seen += count
        if rank < seen:
            return value
    return histogram[-1][0]


def percentile(histogram: list[tuple[float, int]], fraction: float) -> float | None:
    ordered = sorted((value, count) for value, count in histogram if count > 0)
    total = sum(count for _, count in ordered)
    if total == 0:
        return None
    position = fraction * (total - 1)
    lower = math.floor(position)
    upper = math.ceil(position)
    low = value_at(ordered, lower)
    high = value_at(ordered, upper)
    return low + (high - low) * (position - lower)


def latency_summary(histogram: list[tuple[float, int]]) -> LatencySummary:
    filled = [(value, count) for value, count in histogram if count > 0]
    total = sum(count for _, count in filled)
    if total == 0:
        return EMPTY_LATENCY

    def rounded(value: float | None) -> float | None:
        return round(value, LATENCY_DECIMALS) if value is not None else None

    return LatencySummary(
        avg_ms=rounded(sum(value * count for value, count in filled) / total),
        p50_ms=rounded(percentile(filled, 0.5)),
        p95_ms=rounded(percentile(filled, 0.95)),
        max_ms=rounded(max(value for value, _ in filled)),
    )
