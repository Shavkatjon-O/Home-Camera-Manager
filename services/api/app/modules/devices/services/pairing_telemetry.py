"""Pairing telemetry: attempts per method, adapter and step, and the success of each method."""

from datetime import UTC, datetime, timedelta
from uuid import UUID

from sqlalchemy import case, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import PairingAttempt
from app.modules.devices.schemas.pairing import (
    AttemptOutcome,
    MethodStats,
    PairingAttemptCreate,
    PairingAttemptRead,
    PairingMethodId,
    PairingStats,
    StatCount,
)

__all__ = ["FINISHED", "PairingTelemetryService"]

FINISHED = (AttemptOutcome.SUCCEEDED.value, AttemptOutcome.FAILED.value, AttemptOutcome.ABANDONED.value)
TOP = 5


def attempt_read(attempt: PairingAttempt) -> PairingAttemptRead:
    """Build the API view of an attempt.

    Args:
        attempt: The attempt.

    Returns:
        The attempt.
    """
    return PairingAttemptRead(
        uuid=attempt.uuid,
        method=PairingMethodId(attempt.method),
        adapter=attempt.adapter,
        last_step=attempt.last_step,
        outcome=AttemptOutcome(attempt.outcome),
        error_code=attempt.error_code,
        duration_ms=attempt.duration_ms,
        created_at=attempt.created_at,
    )


class PairingTelemetryService:
    """Records pairing attempts of an organisation and sums them up.

    Attributes:
        session: Database session limited to the request's site and organisation.
        site_id: Database id of the request's site.
    """

    def __init__(self, session: AsyncSession, site_id: int | None = None):
        """Bind the service to a scoped session.

        Args:
            session: Database session limited to the request's site and organisation.
            site_id: Database id of the request's site.
        """
        self.session = session
        self.site_id = site_id

    async def start(self, method: PairingMethodId, adapter: str | None = None, step: str = "start") -> PairingAttempt:
        """Open an attempt.

        Args:
            method: Pairing method.
            adapter: Adapter, if known.
            step: First step.

        Returns:
            The attempt, flushed; the caller commits.
        """
        attempt = PairingAttempt(
            site_id=self.site_id,
            method=method.value,
            adapter=adapter,
            last_step=step,
            outcome=AttemptOutcome.STARTED.value,
            duration_ms=0,
        )
        self.session.add(attempt)
        await self.session.flush()
        return attempt

    async def find(self, uuid: UUID | None) -> PairingAttempt | None:
        """Load an open attempt of the organisation.

        Args:
            uuid: Public id, if any.

        Returns:
            The attempt, or None.
        """
        if uuid is None:
            return None
        return await self.session.scalar(select(PairingAttempt).where(PairingAttempt.uuid == uuid))

    def finish(
        self,
        attempt: PairingAttempt,
        outcome: AttemptOutcome,
        step: str,
        adapter: str | None = None,
        error_code: str | None = None,
    ) -> None:
        """Close an attempt with its outcome.

        Args:
            attempt: The attempt.
            outcome: Its outcome.
            step: Last step reached.
            adapter: Adapter involved, if known now.
            error_code: Stable error code of a failure.
        """
        now = datetime.now(UTC)
        started = attempt.created_at or now
        attempt.outcome = outcome.value
        attempt.last_step = step
        attempt.adapter = adapter or attempt.adapter
        attempt.error_code = error_code
        attempt.finished_at = now
        attempt.duration_ms = max(0, int((now - started).total_seconds() * 1000))

    async def report(self, payload: PairingAttemptCreate) -> PairingAttemptRead:
        """Record an attempt the app reports itself.

        Args:
            payload: The attempt.

        Returns:
            The recorded attempt.
        """
        now = datetime.now(UTC)
        attempt = PairingAttempt(
            site_id=self.site_id,
            method=payload.method.value,
            adapter=payload.adapter,
            last_step=payload.last_step,
            outcome=payload.outcome.value,
            error_code=payload.error_code,
            duration_ms=payload.duration_ms,
            finished_at=now if payload.outcome != AttemptOutcome.STARTED else None,
        )
        self.session.add(attempt)
        await self.session.commit()
        await self.session.refresh(attempt)
        return attempt_read(attempt)

    async def stats(self, days: int, unscoped: bool = False) -> PairingStats:
        """Sum up the finished attempts of a period per method.

        Args:
            days: Length of the period in days.
            unscoped: Whether the session sees every organisation, for platform admins.

        Returns:
            The stats.
        """
        since = datetime.now(UTC) - timedelta(days=days)
        window = (PairingAttempt.created_at >= since, PairingAttempt.outcome.in_(FINISHED))
        rows = (
            await self.session.execute(
                select(
                    PairingAttempt.method,
                    func.count(),
                    func.sum(case((PairingAttempt.outcome == AttemptOutcome.SUCCEEDED.value, 1), else_=0)),
                    func.sum(case((PairingAttempt.outcome == AttemptOutcome.FAILED.value, 1), else_=0)),
                    func.sum(case((PairingAttempt.outcome == AttemptOutcome.ABANDONED.value, 1), else_=0)),
                    func.percentile_cont(0.5).within_group(PairingAttempt.duration_ms),
                )
                .where(*window)
                .group_by(PairingAttempt.method)
            )
        ).all()
        errors = await self.counts(PairingAttempt.error_code, window)
        steps = await self.counts(
            PairingAttempt.last_step, (*window, PairingAttempt.outcome != AttemptOutcome.SUCCEEDED.value)
        )
        methods = [
            MethodStats(
                method=PairingMethodId(method),
                attempts=total,
                succeeded=succeeded or 0,
                failed=failed or 0,
                abandoned=abandoned or 0,
                success_rate=round((succeeded or 0) / total, 4) if total else 0.0,
                median_duration_ms=int(median) if median is not None else None,
                errors=errors.get(method, []),
                stopped_at=steps.get(method, []),
            )
            for method, total, succeeded, failed, abandoned, median in rows
            if method in PairingMethodId.__members__.values()
        ]
        return PairingStats(since=since, methods=sorted(methods, key=lambda item: -item.attempts))

    async def counts(self, column, conditions: tuple) -> dict[str, list[StatCount]]:
        """Count the values of a column per method, most frequent first.

        Args:
            column: The column, such as the error code.
            conditions: Filters of the period.

        Returns:
            Method to its most frequent values.
        """
        rows = (
            await self.session.execute(
                select(PairingAttempt.method, column, func.count())
                .where(*conditions, column.is_not(None))
                .group_by(PairingAttempt.method, column)
                .order_by(func.count().desc())
            )
        ).all()
        result: dict[str, list[StatCount]] = {}
        for method, value, count in rows:
            items = result.setdefault(method, [])
            if len(items) < TOP:
                items.append(StatCount(value=value, count=count))
        return result
