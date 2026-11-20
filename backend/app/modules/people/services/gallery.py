"""Service for the face gallery the analytics service recognises faces against."""

import hashlib
import json

from sqlalchemy import and_, case, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import FaceSample, Organisation, Person, UnknownCluster
from app.modules.people.embeddings import encode_embedding
from app.modules.people.enums import SampleSource
from app.modules.people.schemas import Gallery, GalleryCluster, GalleryPerson

__all__ = ["GalleryService", "gallery_version"]

EMBEDDINGS_PER_PERSON = 30
VERSION_LENGTH = 16


def gallery_version(people: list[GalleryPerson], clusters: list[GalleryCluster]) -> str:
    """Compute the version of a gallery as a digest of its content.

    Any change of a person's name, of the embeddings chosen for a person or of a cluster's number, centroid or
    sample count gives a new version, so the analytics service reloads exactly when something it uses changed.

    Args:
        people: People of the gallery.
        clusters: Clusters of the gallery.

    Returns:
        The first 16 hex characters of the SHA-256 of the content.
    """
    content = {
        "people": [person.model_dump(mode="json") for person in people],
        "clusters": [cluster.model_dump(mode="json") for cluster in clusters],
    }
    text = json.dumps(content, sort_keys=True, separators=(",", ":"))
    return hashlib.sha256(text.encode("utf-8")).hexdigest()[:VERSION_LENGTH]


class GalleryService:
    """Build the gallery of known people and unknown clusters.

    Attributes:
        session: Database session the service works in.
    """

    def __init__(self, session: AsyncSession):
        """Bind the service to a session.

        Args:
            session: Database session the service works in.
        """
        self.session = session

    def people_statement(self):
        """Build the query for the best embeddings of every live person.

        Only organisations with face recognition on take part. Each person gets at most 30 embeddings: every
        uploaded sample first, newest first, then camera samples by
        quality.

        Returns:
            Select statement of person id, name and embedding, in gallery order.
        """
        uploaded = FaceSample.source == SampleSource.UPLOAD.value
        ranked = (
            select(
                FaceSample.person_id.label("person_id"),
                FaceSample.embedding.label("embedding"),
                func.row_number()
                .over(
                    partition_by=FaceSample.person_id,
                    order_by=(
                        case((uploaded, 0), else_=1),
                        case((uploaded, FaceSample.seen_at)).desc().nulls_last(),
                        FaceSample.quality.desc(),
                        FaceSample.id.desc(),
                    ),
                )
                .label("rank"),
            )
            .where(FaceSample.person_id.is_not(None), FaceSample.deleted_at.is_(None))
            .subquery()
        )
        return (
            select(Person.uuid, Person.name, ranked.c.embedding)
            .join(ranked, ranked.c.person_id == Person.id)
            .join(Organisation, Organisation.id == Person.organisation_id)
            .where(Person.deleted_at.is_(None), ranked.c.rank <= EMBEDDINGS_PER_PERSON, Organisation.faces_enabled)
            .order_by(func.lower(Person.name), Person.id, ranked.c.rank)
        )

    def clusters_statement(self):
        """Build the query for the live clusters that have a centroid, with their sample counts.

        Returns:
            Select statement of cluster id, number, centroid and sample count, by number.
        """
        return (
            select(UnknownCluster.uuid, UnknownCluster.number, UnknownCluster.centroid, func.count(FaceSample.id))
            .outerjoin(FaceSample, and_(FaceSample.cluster_id == UnknownCluster.id, FaceSample.deleted_at.is_(None)))
            .join(Organisation, Organisation.id == UnknownCluster.organisation_id)
            .where(
                UnknownCluster.deleted_at.is_(None),
                UnknownCluster.centroid.is_not(None),
                Organisation.faces_enabled,
            )
            .group_by(UnknownCluster.id)
            .order_by(UnknownCluster.number)
        )

    async def build(self) -> Gallery:
        """Load the gallery.

        Returns:
            The people with their embeddings, the clusters with their centroids and the version digest.
        """
        people: list[GalleryPerson] = []
        by_uuid: dict = {}
        for uuid, name, embedding in (await self.session.execute(self.people_statement())).all():
            person = by_uuid.get(uuid)
            if person is None:
                person = GalleryPerson(uuid=uuid, name=name, embeddings=[])
                by_uuid[uuid] = person
                people.append(person)
            person.embeddings.append(encode_embedding(embedding))
        clusters = [
            GalleryCluster(uuid=uuid, number=number, centroid=encode_embedding(centroid), count=count)
            for uuid, number, centroid, count in (await self.session.execute(self.clusters_statement())).all()
        ]
        return Gallery(version=gallery_version(people, clusters), people=people, clusters=clusters)
