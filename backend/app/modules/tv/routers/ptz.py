from uuid import UUID

from fastapi import APIRouter, Depends, Response, status

from app.modules.cameras.schemas import PtzMove
from app.modules.cameras.services import CameraService
from app.modules.tv.deps import get_tv_camera_service

router = APIRouter()


@router.post("/ptz/{camera_uuid}/move", status_code=status.HTTP_204_NO_CONTENT)
async def move_camera(
    camera_uuid: UUID,
    payload: PtzMove,
    service: CameraService = Depends(get_tv_camera_service),
) -> Response:
    await service.ptz_move(camera_uuid, payload)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post("/ptz/{camera_uuid}/stop", status_code=status.HTTP_204_NO_CONTENT)
async def stop_camera(camera_uuid: UUID, service: CameraService = Depends(get_tv_camera_service)) -> Response:
    await service.ptz_stop(camera_uuid)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
