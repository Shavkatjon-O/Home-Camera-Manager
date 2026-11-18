from uuid import UUID

from fastapi import APIRouter, Depends, Query, Response, status

from app.modules.cameras.deps import get_camera_service
from app.modules.cameras.enums import CameraSort
from app.modules.cameras.schemas import CameraCreate, CameraList, CameraOrder, CameraRead, CameraUpdate, PtzMove
from app.modules.cameras.services import CameraService

router = APIRouter()

PAGE_SIZE_DEFAULT = 50
PAGE_SIZE_MAX = 200


def no_content() -> Response:
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.get("", response_model=CameraList)
async def list_cameras(
    page: int = Query(1, ge=1),
    page_size: int = Query(PAGE_SIZE_DEFAULT, ge=1, le=PAGE_SIZE_MAX),
    order: CameraSort = Query(CameraSort.CREATED),
    service: CameraService = Depends(get_camera_service),
) -> CameraList:
    return await service.list_page(page, page_size, order)


@router.post("", response_model=CameraRead, status_code=status.HTTP_201_CREATED)
async def create_camera(payload: CameraCreate, service: CameraService = Depends(get_camera_service)) -> CameraRead:
    return await service.create(payload)


@router.put("/order", status_code=status.HTTP_204_NO_CONTENT)
async def order_cameras(payload: CameraOrder, service: CameraService = Depends(get_camera_service)) -> Response:
    await service.reorder(payload.uuids)
    return no_content()


@router.get("/{uuid}", response_model=CameraRead)
async def get_camera(uuid: UUID, service: CameraService = Depends(get_camera_service)) -> CameraRead:
    return await service.detail(uuid)


@router.patch("/{uuid}", response_model=CameraRead)
async def update_camera(
    uuid: UUID,
    payload: CameraUpdate,
    service: CameraService = Depends(get_camera_service),
) -> CameraRead:
    return await service.update(uuid, payload)


@router.delete("/{uuid}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_camera(uuid: UUID, service: CameraService = Depends(get_camera_service)) -> Response:
    await service.delete(uuid)
    return no_content()


@router.post("/{uuid}/check", response_model=CameraRead)
async def check_camera(uuid: UUID, service: CameraService = Depends(get_camera_service)) -> CameraRead:
    return await service.check(uuid)


@router.post("/{uuid}/ptz/move", status_code=status.HTTP_204_NO_CONTENT)
async def move_camera(
    uuid: UUID,
    payload: PtzMove,
    service: CameraService = Depends(get_camera_service),
) -> Response:
    await service.ptz_move(uuid, payload)
    return no_content()


@router.post("/{uuid}/ptz/stop", status_code=status.HTTP_204_NO_CONTENT)
async def stop_camera(uuid: UUID, service: CameraService = Depends(get_camera_service)) -> Response:
    await service.ptz_stop(uuid)
    return no_content()
