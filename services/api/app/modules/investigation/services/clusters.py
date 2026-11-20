"""Service for unknown face clusters: listing, naming, merging and deleting."""

from uuid import UUID, uuid4

from sqlalchemy import delete, func, select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.core.base_service import BaseModelService
from app.core.config import settings
from app.core.exceptions import NotFound, Unprocessable
from app.models import FaceSample, Person, UnknownCluster
from app.modules.people.crops import CropStore
from app.modules.people.enums import FACE_KNOWN
from app.modules.people.schemas import ClusterList, ClusterName, ClusterRead, PersonRead

from .people import missing_person, person_reads
from .shared import (
    BULK,
    SAMPLES_IN_DETAIL,
    SAMPLES_IN_LIST,
    SIGHTINGS_LIMIT,
    OwnerSamples,
    cluster_events,
    cluster_label,
    lock_faces,
    next_color,
    owner_samples,
    recompute_centroid,
    relabel_events,
    sample_cameras,
    sample_read,
    sighting_read,
    strip_event_crops,
)

__all__ = ["ClusterService", "cluster_reads"]


async def cluster_reads(session: AsyncSession, clusters: list[UnknownCluster]) -> list[ClusterRead]:
    """Convert cluster rows to response schemas with their newest samples and sightings.

    Args:
        session: Database session.
        clusters: Cluster rows.

    Returns:
        The clusters in the given order.
    """
    if not clusters:
        return []
    groups = await owner_samples(
        session, "cluster_id", [cluster.id for cluster in clusters], SAMPLES_IN_LIST, SIGHTINGS_LIMIT
    )
    names = await sample_cameras(session, groups.values())
    reads = []
    for cluster in clusters:
        group = groups.get(cluster.id, OwnerSamples())
        reads.append(
            ClusterRead(
                uuid=cluster.uuid,
                number=cluster.number,
                label=cluster_label(cluster.number),
                seen_count=cluster.seen_count,
                first_seen_at=cluster.first_seen_at,
                last_seen_at=cluster.last_seen_at,
                samples=[sample_read(sample, names) for sample in group.samples],
                sightings=[sighting_read(sample, names) for sample in group.sightings],
                created_at=cluster.created_at,
                updated_at=cluster.updated_at,
            )
        )
    return reads


