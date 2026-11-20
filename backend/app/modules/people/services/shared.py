"""Queries and conversions shared by the services of the people module."""

from collections.abc import Iterable, Sequence
from dataclasses import dataclass, field
from uuid import UUID

from sqlalchemy import ColumnElement, and_, func, literal, or_, select, update
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import Camera, Event, FaceSample, Person, UnknownCluster
from app.modules.people.embeddings import mean_embedding
from app.modules.people.enums import FACE_KINDS, FACE_UNKNOWN, PERSON_COLORS, SampleSource
from app.modules.people.schemas import SampleRead, SightingRead

__all__ = [
    "BULK",
    "SAMPLES_IN_DETAIL",
    "SAMPLES_IN_LIST",
    "SIGHTINGS_LIMIT",
    "OwnerSamples",
    "camera_names",
    "cluster_events",
    "cluster_label",
    "lock_faces",
    "next_color",
    "owner_samples",
    "person_events",
    "recompute_centroid",
    "relabel_events",
    "sample_cameras",
    "sample_read",
    "sighting_read",
    "strip_event_crops",
]

FACES_LOCK_KEY = 7_316_052_241

SAMPLES_IN_LIST = 6
SAMPLES_IN_DETAIL = 24
SIGHTINGS_LIMIT = 5

BULK = {"synchronize_session": False}


@dataclass
class OwnerSamples:
    """Samples and sightings shown for one person or unknown cluster.

    Attributes:
        samples: Newest samples of any source.
        sightings: Newest samples seen by a camera.
    """

    samples: list[FaceSample] = field(default_factory=list)
    sightings: list[FaceSample] = field(default_factory=list)


def cluster_label(number: int) -> str:
    """Build the label shown for an unknown cluster.

    Args:
        number: Number of the cluster.

    Returns:
        The label, Unknown followed by the number.
    """
    return f"Unknown {number}"


async def lock_faces(session: AsyncSession) -> None:
    """Take the transaction lock that serialises every change of face sample owners.

    Face results, naming, merging, deleting and the retention pass all move samples between people and clusters,
    so they run one at a time; the lock is released when the transaction ends.

    Args:
        session: Database session whose transaction takes the lock.
    """
    await session.execute(select(func.pg_advisory_xact_lock(FACES_LOCK_KEY)))


async def next_color(session: AsyncSession) -> str:
    """Pick the palette color that the fewest live people use.

    Args:
        session: Database session.

    Returns:
        The least used palette color, the earliest in the palette on a tie.
    """
    rows = (
        await session.execute(
            select(Person.color, func.count()).where(Person.deleted_at.is_(None)).group_by(Person.color)
        )
    ).all()
    used = {str(color).lower(): count for color, count in rows}
    return min(PERSON_COLORS, key=lambda color: used.get(color, 0))


async def owner_samples(
    session: AsyncSession,
    owner: str,
    owner_ids: Sequence[int],
    samples_limit: int,
    sightings_limit: int,
) -> dict[int, OwnerSamples]:
    """Load the newest samples and sightings of several people or clusters in one query.

    Args:
        session: Database session.
        owner: Owner column of the samples, person_id or cluster_id.
        owner_ids: Database ids of the owners.
        samples_limit: Number of newest samples to load per owner.
        sightings_limit: Number of newest camera samples to load per owner.

    Returns:
        The samples and sightings of each owner that has any, newest first.
    """
    if not owner_ids:
        return {}
    column = getattr(FaceSample, owner)
    newest = (FaceSample.seen_at.desc(), FaceSample.id.desc())
    ranked = (
        select(
            FaceSample.id.label("id"),
            func.row_number().over(partition_by=column, order_by=newest).label("overall"),
            func.row_number().over(partition_by=(column, FaceSample.source), order_by=newest).label("by_source"),
        )
        .where(column.in_(owner_ids), FaceSample.deleted_at.is_(None))
        .subquery()
    )
    rows = (
        await session.execute(
            select(FaceSample, ranked.c.overall, ranked.c.by_source)
            .join(ranked, ranked.c.id == FaceSample.id)
            .where(
                or_(
                    ranked.c.overall <= samples_limit,
                    and_(FaceSample.source == SampleSource.EVENT.value, ranked.c.by_source <= sightings_limit),
                )
            )
            .order_by(column, *newest)
        )
    ).all()
    grouped: dict[int, OwnerSamples] = {}
    for sample, overall, by_source in rows:
        group = grouped.setdefault(getattr(sample, owner), OwnerSamples())
        if overall <= samples_limit:
            group.samples.append(sample)
        if sample.source == SampleSource.EVENT.value and by_source <= sightings_limit:
            group.sightings.append(sample)
    return grouped


