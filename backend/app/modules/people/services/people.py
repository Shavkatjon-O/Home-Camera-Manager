"""Service for known people: listing, editing, deleting, merging and enrolling photos."""

from dataclasses import dataclass
from datetime import UTC, datetime
from uuid import UUID, uuid4

from sqlalchemy import delete, func, select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.core.base_service import BaseModelService
from app.core.config import settings
from app.core.exceptions import NotFound, Unavailable, Unprocessable
from app.modules.people.analytics import AnalyticsClient
from app.modules.people.crops import CropStore, enrolled_crop_path
from app.modules.people.enums import SampleSource
from app.modules.people.models import FaceSample, Person
from app.modules.people.photos import PhotoRejected, choose_face, decode_photo
from app.modules.people.schemas import (
    DetectedFace,
    PersonCreate,
    PersonList,
    PersonRead,
    PersonUpdate,
    PhotoRejection,
    PhotoUploadRequest,
    PhotoUploadResult,
)

from .shared import (
    BULK,
    SAMPLES_IN_DETAIL,
    SAMPLES_IN_LIST,
    SIGHTINGS_LIMIT,
    OwnerSamples,
    lock_faces,
    next_color,
    owner_samples,
    person_events,
    relabel_events,
    sample_cameras,
    sample_read,
    sighting_read,
    strip_event_crops,
)

__all__ = ["PersonService", "PersonStats", "missing_person", "person_reads"]


@dataclass(frozen=True)
class PersonStats:
    """Sample counts of one person.

    Attributes:
        sample_count: Number of samples.
        upload_count: Number of uploaded samples.
        last_seen_at: When a camera last saw the person, if ever.
    """

    sample_count: int = 0
    upload_count: int = 0
    last_seen_at: datetime | None = None


async def person_stats(session: AsyncSession, person_ids: list[int]) -> dict[int, PersonStats]:
    """Count the samples of several people in one query.

    Args:
        session: Database session.
        person_ids: Database ids of the people.

    Returns:
        The counts of each person that has samples.
    """
    rows = (
        await session.execute(
            select(
                FaceSample.person_id,
                func.count(),
                func.count().filter(FaceSample.source == SampleSource.UPLOAD.value),
                func.max(FaceSample.seen_at).filter(FaceSample.source == SampleSource.EVENT.value),
            )
            .where(FaceSample.person_id.in_(person_ids), FaceSample.deleted_at.is_(None))
            .group_by(FaceSample.person_id)
        )
    ).all()
    return {person_id: PersonStats(count, uploads, last_seen) for person_id, count, uploads, last_seen in rows}


def person_read(person: Person, stats: PersonStats, group: OwnerSamples, names: dict[UUID, str]) -> PersonRead:
    """Convert a person row and its samples to the response schema.

    Args:
        person: Person row.
        stats: Sample counts of the person.
        group: Newest samples and sightings of the person.
        names: Camera names by camera id.

    Returns:
        The person as shown to users.
    """
    return PersonRead(
        uuid=person.uuid,
        name=person.name,
        notes=person.notes,
        color=person.color,
        sample_count=stats.sample_count,
        upload_count=stats.upload_count,
        samples=[sample_read(sample, names) for sample in group.samples],
        last_seen_at=stats.last_seen_at,
        sightings=[sighting_read(sample, names) for sample in group.sightings],
        created_at=person.created_at,
        updated_at=person.updated_at,
    )


async def person_reads(session: AsyncSession, people: list[Person], samples_limit: int) -> list[PersonRead]:
    """Convert person rows to response schemas with their counts, samples and sightings.

    Args:
        session: Database session.
        people: Person rows.
        samples_limit: Number of newest samples to include per person.

    Returns:
        The people in the given order.
    """
    if not people:
        return []
    ids = [person.id for person in people]
    stats = await person_stats(session, ids)
    groups = await owner_samples(session, "person_id", ids, samples_limit, SIGHTINGS_LIMIT)
    names = await sample_cameras(session, groups.values())
    return [
        person_read(person, stats.get(person.id, PersonStats()), groups.get(person.id, OwnerSamples()), names)
        for person in people
    ]