class ClusterService(BaseModelService[UnknownCluster]):
    """List unknown clusters, name them after a person, merge them and delete them.

    Attributes:
        store: Storage of face crops.
    """

    model = UnknownCluster
    not_found_code = "cluster_not_found"

    def __init__(self, session: AsyncSession, actor: UserContext | None = None, store: CropStore | None = None):
        """Bind the service to a session, its user and the crop storage.

        Args:
            session: Database session the service works in.
            actor: User making the request, if any.
            store: Storage of face crops; the events folder from the settings when left out.
        """
        super().__init__(session, actor)
        self.store = store if store is not None else CropStore(settings.events_dir)

    async def get(self, uuid: UUID) -> UnknownCluster:
        """Load a live cluster, or fail.

        Args:
            uuid: Public id of the cluster.

        Returns:
            The cluster.

        Raises:
            NotFound: The cluster does not exist or is deleted.
        """
        cluster = await self.find(uuid)
        if cluster is None:
            raise NotFound(self.not_found_code, f"Unknown cluster {uuid} does not exist")
        return cluster

    async def list_page(self, page: int, page_size: int) -> ClusterList:
        """List one page of live clusters, the most recently seen first.

        Args:
            page: One-based page number.
            page_size: Number of clusters per page.

        Returns:
            Clusters on the page with the total count.
        """
        live = UnknownCluster.deleted_at.is_(None)
        total = await self.session.scalar(select(func.count()).select_from(UnknownCluster).where(live))
        clusters = list(
            await self.session.scalars(
                select(UnknownCluster)
                .where(live)
                .order_by(UnknownCluster.last_seen_at.desc(), UnknownCluster.id.desc())
                .offset((page - 1) * page_size)
                .limit(page_size)
            )
        )
        return ClusterList(
            items=await cluster_reads(self.session, clusters),
            total=total or 0,
            page=page,
            page_size=page_size,
        )

    async def name(self, uuid: UUID, payload: ClusterName) -> PersonRead:
        """Name a cluster after an existing person or a new one.

        Every sample of the cluster moves to the person, the cluster's face events become known faces of the
        person while keeping the cluster id for history, and the cluster is soft-deleted.

        Args:
            uuid: Public id of the cluster.
            payload: The person to join, or the name of a new person, and an optional color.

        Returns:
            The person the cluster became.

        Raises:
            NotFound: When the cluster or the named person does not exist.
        """
        await lock_faces(self.session)
        cluster = await self.get(uuid)
        if payload.person is not None:
            person = await self.session.scalar(
                select(Person).where(Person.uuid == payload.person, Person.deleted_at.is_(None))
            )
            if person is None:
                raise missing_person(payload.person)
            if payload.color is not None:
                person.color = payload.color
        else:
            color = payload.color or await next_color(self.session)
            person = Person(uuid=uuid4(), name=payload.name, notes=None, color=color)
            self.session.add(person)
            await self.session.flush()
        await self.session.execute(
            update(FaceSample)
            .where(FaceSample.cluster_id == cluster.id)
            .values(person_id=person.id, cluster_id=None)
            .execution_options(**BULK)
        )
        await relabel_events(
            self.session, cluster_events(cluster.uuid), {"person_uuid": str(person.uuid)}, kind=FACE_KNOWN
        )
        cluster.centroid = None
        cluster.deleted_at = func.now()
        await self.commit()
        await self.session.refresh(person)
        return (await person_reads(self.session, [person], SAMPLES_IN_DETAIL))[0]

    async def merge(self, uuid: UUID, into: UUID) -> ClusterRead:
        """Merge a cluster into another: samples and face events move, seen counts add up and the source goes.

        Args:
            uuid: Public id of the cluster that goes away.
            into: Public id of the cluster that remains.

        Returns:
            The remaining cluster with its recomputed centroid.

        Raises:
            Unprocessable: When both ids name the same cluster.
        """
        if uuid == into:
            raise Unprocessable("same_cluster", "A cluster cannot be merged into itself")
        await lock_faces(self.session)
        source = await self.get(uuid)
        target = await self.get(into)
        await self.session.execute(
            update(FaceSample)
            .where(FaceSample.cluster_id == source.id)
            .values(cluster_id=target.id)
            .execution_options(**BULK)
        )
        await relabel_events(self.session, cluster_events(source.uuid), {"cluster_uuid": str(target.uuid)})
        target.seen_count = (target.seen_count or 0) + (source.seen_count or 0)
        target.first_seen_at = min(target.first_seen_at, source.first_seen_at)
        target.last_seen_at = max(target.last_seen_at, source.last_seen_at)
        source.centroid = None
        source.deleted_at = func.now()
        await recompute_centroid(self.session, target)
        await self.commit()
        await self.session.refresh(target)
        return (await cluster_reads(self.session, [target]))[0]

    async def delete(self, uuid: UUID) -> None:
        """Delete a cluster with its samples and crops, and strip the crops from its face events.

        The samples are deleted for good and the cluster is soft-deleted; the files go after the commit.

        Args:
            uuid: Public id of the cluster.
        """
        await lock_faces(self.session)
        cluster = await self.get(uuid)
        crops = (
            await self.session.execute(
                select(FaceSample.crop_path).where(
                    FaceSample.cluster_id == cluster.id, FaceSample.crop_path.is_not(None)
                )
            )
        ).all()
        await self.session.execute(
            delete(FaceSample).where(FaceSample.cluster_id == cluster.id).execution_options(**BULK)
        )
        paths = [path for (path,) in crops]
        paths += await strip_event_crops(self.session, cluster_events(cluster.uuid))
        cluster.centroid = None
        cluster.deleted_at = func.now()
        await self.commit()
        await self.store.delete(paths)
