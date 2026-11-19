from datetime import datetime
from uuid import UUID

from pydantic import BaseModel

from app.modules.health.enums import DeviceKind, HealthRange, LinkKind, TargetKind, TargetStatus

__all__ = ["HealthBucket", "HealthOverview", "LatencyStats", "OutageBrief", "TargetDetail", "TargetHealth"]


class LatencyStats(BaseModel):
    avg_ms: float | None
    p50_ms: float | None
    p95_ms: float | None
    max_ms: float | None


class HealthBucket(BaseModel):
    start: datetime
    samples: int
    availability: float | None
    latency_ms: float | None


class OutageBrief(BaseModel):
    uuid: UUID
    started_at: datetime
    ended_at: datetime | None
    duration_seconds: float
    upstream_uuid: UUID | None
    upstream_name: str | None


class TargetHealth(BaseModel):
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
    range: HealthRange
    since: datetime
    until: datetime
    bucket_seconds: int
    interval_seconds: int
    targets: list[TargetHealth]


class TargetDetail(BaseModel):
    range: HealthRange
    since: datetime
    until: datetime
    bucket_seconds: int
    interval_seconds: int
    target: TargetHealth