class PersonService(BaseModelService[Person]):
    """Create, read, change, delete and merge people and enroll photos of their faces.

    Attributes:
        store: Storage of face crops.
        analytics: Client of the analytics enrollment endpoint, if available.
    """

    model = Person
    not_found_code = "person_not_found"

    def __init__(
        self,
        session: AsyncSession,
        actor: UserContext | None = None,
        store: CropStore | None = None,
        analytics: AnalyticsClient | None = None,
    ):
        """Bind the service to a session, its user, the crop storage and the analytics service.

        Args:
            session: Database session the service works in.
            actor: User making the request, if any.
            store: Storage of face crops; the events folder from the settings when left out.
            analytics: Client of the analytics enrollment endpoint, if available.
        """
        super().__init__(session, actor)
        self.store = store if store is not None else CropStore(settings.events_dir)
        self.analytics = analytics

    async def list_page(self, page: int, page_size: int) -> PersonList:
        """List one page of live people sorted by name.

        Args:
            page: One-based page number.
            page_size: Number of people per page.

        Returns:
            People on the page with the total count.
        """
        live = Person.deleted_at.is_(None)
        total = await self.session.scalar(select(func.count()).select_from(Person).where(live))
        people = list(
            await self.session.scalars(
                select(Person)
                .where(live)
                .order_by(func.lower(Person.name), Person.id)
                .offset((page - 1) * page_size)
                .limit(page_size)
            )
        )
        return PersonList(
            items=await person_reads(self.session, people, SAMPLES_IN_LIST),
            total=total or 0,
            page=page,
            page_size=page_size,
        )

    async def detail(self, uuid: UUID) -> PersonRead:
        """Load one person with up to 24 samples.

        Args:
            uuid: Public id of the person.

        Returns:
            The person.
        """
        person = await self.get(uuid)
        return (await person_reads(self.session, [person], SAMPLES_IN_DETAIL))[0]

    async def create(self, payload: PersonCreate) -> PersonRead:
        """Store a new person.

        Args:
            payload: Person to create.

        Returns:
            The stored person, without samples yet.
        """
        color = payload.color or await next_color(self.session)
        person = Person(uuid=uuid4(), name=payload.name, notes=payload.notes, color=color)
        self.session.add(person)
        await self.commit()
        await self.session.refresh(person)
        return person_read(person, PersonStats(), OwnerSamples(), {})

    async def update(self, uuid: UUID, payload: PersonUpdate) -> PersonRead:
        """Change a person.

        Args:
            uuid: Public id of the person.
            payload: Fields to change.

        Returns:
            The updated person.
        """
        person = await self.get(uuid)
        for name in payload.model_fields_set:
            setattr(person, name, getattr(payload, name))
        await self.commit()
        await self.session.refresh(person)
        return (await person_reads(self.session, [person], SAMPLES_IN_DETAIL))[0]

    async def delete(self, uuid: UUID) -> None:
        """Delete a person with every sample and crop, and strip the crops from the person's face events.

        The samples are deleted for good and the person is soft-deleted; the files go after the commit.

        Args:
            uuid: Public id of the person.
        """
        await lock_faces(self.session)
        person = await self.get(uuid)
        crops = (
            await self.session.execute(
                select(FaceSample.crop_path).where(FaceSample.person_id == person.id, FaceSample.crop_path.is_not(None))
            )
        ).all()
        await self.session.execute(
            delete(FaceSample).where(FaceSample.person_id == person.id).execution_options(**BULK)
        )
        paths = [path for (path,) in crops]
        paths += await strip_event_crops(self.session, person_events(person.uuid))
        person.deleted_at = func.now()
        await self.commit()
        await self.store.delete(paths)

    async def merge(self, uuid: UUID, into: UUID) -> PersonRead:
        """Merge a person into another: the samples and face events move and the source is soft-deleted.

        Args:
            uuid: Public id of the person that goes away.
            into: Public id of the person that remains.

        Returns:
            The remaining person.

        Raises:
            Unprocessable: When both ids name the same person.
        """
        if uuid == into:
            raise Unprocessable("same_person", "A person cannot be merged into themselves")
        await lock_faces(self.session)
        source = await self.get(uuid)
        target = await self.get(into)
        await self.session.execute(
            update(FaceSample)
            .where(FaceSample.person_id == source.id)
            .values(person_id=target.id)
            .execution_options(**BULK)
        )
        await relabel_events(self.session, person_events(source.uuid), {"person_uuid": str(target.uuid)})
        source.deleted_at = func.now()
        await self.commit()
        await self.session.refresh(target)
        return (await person_reads(self.session, [target], SAMPLES_IN_DETAIL))[0]

    async def enroll_face(self, data: str) -> DetectedFace:
        """Find the one face of a photo through the analytics service.

        Args:
            data: Photo as a base64 data URL.

        Returns:
            The face with its embedding and crop.

        Raises:
            PhotoRejected: When the photo cannot be read or does not hold exactly one large enough face.
            Unavailable: When no analytics client is available or the service does not answer.
        """
        if self.analytics is None:
            raise Unavailable("analytics_not_configured", "The analytics service is not configured")
        content, content_type = decode_photo(data)
        return choose_face(await self.analytics.embed(content, content_type))

    async def add_photos(self, uuid: UUID, payload: PhotoUploadRequest) -> PhotoUploadResult:
        """Enroll photos of a person, each of which must hold exactly one face.

        Every accepted photo becomes an uploaded sample with the embedding and quality the analytics service
        returned, and its crop is written to people/<person uuid>/<sample uuid>.jpg. Crops already written are
        deleted again when the upload fails.

        Args:
            uuid: Public id of the person.
            payload: Photos to enroll.

        Returns:
            The person after the upload, the samples added and the photos rejected with their reasons.
        """
        person = await self.get(uuid)
        added: list[FaceSample] = []
        rejected: list[PhotoRejection] = []
        written: list[str] = []
        try:
            for photo in payload.photos:
                try:
                    face = await self.enroll_face(photo.data)
                except PhotoRejected as exc:
                    rejected.append(PhotoRejection(name=photo.name, reason=exc.reason))
                    continue
                sample = FaceSample(
                    uuid=uuid4(),
                    person_id=person.id,
                    source=SampleSource.UPLOAD.value,
                    embedding=face.embedding,
                    quality=face.quality,
                    seen_at=datetime.now(UTC),
                    details={
                        "photo": photo.name,
                        "score": face.score,
                        "size": face.size,
                        "frontal": face.frontal,
                        "sharpness": face.sharpness,
                    },
                )
                relative = enrolled_crop_path(person.uuid, sample.uuid)
                if await self.store.write(relative, face.crop):
                    sample.crop_path = relative
                    written.append(relative)
                self.session.add(sample)
                added.append(sample)
            if added:
                await self.commit()
        except BaseException:
            await self.store.delete(written)
            raise
        read = (await person_reads(self.session, [person], SAMPLES_IN_DETAIL))[0]
        return PhotoUploadResult(person=read, added=[sample_read(sample, {}) for sample in added], rejected=rejected)


def missing_person(uuid: UUID) -> NotFound:
    """Build the error for a person that does not exist.

    Args:
        uuid: Public id that was asked for.

    Returns:
        Error with the person_not_found code.
    """
    return NotFound("person_not_found", f"Person {uuid} does not exist")
