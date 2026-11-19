from uuid import UUID

from fastapi import APIRouter, Depends

from app.modules.health.deps import get_camera_link_service
from app.modules.health.schemas import CameraLinkRead, CameraLinkUpdate
from app.modules.health.services import CameraLinkService

router = APIRouter()


@router.put("/{camera_uuid}", response_model=CameraLinkRead)
async def put_camera_link(
    camera_uuid: UUID,
    payload: CameraLinkUpdate,
    service: CameraLinkService = Depends(get_camera_link_service),
) -> CameraLinkRead:
    return await service.put(camera_uuid, payload)
