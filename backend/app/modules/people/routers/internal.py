"""Internal routes the analytics service calls with its bearer token, never served through nginx."""

from fastapi import APIRouter, Depends

from app.modules.people.deps import get_face_result_service, get_gallery_service, require_analytics_token
from app.modules.people.schemas import FaceResult, FaceResultAck, Gallery
from app.modules.people.services import FaceResultService, GalleryService

router = APIRouter(dependencies=[Depends(require_analytics_token)])


@router.get("/gallery", response_model=Gallery)
async def get_gallery(service: GalleryService = Depends(get_gallery_service)) -> Gallery:
    """Return the known people and unknown clusters to recognise faces against.

    Args:
        service: Gallery service.

    Returns:
        The gallery with its version digest.
    """
    return await service.build()


@router.post("/faces", response_model=FaceResultAck)
async def store_face(
    payload: FaceResult,
    service: FaceResultService = Depends(get_face_result_service),
) -> FaceResultAck:
    """Store the decision of the analytics service about who a person track is.

    Args:
        payload: Face result of one track.
        service: Face result service.

    Returns:
        The ids of the stored face event and sample and the cluster number of an unknown face.
    """
    return await service.store(payload)
