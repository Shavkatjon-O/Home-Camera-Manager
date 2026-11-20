"""Routes for known people.

The cluster and sample routes are included before the person routes are declared, so /people/clusters and
/people/samples are matched first and never taken for a person id.
"""

from uuid import UUID

from fastapi import APIRouter, Depends, Query, Response, status

from app.modules.people.deps import get_person_service, get_sample_service
from app.modules.people.schemas import (
    PersonCreate,
    PersonList,
    PersonMerge,
    PersonRead,
    PersonUpdate,
    PhotoUploadRequest,
    PhotoUploadResult,
)
from app.modules.people.services import PersonService, SampleService

from .clusters import router as clusters_router
from .samples import router as samples_router

router = APIRouter()
router.include_router(clusters_router, prefix="/clusters")
router.include_router(samples_router, prefix="/samples")

PAGE_SIZE_DEFAULT = 50
PAGE_SIZE_MAX = 200


@router.get("", response_model=PersonList)
async def list_people(
    page: int = Query(1, ge=1),
    page_size: int = Query(PAGE_SIZE_DEFAULT, ge=1, le=PAGE_SIZE_MAX),
    service: PersonService = Depends(get_person_service),
) -> PersonList:
    """List people sorted by name.

    Args:
        page: One-based page number.
        page_size: Number of people per page.
        service: Person service for the signed-in user.

    Returns:
        One page of people with the total count.
    """
    return await service.list_page(page, page_size)


@router.post("", response_model=PersonRead, status_code=status.HTTP_201_CREATED)
async def create_person(payload: PersonCreate, service: PersonService = Depends(get_person_service)) -> PersonRead:
    """Create a person.

    Args:
        payload: Person to create.
        service: Person service for the signed-in user.

    Returns:
        The created person.
    """
    return await service.create(payload)


@router.get("/{uuid}", response_model=PersonRead)
async def get_person(uuid: UUID, service: PersonService = Depends(get_person_service)) -> PersonRead:
    """Return one person with up to 24 samples.

    Args:
        uuid: Public id of the person.
        service: Person service for the signed-in user.

    Returns:
        The person.
    """
    return await service.detail(uuid)


@router.patch("/{uuid}", response_model=PersonRead)
async def update_person(
    uuid: UUID,
    payload: PersonUpdate,
    service: PersonService = Depends(get_person_service),
) -> PersonRead:
    """Change the given fields of a person.

    Args:
        uuid: Public id of the person.
        payload: Fields to change.
        service: Person service for the signed-in user.

    Returns:
        The updated person.
    """
    return await service.update(uuid, payload)


@router.delete("/{uuid}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_person(uuid: UUID, service: PersonService = Depends(get_person_service)) -> Response:
    """Delete a person with every sample and crop.

    Args:
        uuid: Public id of the person.
        service: Person service for the signed-in user.

    Returns:
        Empty response.
    """
    await service.delete(uuid)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post("/{uuid}/photos", response_model=PhotoUploadResult)
async def add_photos(
    uuid: UUID,
    payload: PhotoUploadRequest,
    service: PersonService = Depends(get_person_service),
) -> PhotoUploadResult:
    """Enroll photos of a person's face.

    Args:
        uuid: Public id of the person.
        payload: Photos as data URLs.
        service: Person service for the signed-in user.

    Returns:
        The person, the samples added and the photos rejected with their reasons.
    """
    return await service.add_photos(uuid, payload)


@router.delete("/{uuid}/samples/{sample_uuid}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_sample(
    uuid: UUID,
    sample_uuid: UUID,
    service: SampleService = Depends(get_sample_service),
) -> Response:
    """Delete one face sample of a person with its crop.

    Args:
        uuid: Public id of the person.
        sample_uuid: Public id of the sample.
        service: Sample service for the signed-in user.

    Returns:
        Empty response.
    """
    await service.delete(uuid, sample_uuid)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post("/{uuid}/merge", response_model=PersonRead)
async def merge_person(
    uuid: UUID,
    payload: PersonMerge,
    service: PersonService = Depends(get_person_service),
) -> PersonRead:
    """Merge a person into another.

    Args:
        uuid: Public id of the person that goes away.
        payload: The person that remains.
        service: Person service for the signed-in user.

    Returns:
        The remaining person.
    """
    return await service.merge(uuid, payload.into)
