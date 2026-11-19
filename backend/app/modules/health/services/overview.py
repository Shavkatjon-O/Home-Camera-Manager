from dataclasses import dataclass
from datetime import datetime, timedelta
from uuid import UUID

from sqlalchemy import func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.core.config import settings
from app.core.exceptions import NotFound
from app.health.stats import BucketCounts, Window, availability, bucket_window, fill_buckets, latency_summary
from app.health.targets import Target, camera_address, depth_order
from app.models import Camera, CameraLink, HealthSample, NetworkDevice, Outage
from app.modules.health.enums import DeviceKind, HealthRange, LinkKind, TargetKind, TargetStatus
from app.modules.health.schemas import (
    HealthBucket,
    HealthOverview,
    LatencyStats,
    OutageBrief,
    TargetDetail,
    TargetHealth,
)

__all__ = [
    "BUCKET_SECONDS",
    "FINE_BUCKET_SECONDS",
    "RANGE_SECONDS",
    "HealthOverviewService",
    "Latest",
    "TargetInfo",
    "duration_seconds",
    "target_status",
]

RANGE_SECONDS = {HealthRange.HOUR: 3600, HealthRange.DAY: 86400, HealthRange.WEEK: 604800}
BUCKET_SECONDS = {HealthRange.HOUR: 60, HealthRange.DAY: 900, HealthRange.WEEK: 7200}
FINE_BUCKET_SECONDS = {HealthRange.HOUR: 30, HealthRange.DAY: 300, HealthRange.WEEK: 1800}

STALE_INTERVALS = 3
LATEST_INTERVALS = 6


@dataclass(frozen=True)
class TargetInfo:
    uuid: UUID
    kind: TargetKind
    device_kind: DeviceKind | None
    name: str
    host: str
    port: int
    parent_uuid: UUID | None
    link: LinkKind | None
    notes: str | None
    enabled: bool


@dataclass(frozen=True)
class Latest:
    ok: bool
    at: datetime
    error: str | None


def target_status(enabled: bool, ongoing: bool, latest: Latest | None, until: datetime, interval: int) -> TargetStatus:
    if not enabled:
        return TargetStatus.DISABLED
    if ongoing:
        return TargetStatus.DOWN
    if latest is None or until - latest.at > timedelta(seconds=interval * STALE_INTERVALS):
        return TargetStatus.UNKNOWN
    return TargetStatus.UP if latest.ok else TargetStatus.DEGRADED


def duration_seconds(started_at: datetime, ended_at: datetime | None, until: datetime) -> float:
    return round(max(0.0, ((ended_at or until) - started_at).total_seconds()), 1)


