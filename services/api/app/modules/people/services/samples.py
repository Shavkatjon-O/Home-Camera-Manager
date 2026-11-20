"""Service for single face samples: serving their crops and deleting them."""

from pathlib import Path
from uuid import UUID

from sqlalchemy import delete, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.core.base_service import BaseModelService
from app.core.config import settings
from app.core.exceptions import NotFound
from app.models import Event, FaceSample, Person
from app.modules.people.crops import CropStore
from app.modules.people.enums import FACE_KINDS

from .people import missing_person
from .shared import BULK, strip_event_crops

__all__ = ["SampleService"]


class SampleService(BaseModelService[FaceSample]):
    """Serve the crop of a face sample and delete samples of a person.

    Attributes:
        store: Storage of face crops.
    """

    model = FaceSample
    not_found_code = "sample_not_found"

    def __init__(self, session: AsyncSession, actor: UserContext | None = None, store: CropStore | None = None):
        """Bind the service to a session, its user and the crop storage.

        Args:
            session: Database session the service works in.
            actor: User making the request, if any.
            store: Storage of face crops; the events folder from the settings when left out.
        """
        super().__init__(session, actor)
        self.store = store if store is not None else CropStore(settings.events_dir)

    async def get(self, uuid: UUID) -> FaceSample:
        """Load a live sample, or fail.

        Args:
            uuid: Public id of the sample.

        Returns:
            The sample.

        Raises:
            NotFound: The sample does not exist.
        """
        sample = await self.find(uuid)
        if sample is None:
            raise NotFound(self.not_found_code, f"Face sample {uuid} does not exist")
        return sample

    async def crop(self, uuid: UUID) -> Path:
        """Find the crop file of a sample.

        Args:
            uuid: Public id of the sample.

        Returns:
            Absolute path of the JPEG file.

        Raises:
            NotFound: When the sample does not exist or has no crop file.
        """
        sample = await self.get(uuid)
        path = self.store.resolve(sample.crop_path)
        if path is None or not path.is_file():
            raise NotFound("crop_not_found", "This face sample has no crop")
        return path

    async def delete(self, person_uuid: UUID, sample_uuid: UUID) -> None:
        """Delete one sample of a person with its crop, and strip that crop from its face event.

        Args:
            person_uuid: Public id of the person.
            sample_uuid: Public id of the sample.

        Raises:
            NotFound: When the person does not exist or has no such sample.
        """
        person = await self.session.scalar(
            select(Person).where(Person.uuid == person_uuid, Person.deleted_at.is_(None))
        )
        if person is None:
            raise missing_person(person_uuid)
        sample = await self.session.scalar(
            select(FaceSample).where(
                FaceSample.uuid == sample_uuid,
                FaceSample.person_id == person.id,
                FaceSample.deleted_at.is_(None),
            )
        )
        if sample is None:
            raise NotFound(self.not_found_code, f"Face sample {sample_uuid} does not exist")
        await self.session.execute(delete(FaceSample).where(FaceSample.id == sample.id).execution_options(**BULK))
        paths = [sample.crop_path]
        if sample.event_uuid is not None:
            paths += await strip_event_crops(
                self.session, (Event.uuid == sample.event_uuid) & Event.kind.in_(FACE_KINDS)
            )
        await self.commit()
        await self.store.delete(paths)
