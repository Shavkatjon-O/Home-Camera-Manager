"""Usage metering: hourly rollups per organisation and site, for billing later."""

import asyncio
import logging
from collections import defaultdict
from datetime import UTC, datetime, timedelta
from pathlib import Path

from sqlalchemy import case, func, select
from sqlalchemy.dialects.postgresql import insert
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.core.database import UNSCOPED_OPTION, async_session_maker
from app.models import AnalyticsView, Camera, Connector, Event, HealthSample, UsageRollup
from app.modules.billing.enums import UsageMetric

__all__ = ["UsageMeter", "hour_start", "measure_hour", "record_usage", "usage_meter"]

logger = logging.getLogger(__name__)

UNSCOPED = {UNSCOPED_OPTION: True}
TICK_SECONDS = 300
GAUGES = (UsageMetric.CAMERA_HOURS, UsageMetric.VIEW_HOURS, UsageMetric.EVENTS, UsageMetric.CLIP_BYTES)


def hour_start(at: datetime) -> datetime:
    """Return the start of the hour a time falls in.

    Args:
        at: The time.

    Returns:
        The hour's start in UTC.
    """
    return at.astimezone(UTC).replace(minute=0, second=0, microsecond=0)


def rollup_statement(rows: list[dict], add: bool):
    """Build the upsert of rollup rows.

    Args:
        rows: Rows with organisation_id, site_id, hour, metric and value.
        add: Whether to add to a stored value rather than replace it.

    Returns:
        The insert statement.
    """
    statement = insert(UsageRollup).values(rows)
    value = UsageRollup.value + statement.excluded.value if add else statement.excluded.value
    return statement.on_conflict_do_update(
        constraint="uq_usage_rollup", set_={"value": value, "updated_at": func.now()}
    )


async def record_usage(
    session: AsyncSession,
    organisation_id: int | None,
    site_id: int | None,
    metric: UsageMetric,
    amount: float = 1.0,
    at: datetime | None = None,
) -> None:
    """Add to a counted metric, such as a notification sent, in the hour it happened.

    Args:
        session: Database session; the caller commits.
        organisation_id: The organisation; nothing is recorded without one.
        site_id: The site, None for usage of the organisation as a whole.
        metric: The metric.
        amount: How much to add.
        at: When it happened, now when omitted.
    """
    if organisation_id is None:
        return
    row = {
        "organisation_id": organisation_id,
        "site_id": site_id,
        "hour": hour_start(at or datetime.now(UTC)),
        "metric": metric.value,
        "value": float(amount),
    }
    await session.execute(rollup_statement([row], add=True))


def clip_size(relative: str) -> int:
    """Return the size of a stored clip.

    Args:
        relative: Path relative to the event store.

    Returns:
        Bytes, 0 when the file is missing.
    """
    try:
        return (Path(settings.events_dir) / relative).stat().st_size
    except OSError:
        return 0


async def measure_hour(session: AsyncSession, start: datetime) -> list[dict]:
    """Measure the gauge metrics of one hour for every site.

    Cameras the backend probes count the share of their health samples that answered; cameras behind a
    connector count as online when their connector reported during or after the hour. Every enabled analytics
    view counts the whole hour.

    Args:
        session: Database session without a scope.
        start: Start of the hour.

    Returns:
        Rollup rows with organisation_id, site_id, hour, metric and value.
    """
    end = start + timedelta(hours=1)
    values: dict[tuple[int, int, str], float] = defaultdict(float)
    cameras = (
        await session.execute(
            select(Camera.uuid, Camera.site_id, Camera.organisation_id, Connector.last_seen_at)
            .outerjoin(Connector, Connector.id == Camera.connector_id)
            .where(Camera.deleted_at.is_(None), Camera.enabled.is_(True), Camera.site_id.is_not(None))
            .execution_options(**UNSCOPED)
        )
    ).all()
    samples = dict(
        (
            await session.execute(
                select(HealthSample.target_uuid, func.avg(case((HealthSample.ok, 1.0), else_=0.0)))
                .where(HealthSample.created_at >= start, HealthSample.created_at < end)
                .group_by(HealthSample.target_uuid)
                .execution_options(**UNSCOPED)
            )
        ).all()
    )
    for uuid, site_id, organisation_id, last_seen in cameras:
        key = (organisation_id, site_id, UsageMetric.CAMERA_HOURS.value)
        if uuid in samples:
            values[key] += float(samples[uuid] or 0)
        elif last_seen is not None and last_seen >= start:
            values[key] += 1.0
        else:
            values[key] += 0.0
    views = (
        await session.execute(
            select(AnalyticsView.organisation_id, AnalyticsView.site_id, func.count())
            .where(
                AnalyticsView.enabled.is_(True), AnalyticsView.deleted_at.is_(None), AnalyticsView.site_id.is_not(None)
            )
            .group_by(AnalyticsView.organisation_id, AnalyticsView.site_id)
            .execution_options(**UNSCOPED)
        )
    ).all()
    for organisation_id, site_id, count in views:
        values[(organisation_id, site_id, UsageMetric.VIEW_HOURS.value)] += float(count)
    events = (
        await session.execute(
            select(Event.organisation_id, Event.site_id, Event.clip_path)
            .where(Event.started_at >= start, Event.started_at < end, Event.site_id.is_not(None))
            .execution_options(**UNSCOPED)
        )
    ).all()
    for organisation_id, site_id, clip in events:
        values[(organisation_id, site_id, UsageMetric.EVENTS.value)] += 1.0
        if clip:
            values[(organisation_id, site_id, UsageMetric.CLIP_BYTES.value)] += float(clip_size(clip))
    return [
        {"organisation_id": organisation_id, "site_id": site_id, "hour": start, "metric": metric, "value": value}
        for (organisation_id, site_id, metric), value in values.items()
        if organisation_id is not None
    ]


class UsageMeter:
    """Rolls up the previous hour's gauge metrics every few minutes, replacing what an earlier run stored.

    Attributes:
        task: The running loop, if any.
    """

    def __init__(self):
        """Create the meter, not yet running."""
        self.task: asyncio.Task | None = None

    async def start(self) -> None:
        """Start the loop."""
        if self.task is None or self.task.done():
            self.task = asyncio.create_task(self.run(), name="usage-meter")

    async def stop(self) -> None:
        """Stop the loop."""
        if self.task is not None:
            self.task.cancel()
            await asyncio.gather(self.task, return_exceptions=True)
            self.task = None

    async def roll(self, start: datetime) -> int:
        """Store one hour's gauge metrics.

        Args:
            start: Start of the hour.

        Returns:
            The number of rows stored.
        """
        async with async_session_maker() as session:
            rows = await measure_hour(session, start)
            if rows:
                await session.execute(rollup_statement(rows, add=False))
            await session.commit()
            return len(rows)

    async def run(self) -> None:
        """Roll up the previous and the current hour until cancelled, surviving failures."""
        while True:
            now = datetime.now(UTC)
            for start in (hour_start(now) - timedelta(hours=1), hour_start(now)):
                try:
                    await self.roll(start)
                except Exception:
                    logger.exception("Rolling up the usage of %s failed", start.isoformat())
            await asyncio.sleep(TICK_SECONDS)


usage_meter = UsageMeter()