class HealthOverviewService:
    def __init__(
        self,
        session: AsyncSession,
        actor: UserContext | None = None,
        interval: int = settings.health_interval_seconds,
    ):
        self.session = session
        self.actor = actor
        self.interval = interval

    async def now(self) -> datetime:
        return await self.session.scalar(select(func.now()))

    async def target_infos(self) -> tuple[list[TargetInfo], dict[UUID, str]]:
        devices = list(await self.session.scalars(select(NetworkDevice)))
        cameras = (
            await self.session.execute(
                select(
                    Camera.uuid,
                    Camera.name,
                    Camera.host,
                    Camera.device_host,
                    Camera.rtsp_port,
                    Camera.enabled,
                    Camera.deleted_at,
                ).order_by(Camera.position.asc(), Camera.created_at.desc(), Camera.id.desc())
            )
        ).all()
        links = {
            link.camera_uuid: link
            for link in await self.session.scalars(select(CameraLink).where(CameraLink.deleted_at.is_(None)))
        }
        names = {device.uuid: device.name for device in devices}
        names.update({camera.uuid: camera.name for camera in cameras})
        live = [device for device in devices if device.deleted_at is None]
        by_uuid = {device.uuid: device for device in live}
        ordered = depth_order(
            [
                Target(kind=TargetKind.DEVICE.value, uuid=device.uuid, host="", port=0, parent_uuid=device.parent_uuid)
                for device in sorted(live, key=lambda item: (item.name.lower(), item.created_at))
            ]
        )
        infos = []
        for entry in ordered:
            device = by_uuid[entry.uuid]
            infos.append(
                TargetInfo(
                    uuid=device.uuid,
                    kind=TargetKind.DEVICE,
                    device_kind=DeviceKind(device.kind),
                    name=device.name,
                    host=device.host,
                    port=device.probe_port,
                    parent_uuid=device.parent_uuid,
                    link=LinkKind(device.link) if device.link else None,
                    notes=device.notes,
                    enabled=device.enabled,
                )
            )
        for camera in cameras:
            if camera.deleted_at is not None:
                continue
            host, port = camera_address(camera.host, camera.device_host, camera.rtsp_port)
            link = links.get(camera.uuid)
            infos.append(
                TargetInfo(
                    uuid=camera.uuid,
                    kind=TargetKind.CAMERA,
                    device_kind=None,
                    name=camera.name,
                    host=host,
                    port=port,
                    parent_uuid=link.parent_uuid if link else None,
                    link=LinkKind(link.link) if link else None,
                    notes=None,
                    enabled=camera.enabled,
                )
            )
        return infos, names

    async def bucket_counts(self, uuids: list[UUID], window: Window) -> dict[UUID, dict[datetime, BucketCounts]]:
        bucket = func.date_bin(timedelta(seconds=window.size), HealthSample.created_at, window.since).label("bucket")
        rows = await self.session.execute(
            select(
                HealthSample.target_uuid,
                bucket,
                func.count().label("samples"),
                func.count().filter(HealthSample.ok.is_(True)).label("ok"),
                func.avg(HealthSample.latency_ms).filter(HealthSample.ok.is_(True)).label("latency"),
            )
            .where(HealthSample.target_uuid.in_(uuids), HealthSample.created_at >= window.since)
            .group_by(HealthSample.target_uuid, bucket)
        )
        counts: dict[UUID, dict[datetime, BucketCounts]] = {}
        for row in rows.all():
            latency = float(row.latency) if row.latency is not None else None
            counts.setdefault(row.target_uuid, {})[row.bucket] = BucketCounts(
                samples=row.samples, ok=row.ok, latency_ms=latency
            )
        return counts

    async def histograms(self, uuids: list[UUID], since: datetime) -> dict[UUID, list[tuple[float, int]]]:
        rows = await self.session.execute(
            select(HealthSample.target_uuid, HealthSample.latency_ms, func.count().label("samples"))
            .where(
                HealthSample.target_uuid.in_(uuids),
                HealthSample.created_at >= since,
                HealthSample.ok.is_(True),
                HealthSample.latency_ms.is_not(None),
            )
            .group_by(HealthSample.target_uuid, HealthSample.latency_ms)
        )
        histograms: dict[UUID, list[tuple[float, int]]] = {}
        for row in rows.all():
            histograms.setdefault(row.target_uuid, []).append((row.latency_ms, row.samples))
        return histograms

    async def latest(self, uuids: list[UUID], until: datetime) -> dict[UUID, Latest]:
        rows = await self.session.execute(
            select(HealthSample.target_uuid, HealthSample.ok, HealthSample.created_at, HealthSample.error)
            .where(
                HealthSample.target_uuid.in_(uuids),
                HealthSample.created_at >= until - timedelta(seconds=self.interval * LATEST_INTERVALS),
            )
            .order_by(HealthSample.target_uuid, HealthSample.created_at.desc())
            .distinct(HealthSample.target_uuid)
        )
        return {row.target_uuid: Latest(ok=row.ok, at=row.created_at, error=row.error) for row in rows.all()}

    async def outage_counts(self, uuids: list[UUID], window: Window) -> dict[UUID, int]:
        rows = await self.session.execute(
            select(Outage.target_uuid, func.count().label("outages"))
            .where(
                Outage.target_uuid.in_(uuids),
                Outage.deleted_at.is_(None),
                Outage.started_at < window.until,
                or_(Outage.ended_at.is_(None), Outage.ended_at >= window.since),
            )
            .group_by(Outage.target_uuid)
        )
        return {row.target_uuid: row.outages for row in rows.all()}

    async def last_outages(self, uuids: list[UUID]) -> dict[UUID, Outage]:
        rows = await self.session.scalars(
            select(Outage)
            .where(Outage.target_uuid.in_(uuids), Outage.deleted_at.is_(None))
            .order_by(Outage.target_uuid, Outage.started_at.desc())
            .distinct(Outage.target_uuid)
        )
        return {outage.target_uuid: outage for outage in rows}

    def brief(self, outage: Outage, until: datetime, names: dict[UUID, str]) -> OutageBrief:
        return OutageBrief(
            uuid=outage.uuid,
            started_at=outage.started_at,
            ended_at=outage.ended_at,
            duration_seconds=duration_seconds(outage.started_at, outage.ended_at, until),
            upstream_uuid=outage.upstream_uuid,
            upstream_name=names.get(outage.upstream_uuid) if outage.upstream_uuid else None,
        )

    async def measure(
        self, infos: list[TargetInfo], names: dict[UUID, str], window: Window, buckets: Window
    ) -> list[TargetHealth]:
        uuids = [info.uuid for info in infos]
        if not uuids:
            return []
        counts = await self.bucket_counts(uuids, buckets)
        histograms = await self.histograms(uuids, window.since)
        latest = await self.latest(uuids, window.until)
        outage_counts = await self.outage_counts(uuids, window)
        last_outages = await self.last_outages(uuids)
        results = []
        for info in infos:
            filled = fill_buckets(buckets, counts.get(info.uuid, {}))
            samples = sum(bucket.samples for bucket in filled)
            ok = sum(bucket.ok for bucket in filled)
            summary = latency_summary(histograms.get(info.uuid, []))
            last_outage = last_outages.get(info.uuid)
            current = latest.get(info.uuid)
            ongoing = last_outage is not None and last_outage.ended_at is None
            results.append(
                TargetHealth(
                    uuid=info.uuid,
                    kind=info.kind,
                    device_kind=info.device_kind,
                    name=info.name,
                    host=info.host,
                    port=info.port,
                    parent_uuid=info.parent_uuid,
                    parent_name=names.get(info.parent_uuid) if info.parent_uuid else None,
                    link=info.link,
                    notes=info.notes,
                    enabled=info.enabled,
                    status=target_status(info.enabled, ongoing, current, window.until, self.interval),
                    last_sample_at=current.at if current else None,
                    last_error=current.error if current and not current.ok else None,
                    samples=samples,
                    uptime_percent=availability(samples, ok),
                    latency=LatencyStats(
                        avg_ms=summary.avg_ms, p50_ms=summary.p50_ms, p95_ms=summary.p95_ms, max_ms=summary.max_ms
                    ),
                    outage_count=outage_counts.get(info.uuid, 0),
                    last_outage=self.brief(last_outage, window.until, names) if last_outage else None,
                    buckets=[
                        HealthBucket(
                            start=bucket.start,
                            samples=bucket.samples,
                            availability=bucket.availability,
                            latency_ms=bucket.latency_ms,
                        )
                        for bucket in filled
                    ],
                )
            )
        return results

    async def window(self, health_range: HealthRange) -> Window:
        return bucket_window(await self.now(), RANGE_SECONDS[health_range], BUCKET_SECONDS[health_range])

    async def overview(self, health_range: HealthRange) -> HealthOverview:
        window = await self.window(health_range)
        infos, names = await self.target_infos()
        targets = await self.measure(infos, names, window, window)
        return HealthOverview(
            range=health_range,
            since=window.since,
            until=window.until,
            bucket_seconds=window.size,
            interval_seconds=self.interval,
            targets=targets,
        )

    async def target(self, uuid: UUID, health_range: HealthRange) -> TargetDetail:
        window = await self.window(health_range)
        infos, names = await self.target_infos()
        info = next((item for item in infos if item.uuid == uuid), None)
        if info is None:
            raise NotFound("health_target_not_found", f"No device or camera {uuid} exists")
        fine = window.refine(FINE_BUCKET_SECONDS[health_range])
        targets = await self.measure([info], names, window, fine)
        return TargetDetail(
            range=health_range,
            since=window.since,
            until=window.until,
            bucket_seconds=fine.size,
            interval_seconds=self.interval,
            target=targets[0],
        )
