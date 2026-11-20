"""Retention of person appearances, journeys and line counts."""

import logging
from datetime import datetime, timedelta

from sqlalchemy import delete, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import InstrumentedAttribute

from app.models import AnalyticsAppearance, AnalyticsCount, AnalyticsJourney

__all__ = ["expired_rows", "purge_expired_counts", "purge_expired_journeys"]

logger = logging.getLogger(__name__)

PURGE_BATCH = 1000


def expired_rows(model: type, column: InstrumentedAttribute, cutoff: datetime, limit: int = PURGE_BATCH):
    """Build the statement that deletes one batch of rows older than a cutoff.

    Args:
        model: Mapped class of the table.
        column: Time column compared with the cutoff.
        cutoff: Rows whose time is before this are deleted.
        limit: Largest number of rows deleted by the statement.

    Returns:
        Delete statement of at most limit rows, oldest ids first.
    """
    batch = select(model.id).where(column < cutoff).order_by(model.id).limit(limit)
    return delete(model).where(model.id.in_(batch)).execution_options(synchronize_session=False)


async def purge_rows(session: AsyncSession, model: type, column: InstrumentedAttribute, cutoff: datetime) -> int:
    """Delete rows older than a cutoff in batches, committing each batch.

    Args:
        session: Database session to work in.
        model: Mapped class of the table.
        column: Time column compared with the cutoff.
        cutoff: Rows whose time is before this are deleted.

    Returns:
        Number of rows deleted.
    """
    total = 0
    while True:
        result = await session.execute(expired_rows(model, column, cutoff))
        await session.commit()
        deleted = result.rowcount or 0
        total += deleted
        if deleted < PURGE_BATCH:
            return total


async def purge_expired_journeys(session: AsyncSession, now: datetime, retention_days: int) -> tuple[int, int]:
    """Delete person appearances and journeys that started before the retention.

    Args:
        session: Database session to work in.
        now: Current time.
        retention_days: Days appearances and journeys are kept.

    Returns:
        Numbers of appearances and journeys deleted.
    """
    cutoff = now - timedelta(days=retention_days)
    appearances = await purge_rows(session, AnalyticsAppearance, AnalyticsAppearance.started_at, cutoff)
    journeys = await purge_rows(session, AnalyticsJourney, AnalyticsJourney.started_at, cutoff)
    if appearances or journeys:
        logger.info("Pruned %d appearances and %d journeys older than %d days", appearances, journeys, retention_days)
    return appearances, journeys


async def purge_expired_counts(session: AsyncSession, now: datetime, retention_days: int) -> int:
    """Delete line counts of minutes before the retention.

    Args:
        session: Database session to work in.
        now: Current time.
        retention_days: Days line counts are kept.

    Returns:
        Number of count rows deleted.
    """
    deleted = await purge_rows(session, AnalyticsCount, AnalyticsCount.start, now - timedelta(days=retention_days))
    if deleted:
        logger.info("Pruned %d line count rows older than %d days", deleted, retention_days)
    return deleted
