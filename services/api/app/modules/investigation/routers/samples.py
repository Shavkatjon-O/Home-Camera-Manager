"""Routes for single face samples."""

from uuid import UUID

from fastapi import APIRouter, Depends
from fastapi.responses import FileResponse

from app.modules.people.deps import get_sample_service
from app.modules.people.services import SampleService

router = APIRouter()

CROP_HEADERS = {"Cache-Control": "private, max-age=300"}


@router.get(
    "/{uuid}/crop",
    response_class=FileResponse,
    responses={200: {"content": {"image/jpeg": {"schema": {"type": "string", "format": "binary"}}}}},
)
async def get_face_crop(uuid: UUID, service: SampleService = Depends(get_sample_service)) -> FileResponse:
    """Return the crop image of a face sample.

    The cache time is short because the analytics service may write a better crop for an ongoing face event.

    Args:
        uuid: Public id of the sample.
        service: Sample service for the signed-in user.

    Returns:
        The JPEG file.
    """
    return FileResponse(await service.crop(uuid), media_type="image/jpeg", headers=CROP_HEADERS)