async def camera_names(session: AsyncSession) -> dict[UUID, str]:
    """Load the name of every camera.

    The query is kept here rather than taken from the events module, so the camera events engine can import the
    people services without importing itself back.

    Args:
        session: Database session.

    Returns:
        The name of each camera by camera id.
    """
    rows = await session.execute(select(Camera.uuid, Camera.name))
    return {camera_uuid: name for camera_uuid, name in rows.all()}


async def sample_cameras(session: AsyncSession, groups: Iterable[OwnerSamples]) -> dict[UUID, str]:
    """Load camera names when any of the samples was seen by a camera.

    Args:
        session: Database session.
        groups: Samples and sightings about to be shown.

    Returns:
        The name of each camera, or an empty map when no sample has a camera.
    """
    for group in groups:
        if any(sample.camera_uuid is not None for sample in (*group.samples, *group.sightings)):
            return await camera_names(session)
    return {}


def sample_read(sample: FaceSample, names: dict[UUID, str]) -> SampleRead:
    """Convert a sample row to its response schema.

    Args:
        sample: Sample row.
        names: Camera names by camera id.

    Returns:
        The sample as shown to users.
    """
    return SampleRead(
        uuid=sample.uuid,
        source=SampleSource(sample.source),
        quality=sample.quality,
        confidence=sample.confidence,
        seen_at=sample.seen_at,
        has_crop=bool(sample.crop_path),
        event_uuid=sample.event_uuid,
        camera_uuid=sample.camera_uuid,
        camera_name=names.get(sample.camera_uuid) if sample.camera_uuid else None,
        view_name=sample.view_name,
    )


def sighting_read(sample: FaceSample, names: dict[UUID, str]) -> SightingRead:
    """Convert a camera sample row to a sighting.

    Args:
        sample: Sample row seen by a camera.
        names: Camera names by camera id.

    Returns:
        The sighting as shown to users.
    """
    return SightingRead(
        event_uuid=sample.event_uuid,
        sample_uuid=sample.uuid,
        camera_uuid=sample.camera_uuid,
        camera_name=names.get(sample.camera_uuid) if sample.camera_uuid else None,
        view_name=sample.view_name,
        seen_at=sample.seen_at,
        confidence=sample.confidence,
    )


def person_events(person_uuid: UUID) -> ColumnElement[bool]:
    """Build the condition that selects the face events of a person.

    Args:
        person_uuid: Public id of the person.

    Returns:
        Condition over the events table.
    """
    return and_(Event.kind.in_(FACE_KINDS), Event.details["person_uuid"].astext == str(person_uuid))


def cluster_events(cluster_uuid: UUID) -> ColumnElement[bool]:
    """Build the condition that selects the face events an unknown cluster still owns.

    Events of a cluster that was named keep its id for history but are known faces, so they are left out.

    Args:
        cluster_uuid: Public id of the cluster.

    Returns:
        Condition over the events table.
    """
    return and_(Event.kind == FACE_UNKNOWN, Event.details["cluster_uuid"].astext == str(cluster_uuid))


async def strip_event_crops(session: AsyncSession, condition: ColumnElement[bool]) -> list[str]:
    """Remove the crop from the face events that match a condition.

    Args:
        session: Database session.
        condition: Condition that selects the events.

    Returns:
        The image paths the events referenced, for deleting the files after the commit.
    """
    has_image = or_(Event.snapshot_path.is_not(None), Event.thumbnail_path.is_not(None))
    rows = (await session.execute(select(Event.snapshot_path, Event.thumbnail_path).where(condition, has_image))).all()
    await session.execute(
        update(Event)
        .where(condition, has_image)
        .values(snapshot_path=None, thumbnail_path=None)
        .execution_options(**BULK)
    )
    return [path for row in rows for path in row if path]


async def relabel_events(
    session: AsyncSession,
    condition: ColumnElement[bool],
    details: dict,
    kind: str | None = None,
) -> None:
    """Change the owner recorded in the face events that match a condition.

    Args:
        session: Database session.
        condition: Condition that selects the events.
        details: Fields merged into each event's details.
        kind: New kind of the events, or None to keep it.
    """
    values = {"details": Event.details.op("||")(literal(details, JSONB))}
    if kind is not None:
        values["kind"] = kind
    await session.execute(update(Event).where(condition).values(**values).execution_options(**BULK))


async def recompute_centroid(session: AsyncSession, cluster: UnknownCluster) -> int:
    """Set the centroid of a cluster to the normalised mean of its samples' embeddings.

    Pending changes are flushed first so the samples just moved or added count.

    Args:
        session: Database session.
        cluster: Cluster to update.

    Returns:
        Number of samples the cluster has.
    """
    await session.flush()
    embeddings = list(
        await session.scalars(
            select(FaceSample.embedding).where(FaceSample.cluster_id == cluster.id, FaceSample.deleted_at.is_(None))
        )
    )
    cluster.centroid = mean_embedding(embeddings)
    return len(embeddings)
