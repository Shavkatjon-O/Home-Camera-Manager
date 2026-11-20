"""Service for the face similarity search over every stored face sample."""

from sqlalchemy import and_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.core.base_service import BaseModelService
from app.core.exceptions import NotFound, Unavailable, Unprocessable
from app.models import FaceSample, Person, UnknownCluster
from app.modules.investigation.analytics import AnalyticsClient
from app.modules.investigation.embeddings import EMBEDDING_BYTES, rank, stack, to_vector
from app.modules.investigation.enums import SampleSource
from app.modules.investigation.photos import PhotoRejected, choose_face, decode_photo
from app.modules.investigation.schemas import SimilarPage, SimilarQuery, SimilarRead
from app.modules.investigation.services.shared import camera_names, cluster_label

__all__ = ["SimilarService", "rank_samples"]

SCORE_MIN = 0.25


def rank_samples(
    query: bytes,
    rows: list[tuple[int, bytes]],
    exclude: int | None,
    threshold: float = SCORE_MIN,
) -> list[tuple[int, float]]:
    """Rank stored samples by their similarity to a query embedding.

    Args:
        query: Raw bytes of the query embedding.
        rows: Database id and raw embedding of every candidate sample.
        exclude: Database id of the query's own sample, left out of the ranking, if any.
        threshold: Lowest similarity to keep.

    Returns:
        Sample id and similarity of every sample at or above the threshold, most similar first.
    """
    candidates = [(sample_id, raw) for sample_id, raw in rows if sample_id != exclude and len(raw) == EMBEDDING_BYTES]
    matrix = stack([raw for _, raw in candidates])
    return [(candidates[index][0], score) for index, score in rank(to_vector(query), matrix, threshold)]


class SimilarService(BaseModelService[FaceSample]):
    """Find the stored faces most similar to a sample, a face event or a photo.

    Attributes:
        analytics: Client of the analytics enrollment endpoint for photo queries, if available.
    """

    model = FaceSample
    not_found_code = "sample_not_found"

    def __init__(
        self,
        session: AsyncSession,
        actor: UserContext | None = None,
        analytics: AnalyticsClient | None = None,
    ):
        """Bind the service to a session, its user and the analytics service.

        Args:
            session: Database session the service works in.
            actor: User making the request, if any.
            analytics: Client of the analytics enrollment endpoint, if available.
        """
        super().__init__(session, actor)
        self.analytics = analytics

    async def query_embedding(self, query: SimilarQuery) -> tuple[bytes, int | None]:
        """Find the embedding to search with.

        Args:
            query: Similarity request.

        Returns:
            The raw query embedding and the database id of its own sample, if it is a stored one.

        Raises:
            NotFound: When the sample, or the face sample of the event, does not exist.
            Unprocessable: When the photo cannot be read or does not hold exactly one large enough face.
            Unavailable: When a photo is sent and no analytics client is available.
        """
        if query.sample is not None:
            sample = await self.find(query.sample)
            if sample is None:
                raise NotFound(self.not_found_code, f"Face sample {query.sample} does not exist")
            return sample.embedding, sample.id
        if query.event is not None:
            sample = await self.session.scalar(
                select(FaceSample)
                .where(FaceSample.event_uuid == query.event, FaceSample.deleted_at.is_(None))
                .order_by(FaceSample.id.desc())
                .limit(1)
            )
            if sample is None:
                raise NotFound("face_event_not_found", f"Event {query.event} has no stored face")
            return sample.embedding, sample.id
        if self.analytics is None:
            raise Unavailable("analytics_not_configured", "The analytics service is not configured")
        try:
            content, content_type = decode_photo(query.photo or "")
            face = choose_face(await self.analytics.embed(content, content_type))
        except PhotoRejected as exc:
            raise Unprocessable("photo_rejected", exc.reason)
        return face.embedding, None

    async def similar(self, query: SimilarQuery) -> SimilarPage:
        """Rank every live stored face by cosine similarity to the query and return one page.

        Args:
            query: Similarity request with its page.

        Returns:
            Similar samples on the page, most similar first, with the total count of similar samples.
        """
        embedding, exclude = await self.query_embedding(query)
        rows = (
            await self.session.execute(
                select(FaceSample.id, FaceSample.embedding).where(FaceSample.deleted_at.is_(None))
            )
        ).all()
        ranked = rank_samples(embedding, [(sample_id, raw) for sample_id, raw in rows], exclude)
        start = (query.page - 1) * query.page_size
        window = ranked[start : start + query.page_size]
        return SimilarPage(
            items=await self.reads(window),
            total=len(ranked),
            page=query.page,
            page_size=query.page_size,
        )

    async def reads(self, window: list[tuple[int, float]]) -> list[SimilarRead]:
        """Load the samples of one page with their owners and cameras.

        Args:
            window: Sample id and similarity of each result on the page, in order.

        Returns:
            The results in the same order.
        """
        if not window:
            return []
        rows = (
            await self.session.execute(
                select(FaceSample, Person.uuid, Person.name, Person.color, UnknownCluster.uuid, UnknownCluster.number)
                .outerjoin(Person, and_(Person.id == FaceSample.person_id, Person.deleted_at.is_(None)))
                .outerjoin(UnknownCluster, UnknownCluster.id == FaceSample.cluster_id)
                .where(FaceSample.id.in_([sample_id for sample_id, _ in window]))
            )
        ).all()
        found = {row[0].id: row for row in rows}
        names = await camera_names(self.session) if any(row[0].camera_uuid for row in rows) else {}
        reads = []
        for sample_id, score in window:
            row = found.get(sample_id)
            if row is None:
                continue
            sample, person_uuid, person_name, person_color, cluster_uuid, number = row
            reads.append(
                SimilarRead(
                    sample_uuid=sample.uuid,
                    score=round(score, 4),
                    source=SampleSource(sample.source),
                    seen_at=sample.seen_at,
                    has_crop=bool(sample.crop_path),
                    person_uuid=person_uuid,
                    person_name=person_name,
                    person_color=person_color,
                    cluster_uuid=cluster_uuid,
                    cluster_label=cluster_label(number) if number is not None else None,
                    event_uuid=sample.event_uuid,
                    camera_uuid=sample.camera_uuid,
                    camera_name=names.get(sample.camera_uuid) if sample.camera_uuid else None,
                    view_name=sample.view_name,
                )
            )
        return reads
