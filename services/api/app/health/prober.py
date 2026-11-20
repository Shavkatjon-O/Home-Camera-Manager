"""Background task that probes every enabled camera and device, stores samples and tracks outages."""

import asyncio
import logging
import time
from collections.abc import Awaitable, Callable
from datetime import datetime, timedelta
from uuid import UUID

from sqlalchemy import delete, func, insert, select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.core.database import async_session_maker
from app.health.probe import ProbeOutcome, tcp_probe
from app.health.targets import Target, camera_address
from app.health.tracker import OutageRecord, OutageTracker
from app.models import Camera, CameraLink, HealthSample, NetworkDevice, Outage
from app.modules.health.enums import TargetKind

logger = logging.getLogger(__name__)

PROBE_CONCURRENCY = 32
ATTRIBUTION_INTERVALS = 2
RESTORE_INTERVALS = 3
PRUNE_SECONDS = 3600.0

Probe = Callable[[str, int], Awaitable[ProbeOutcome]]


def outage_record(outage: Outage) -> OutageRecord:
    """Copy a stored outage into a tracker record.

    Args:
        outage: Outage row.

    Returns:
        The matching in-memory record.
    """
    return OutageRecord(
        target_kind=outage.target_kind,
        target_uuid=outage.target_uuid,
        started_at=outage.started_at,
        failed_samples=outage.failed_samples,
        upstream_uuid=outage.upstream_uuid,
        ended_at=outage.ended_at,
        id=outage.id,
    )


def build_targets(devices: list[NetworkDevice], cameras: list[Camera], links: list[CameraLink]) -> list[Target]:
    """Build the list of targets to probe from the live registry rows.

    Args:
        devices: Enabled network devices.
        cameras: Enabled cameras.
        links: Camera links that give each camera's parent device.

    Returns:
        One target per device, then one per camera, each at the address camera_address picks.
    """
    parents = {link.camera_uuid: link.parent_uuid for link in links}
    targets = [
        Target(
            kind=TargetKind.DEVICE.value,
            uuid=device.uuid,
            host=device.host,
            port=device.probe_port,
            parent_uuid=device.parent_uuid,
        )
        for device in devices
    ]
    for camera in cameras:
        host, port = camera_address(camera.host, camera.device_host, camera.rtsp_port)
        targets.append(
            Target(
                kind=TargetKind.CAMERA.value,
                uuid=camera.uuid,
                host=host,
                port=port,
                parent_uuid=parents.get(camera.uuid),
            )
        )
    return targets


