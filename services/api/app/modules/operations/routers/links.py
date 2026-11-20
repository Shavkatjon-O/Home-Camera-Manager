"""Camera link endpoint."""

from uuid import UUID

from fastapi import APIRouter, Depends

from app.modules.operations.deps import get_camera_link_service
from app.modules.operations.schemas import CameraLinkRead, CameraLinkUpdate
from app.modules.operations.services import CameraLinkService
from app.modules.tenancy.deps import require_admin

router = APIRouter()


@router.put("/{camera_uuid}", dependencies=[Depends(require_admin)], response_model=CameraLinkRead)
async def put_camera_link(
    camera_uuid: UUID,
    payload: CameraLinkUpdate,
    service: CameraLinkService = Depends(get_camera_link_service),
) -> CameraLinkRead:
    """Set or clear the device a camera connects through.

    Args:
        camera_uuid: Public id of the camera.
        payload: New parent device and link kind, or nulls to clear the link.
        service: Camera link service for the request.

    Returns:
        The camera's link after the change.
    """
    return await service.put(camera_uuid, payload)
