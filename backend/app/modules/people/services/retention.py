"""Retention of face samples seen by the cameras."""

import logging
from datetime import datetime, timedelta

from sqlalchemy import delete, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.models import Event
from app.modules.people.crops import CropStore
from app.modules.people.embeddings import mean_embedding
from app.modules.people.enums import FACE_KINDS, SampleSource
from app.modules.people.models import FaceSample, UnknownCluster

from .shared import BULK, lock_faces, strip_event_crops

__all__ = ["expired_samples", "purge_expired_samples"]

logger = logging.getLogger(__name__)

PURGE_BATCH = 500


def expired_samples(cutoff: datetime, limit: int = PURGE_BATCH):
    """Build the query for camera samples seen before a cutoff.

    Uploaded samples are never selected; they stay until a user deletes them.

    Args:
        cutoff: Samples seen before this time are expired.
        limit: Largest number of samples to select.

    Returns:
        Select statement of sample id, crop path, event id and cluster id.
    """
    return (
        select(FaceSample.id, FaceSample.crop_path, FaceSample.event_uuid, FaceSample.cluster_id)
        .where(FaceSample.source == SampleSource.EVENT.value, FaceSample.seen_at < cutoff)
        .order_by(FaceSample.id)
        .limit(limit)
    )


async def refresh_clusters(session: AsyncSession, cluster_ids: set[int], now: datetime) -> None:
    """Recompute the centroids of clusters that lost samples and soft-delete those left without any.

    Args:
        session: Database session.
        cluster_ids: Database ids of the clusters.
        now: Time recorded as the deletion time.
    """
    clusters = list(await session.scalars(select(UnknownCluster).where(UnknownCluster.id.in_(cluster_ids))))
    rows = (
        await session.execute(
            select(FaceSample.cluster_id, FaceSample.embedding).where(
                FaceSample.cluster_id.in_(cluster_ids), FaceSample.deleted_at.is_(None)
            )
        )
    ).all()
    embeddings: dict[int, list[bytes]] = {}
    for cluster_id, embedding in rows:
        embeddings.setdefault(cluster_id, []).append(embedding)
    for cluster in clusters:
        remaining = embeddings.get(cluster.id, [])
        cluster.centroid = mean_embedding(remaining)
        if not remaining and cluster.deleted_at is None:
            cluster.deleted_at = now


async def purge_expired_samples(
    session: AsyncSession,
    now: datetime,
    retention_days: int,
    store: CropStore | None = None,
) -> int:
    """Delete camera samples older than the retention with their crops, in batches.

    The crops are stripped from the face events that still reference them, the clusters that lost samples get
    their centroids recomputed and a cluster left without samples is soft-deleted. Each batch commits on its own
    and its files are deleted after the commit.

    Args:
        session: Database session to work in.
        now: Current time.
        retention_days: Days camera samples are kept.
        store: Storage of face crops; the events folder from the settings when left out.

    Returns:
        Number of samples deleted.
    """
    store = store if store is not None else CropStore(settings.events_dir)
    cutoff = now - timedelta(days=retention_days)
    total = 0
    while True:
        await lock_faces(session)
        rows = (await session.execute(expired_samples(cutoff))).all()
        paths = []
        if rows:
            await session.execute(
                delete(FaceSample).where(FaceSample.id.in_([row.id for row in rows])).execution_options(**BULK)
            )
            paths = [row.crop_path for row in rows if row.crop_path]
            events = sorted({row.event_uuid for row in rows if row.event_uuid is not None})
            if events:
                paths += await strip_event_crops(session, Event.uuid.in_(events) & Event.kind.in_(FACE_KINDS))
            clusters = {row.cluster_id for row in rows if row.cluster_id is not None}
            if clusters:
                await refresh_clusters(session, clusters, now)
        await session.commit()
        await store.delete(paths)
        total += len(rows)
        if len(rows) < PURGE_BATCH:
            break
    if total:
        logger.info("Pruned %d face samples older than %d days", total, retention_days)
    return total