class HealthProber:
    """Probe all targets on a fixed interval and persist the results.

    Each round loads the enabled devices and cameras, probes them concurrently, stores one sample per target,
    updates outages and, about once an hour, deletes samples older than the retention period.

    Attributes:
        interval: Seconds between rounds.
        retention: How long samples are kept.
        probe: Coroutine function that probes one host and port.
        tracker: Outage tracker fed by every round.
        task: Running background task, or None when stopped.
        restored: True once tracker state has been rebuilt from the database.
        pruned_at: Monotonic time of the last prune, or None before the first.
    """

    def __init__(self, interval: float, retention_days: int, probe: Probe = tcp_probe):
        """Create a prober that is not yet running.

        Args:
            interval: Seconds between rounds.
            retention_days: Days to keep samples.
            probe: Coroutine function that probes one host and port.
        """
        self.interval = interval
        self.retention = timedelta(days=retention_days)
        self.probe = probe

        self.tracker = OutageTracker(slack=timedelta(seconds=interval * ATTRIBUTION_INTERVALS))
        self.task: asyncio.Task | None = None
        self.restored = False
        self.pruned_at: float | None = None

    async def start(self) -> None:
        """Start the background task unless it is already running."""
        if self.task is None or self.task.done():
            self.task = asyncio.create_task(self.run(), name="health-prober")

    async def stop(self) -> None:
        """Cancel the background task and wait for it to finish."""
        if self.task is not None:
            self.task.cancel()
            await asyncio.gather(self.task, return_exceptions=True)
            self.task = None

    async def run(self) -> None:
        """Run rounds forever, one per interval.

        A failing round is logged and does not stop the loop. A round that overruns the interval is followed at once by
        the next one, without trying to catch up on the missed rounds.
        """
        loop = asyncio.get_running_loop()
        next_at = loop.time()
        while True:
            try:
                await self.tick()
            except Exception:
                logger.exception("Health probing failed")
            next_at += self.interval
            delay = next_at - loop.time()
            if delay < 0:
                next_at = loop.time()
                delay = 0
            await asyncio.sleep(delay)

    async def tick(self) -> None:
        """Run one round: restore state on the first round, probe, save and prune when due."""
        if not self.restored:
            await self.restore()
            self.restored = True
        targets = await self.load()
        outcomes = await self.probe_all(targets)
        await self.save(targets, outcomes)
        await self.prune_when_due()

    async def load(self) -> list[Target]:
        """Load the targets to probe.

        Returns:
            Targets for the live, enabled devices and cameras.
        """
        async with async_session_maker() as session:
            devices = await session.scalars(
                select(NetworkDevice).where(NetworkDevice.deleted_at.is_(None), NetworkDevice.enabled.is_(True))
            )
            cameras = await session.scalars(
                select(Camera).where(
                    Camera.deleted_at.is_(None), Camera.enabled.is_(True), Camera.connector_id.is_(None)
                )
            )
            links = await session.scalars(select(CameraLink).where(CameraLink.deleted_at.is_(None)))
            return build_targets(list(devices), list(cameras), list(links))

    async def probe_all(self, targets: list[Target]) -> dict[UUID, ProbeOutcome]:
        """Probe all targets concurrently, at most 32 at a time.

        Args:
            targets: Targets to probe.

        Returns:
            The outcome of each probe keyed by target id.
        """
        semaphore = asyncio.Semaphore(PROBE_CONCURRENCY)

        async def limited(target: Target) -> tuple[UUID, ProbeOutcome]:
            """Probe one target once a concurrency slot is free.

            Args:
                target: Target to probe.

            Returns:
                The target id and its outcome.
            """
            async with semaphore:
                return target.uuid, await self.probe(target.host, target.port)

        return dict(await asyncio.gather(*(limited(target) for target in targets)))

    async def restore(self) -> None:
        """Rebuild tracker state from the database after a start.

        Open outages whose target has no sample in the last three intervals are closed, at the time of the
        target's last sample when that is after the outage started, otherwise now. The tracker then receives the
        open outages, the latest closed outage of each target and the targets whose latest recent sample failed.
        """
        async with async_session_maker() as session:
            now = await session.scalar(select(func.now()))
            open_rows = list(
                await session.scalars(select(Outage).where(Outage.deleted_at.is_(None), Outage.ended_at.is_(None)))
            )
            closed_rows = await session.scalars(
                select(Outage)
                .where(Outage.deleted_at.is_(None), Outage.ended_at.is_not(None))
                .order_by(Outage.target_uuid, Outage.started_at.desc())
                .distinct(Outage.target_uuid)
            )
            recent = now - timedelta(seconds=self.interval * RESTORE_INTERVALS)
            latest = await session.execute(
                select(HealthSample.target_uuid, HealthSample.ok, HealthSample.created_at)
                .where(HealthSample.created_at >= recent)
                .order_by(HealthSample.target_uuid, HealthSample.created_at.desc())
                .distinct(HealthSample.target_uuid)
            )
            failing = {row.target_uuid: row.created_at for row in latest.all() if not row.ok}
            for outage in open_rows:
                if outage.target_uuid in failing:
                    continue
                last_seen = await session.scalar(
                    select(func.max(HealthSample.created_at)).where(HealthSample.target_uuid == outage.target_uuid)
                )
                if last_seen is None or last_seen < recent:
                    outage.ended_at = last_seen if last_seen is not None and last_seen > outage.started_at else now
            await session.commit()
        records = [outage_record(outage) for outage in [*open_rows, *closed_rows]]
        self.tracker.restore(records, failing)
        logger.info("Health prober restored %d open outages", len(self.tracker.open))

    async def write_outages(self, session: AsyncSession) -> list[tuple[OutageRecord, Outage]]:
        """Write the tracker's changed outages to the session.

        Args:
            session: Database session to write in.

        Returns:
            Each new record paired with its new row, so the caller can copy the row ids back after the commit.
        """
        created = []
        for record in self.tracker.unsaved:
            if record.id is None:
                row = Outage(
                    target_kind=record.target_kind,
                    target_uuid=record.target_uuid,
                    started_at=record.started_at,
                    ended_at=record.ended_at,
                    failed_samples=record.failed_samples,
                    upstream_uuid=record.upstream_uuid,
                )
                session.add(row)
                created.append((record, row))
                continue
            await session.execute(
                update(Outage)
                .where(Outage.id == record.id)
                .values(
                    ended_at=record.ended_at,
                    failed_samples=record.failed_samples,
                    upstream_uuid=record.upstream_uuid,
                )
            )
        await session.flush()
        return created

    async def save(self, targets: list[Target], outcomes: dict[UUID, ProbeOutcome]) -> None:
        """Store a round's samples and outage changes in one transaction.

        Does nothing when there are no targets and no open outages.

        Args:
            targets: Targets that were probed.
            outcomes: Outcome of each probe keyed by target id.
        """
        if not targets and not self.tracker.open:
            return
        async with async_session_maker() as session:
            at: datetime = await session.scalar(select(func.now()))
            rows = [
                {
                    "target_kind": target.kind,
                    "target_uuid": target.uuid,
                    "ok": outcomes[target.uuid].ok,
                    "latency_ms": outcomes[target.uuid].latency_ms,
                    "error": outcomes[target.uuid].error,
                }
                for target in targets
                if target.uuid in outcomes
            ]
            if rows:
                await session.execute(insert(HealthSample), rows)
            self.tracker.observe(targets, {uuid: outcome.ok for uuid, outcome in outcomes.items()}, at)
            created = await self.write_outages(session)
            await session.commit()
        for record, row in created:
            record.id = row.id
        self.tracker.saved()

    async def prune_when_due(self) -> None:
        """Delete samples older than the retention period, at most once an hour."""
        now = time.monotonic()
        if self.pruned_at is not None and now - self.pruned_at < PRUNE_SECONDS:
            return
        self.pruned_at = now
        async with async_session_maker() as session:
            result = await session.execute(
                delete(HealthSample).where(HealthSample.created_at < func.now() - self.retention)
            )
            await session.commit()
        if result.rowcount:
            logger.info("Pruned %d health samples older than %d days", result.rowcount, self.retention.days)


health_prober = HealthProber(settings.health_interval_seconds, settings.health_retention_days)
