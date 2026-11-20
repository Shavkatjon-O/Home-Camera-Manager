"""Health overview schemas."""

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel

from app.modules.operations.enums import DeviceKind, HealthRange, LinkKind, TargetKind, TargetStatus

__all__ = ["HealthBucket", "HealthOverview", "LatencyStats", "OutageBrief", "TargetDetail", "TargetHealth"]


class LatencyStats(BaseModel):
    """Latency statistics of successful probes.

    Attributes:
        avg_ms: Mean in milliseconds.
        p50_ms: Median in milliseconds.
        p95_ms: 95th percentile in milliseconds.
        max_ms: Highest value in milliseconds.
    """

    avg_ms: float | None
    p50_ms: float | None
    p95_ms: float | None
    max_ms: float | None


class HealthBucket(BaseModel):
    """One time bucket of a target's history.

    Attributes:
        start: Start of the bucket.
        samples: Number of samples in the bucket.
        availability: Percentage of successful samples, or None when the bucket has none.
        latency_ms: Average latency of successful samples in milliseconds, or None.
    """

    start: datetime
    samples: int
    availability: float | None
    latency_ms: float | None


class OutageBrief(BaseModel):
    """Short description of an outage.

    Attributes:
        uuid: Public id.
        started_at: Time of the first failed sample.
        ended_at: Time the target answered again, or None while the outage continues.
        duration_seconds: Length of the outage so far, or in total once it has ended.
        upstream_uuid: Public id of the device whose outage caused this one, if any.
        upstream_name: Name of that device.
    """

    uuid: UUID
    started_at: datetime
    ended_at: datetime | None
    duration_seconds: float
    upstream_uuid: UUID | None
    upstream_name: str | None


class TargetHealth(BaseModel):
    """Health of one device or camera over the requested range.

    Attributes:
        uuid: Public id of the target.
        kind: Whether the target is a device or a camera.
        device_kind: Device kind, or None for a camera.
        name: Display name.
        host: Address that is probed.
        port: TCP port that is probed.
        parent_uuid: Public id of the device the target connects through, if any.
        parent_name: Name of that device.
        link: How the target connects to the parent.
        notes: Notes of a device, always None for a camera.
        enabled: Whether the target is probed.
        status: Current state.
        last_sample_at: Time of the latest recent sample, if any.
        last_error: Reason the latest sample failed, when it did.
        samples: Number of samples in the range.
        uptime_percent: Percentage of successful samples, or None when there are none.
        latency: Latency statistics for the range.
        outage_count: Number of outages that overlap the range.
        last_outage: Most recent outage, if any.
        buckets: Availability and latency per time bucket.
    """

    uuid: UUID
    kind: TargetKind
    device_kind: DeviceKind | None
    name: str
    host: str
    port: int

    parent_uuid: UUID | None
    parent_name: str | None
    link: LinkKind | None
    notes: str | None
    enabled: bool

    status: TargetStatus
    last_sample_at: datetime | None
    last_error: str | None

    samples: int
    uptime_percent: float | None
    latency: LatencyStats

    outage_count: int
    last_outage: OutageBrief | None

    buckets: list[HealthBucket]


class HealthOverview(BaseModel):
    """Health of every target over a range.

    Attributes:
        range: Range covered.
        since: Start of the range.
        until: End of the range.
        bucket_seconds: Bucket length in seconds.
        interval_seconds: Seconds between probe rounds.
        targets: Health of each target.
    """

    range: HealthRange
    since: datetime
    until: datetime
    bucket_seconds: int
    interval_seconds: int
    targets: list[TargetHealth]


class TargetDetail(BaseModel):
    """Health of one target over a range, with finer buckets than the overview.

    Attributes:
        range: Range covered.
        since: Start of the range.
        until: End of the range.
        bucket_seconds: Bucket length in seconds.
        interval_seconds: Seconds between probe rounds.
        target: Health of the target.
    """

    range: HealthRange
    since: datetime
    until: datetime
    bucket_seconds: int
    interval_seconds: int
    target: TargetHealth
