"""Routes that let a paired TV move a camera."""

from uuid import UUID

from fastapi import APIRouter, Depends, Response, status

from app.modules.devices.schemas import PtzMove
from app.modules.devices.services import CameraService
from app.modules.tv.deps import get_tv_camera_service

router = APIRouter()


@router.post("/ptz/{camera_uuid}/move", status_code=status.HTTP_204_NO_CONTENT)
async def move_tv_camera(
    camera_uuid: UUID,
    payload: PtzMove,
    service: CameraService = Depends(get_tv_camera_service),
) -> Response:
    """Start moving a camera.

    Args:
        camera_uuid: Public id of the camera.
        payload: Direction and speed of the move.
        service: Camera service for the authenticated TV.

    Returns:
        Empty response.
    """
    await service.ptz_move(camera_uuid, payload)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post("/ptz/{camera_uuid}/stop", status_code=status.HTTP_204_NO_CONTENT)
async def stop_tv_camera(camera_uuid: UUID, service: CameraService = Depends(get_tv_camera_service)) -> Response:
    """Stop a camera's movement.

    Args:
        camera_uuid: Public id of the camera.
        service: Camera service for the authenticated TV.

    Returns:
        Empty response.
    """
    await service.ptz_stop(camera_uuid)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
