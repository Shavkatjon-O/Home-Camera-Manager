"""Time buckets, availability and latency statistics for probe samples."""

import math
from dataclasses import dataclass
from datetime import UTC, datetime, timedelta

PERCENT_DECIMALS = 2
LATENCY_DECIMALS = 1


@dataclass(frozen=True)
class Window:
    """Time span cut into equal buckets.

    Attributes:
        since: Start of the first bucket.
        until: End of the span.
        size: Bucket length in seconds.
        count: Number of buckets.
    """

    since: datetime
    until: datetime
    size: int
    count: int

    def start(self, index: int) -> datetime:
        """Return the start time of a bucket.

        Args:
            index: Zero-based bucket position.

        Returns:
            The bucket's start time.
        """
        return self.since + timedelta(seconds=index * self.size)

    def index(self, at: datetime) -> int | None:
        """Find the bucket a moment falls into.

        Args:
            at: Moment to place.

        Returns:
            The bucket position, or None when the moment is before the window or after its last bucket.
        """
        offset = (at - self.since).total_seconds()
        if offset < 0:
            return None
        position = int(offset // self.size)
        return position if position < self.count else None

    def refine(self, size: int) -> "Window":
        """Cut the same span into smaller buckets.

        Args:
            size: New bucket length in seconds.

        Returns:
            A window over the same span with the new bucket length.
        """
        return Window(since=self.since, until=self.until, size=size, count=self.count * self.size // size)


@dataclass(frozen=True)
class BucketCounts:
    """Sample totals of one bucket as read from the database.

    Attributes:
        samples: Number of samples in the bucket.
        ok: Number of successful samples.
        latency_ms: Average latency of the successful samples in milliseconds, or None when there is none.
    """

    samples: int
    ok: int
    latency_ms: float | None


@dataclass(frozen=True)
class Bucket:
    """One bucket of a target's history.

    Attributes:
        start: Start of the bucket.
        samples: Number of samples in the bucket.
        ok: Number of successful samples.
        availability: Percentage of successful samples, or None when the bucket has no samples.
        latency_ms: Average latency in milliseconds, or None when there is none.
    """

    start: datetime
    samples: int
    ok: int
    availability: float | None
    latency_ms: float | None


@dataclass(frozen=True)
class LatencySummary:
    """Latency statistics over a period.

    Attributes:
        avg_ms: Mean latency in milliseconds.
        p50_ms: Median latency in milliseconds.
        p95_ms: 95th percentile latency in milliseconds.
        max_ms: Highest latency in milliseconds.
    """

    avg_ms: float | None
    p50_ms: float | None
    p95_ms: float | None
    max_ms: float | None


EMPTY_LATENCY = LatencySummary(avg_ms=None, p50_ms=None, p95_ms=None, max_ms=None)


def bucket_window(until: datetime, span_seconds: int, size: int) -> Window:
    """Build a window of whole buckets that ends with the bucket containing a moment.

    Bucket edges are aligned to multiples of the bucket length since the Unix epoch.

    Args:
        until: End of the span.
        span_seconds: Length of the span in seconds.
        size: Bucket length in seconds.

    Returns:
        The window, with at least one bucket.
    """
    count = max(1, span_seconds // size)
    epoch = math.floor(until.timestamp())
    last = epoch - epoch % size
    since = datetime.fromtimestamp(last - (count - 1) * size, UTC)
    return Window(since=since, until=until, size=size, count=count)


def availability(samples: int, ok: int) -> float | None:
    """Compute the percentage of samples that succeeded.

    Args:
        samples: Number of samples.
        ok: Number of successful samples.

    Returns:
        The percentage rounded to two decimals, or None when there are no samples.
    """
    if samples <= 0:
        return None
    return round(ok * 100 / samples, PERCENT_DECIMALS)


def fill_buckets(window: Window, counts: dict[datetime, BucketCounts]) -> list[Bucket]:
    """Produce one bucket for every position in a window, empty where nothing was sampled.

    Args:
        window: Window to fill.
        counts: Sample totals keyed by bucket start time. Entries outside the window are ignored.

    Returns:
        The buckets in time order.
    """
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
    """Return the value at a rank of a histogram laid out as a sorted list of samples.

    Args:
        histogram: Pairs of value and sample count, sorted by value.
        rank: Zero-based position among all samples.

    Returns:
        The value holding that rank, or the highest value when the rank is past the end.
    """
    seen = 0
    for value, count in histogram:
        seen += count
        if rank < seen:
            return value
    return histogram[-1][0]


def percentile(histogram: list[tuple[float, int]], fraction: float) -> float | None:
    """Compute a percentile of a histogram, interpolating between neighbouring ranks.

    Args:
        histogram: Pairs of value and sample count.
        fraction: Position between 0 and 1, such as 0.95.

    Returns:
        The interpolated value, or None when the histogram holds no samples.
    """
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
    """Summarize latency from a histogram.

    Args:
        histogram: Pairs of latency in milliseconds and sample count.

    Returns:
        Average, median, 95th percentile and maximum rounded to one decimal, or empty statistics when there are
        no samples.
    """
    filled = [(value, count) for value, count in histogram if count > 0]
    total = sum(count for _, count in filled)
    if total == 0:
        return EMPTY_LATENCY

    def rounded(value: float | None) -> float | None:
        """Round a latency to one decimal.

        Args:
            value: Latency in milliseconds, if any.

        Returns:
            The rounded value, or None when there is no value.
        """
        return round(value, LATENCY_DECIMALS) if value is not None else None

    return LatencySummary(
        avg_ms=rounded(sum(value * count for value, count in filled) / total),
        p50_ms=rounded(percentile(filled, 0.5)),
        p95_ms=rounded(percentile(filled, 0.95)),
        max_ms=rounded(max(value for value, _ in filled)),
    )
