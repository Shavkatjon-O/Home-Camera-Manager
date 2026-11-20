"""Camera registry endpoints."""

from uuid import UUID

from fastapi import APIRouter, Depends, Query, Response, status

from app.modules.cameras.deps import get_camera_service
from app.modules.cameras.enums import CameraSort
from app.modules.cameras.schemas import CameraCreate, CameraList, CameraOrder, CameraRead, CameraUpdate, PtzMove
from app.modules.cameras.services import CameraService
from app.tenancy.dependencies import require_admin, require_operator

router = APIRouter()

PAGE_SIZE_DEFAULT = 50
PAGE_SIZE_MAX = 200


def no_content() -> Response:
    """Build an empty 204 response.

    Returns:
        Response with the no content status.
    """
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.get("", response_model=CameraList)
async def list_cameras(
    page: int = Query(1, ge=1),
    page_size: int = Query(PAGE_SIZE_DEFAULT, ge=1, le=PAGE_SIZE_MAX),
    order: CameraSort = Query(CameraSort.CREATED),
    service: CameraService = Depends(get_camera_service),
) -> CameraList:
    """List cameras one page at a time.

    Args:
        page: Page number, starting at 1.
        page_size: Number of cameras per page.
        order: Order of the list.
        service: Camera service for the request.

    Returns:
        The requested page with the total camera count.
    """
    return await service.list_page(page, page_size, order)


@router.post("", dependencies=[Depends(require_admin)], response_model=CameraRead, status_code=status.HTTP_201_CREATED)
async def create_camera(payload: CameraCreate, service: CameraService = Depends(get_camera_service)) -> CameraRead:
    """Register a camera.

    Args:
        payload: Camera to register.
        service: Camera service for the request.

    Returns:
        The new camera.
    """
    return await service.create(payload)


@router.put("/order", dependencies=[Depends(require_admin)], status_code=status.HTTP_204_NO_CONTENT)
async def order_cameras(payload: CameraOrder, service: CameraService = Depends(get_camera_service)) -> Response:
    """Set the wall order of the cameras.

    Args:
        payload: Camera ids in the order they should appear.
        service: Camera service for the request.

    Returns:
        Empty response.
    """
    await service.reorder(payload.uuids)
    return no_content()


@router.get("/{uuid}", response_model=CameraRead)
async def get_camera(uuid: UUID, service: CameraService = Depends(get_camera_service)) -> CameraRead:
    """Return one camera.

    Args:
        uuid: Public id of the camera.
        service: Camera service for the request.

    Returns:
        The camera.
    """
    return await service.detail(uuid)


@router.patch("/{uuid}", dependencies=[Depends(require_admin)], response_model=CameraRead)
async def update_camera(
    uuid: UUID,
    payload: CameraUpdate,
    service: CameraService = Depends(get_camera_service),
) -> CameraRead:
    """Change the fields of a camera that the request sets.

    Args:
        uuid: Public id of the camera.
        payload: Fields to change.
        service: Camera service for the request.

    Returns:
        The updated camera.
    """
    return await service.update(uuid, payload)


@router.delete("/{uuid}", dependencies=[Depends(require_admin)], status_code=status.HTTP_204_NO_CONTENT)
async def delete_camera(uuid: UUID, service: CameraService = Depends(get_camera_service)) -> Response:
    """Remove a camera from the registry.

    Args:
        uuid: Public id of the camera.
        service: Camera service for the request.

    Returns:
        Empty response.
    """
    await service.delete(uuid)
    return no_content()


@router.post("/{uuid}/check", dependencies=[Depends(require_operator)], response_model=CameraRead)
async def check_camera(uuid: UUID, service: CameraService = Depends(get_camera_service)) -> CameraRead:
    """Probe a camera now and return it with the fresh status.

    Args:
        uuid: Public id of the camera.
        service: Camera service for the request.

    Returns:
        The camera with its status after the probe.
    """
    return await service.check(uuid)


@router.post("/{uuid}/ptz/move", dependencies=[Depends(require_operator)], status_code=status.HTTP_204_NO_CONTENT)
async def move_camera(
    uuid: UUID,
    payload: PtzMove,
    service: CameraService = Depends(get_camera_service),
) -> Response:
    """Start a continuous pan, tilt and zoom move.

    Args:
        uuid: Public id of the camera.
        payload: Speed on each axis.
        service: Camera service for the request.

    Returns:
        Empty response.
    """
    await service.ptz_move(uuid, payload)
    return no_content()


@router.post("/{uuid}/ptz/stop", dependencies=[Depends(require_operator)], status_code=status.HTTP_204_NO_CONTENT)
async def stop_camera(uuid: UUID, service: CameraService = Depends(get_camera_service)) -> Response:
    """Stop any pan, tilt and zoom move in progress.

    Args:
        uuid: Public id of the camera.
        service: Camera service for the request.

    Returns:
        Empty response.
    """
    await service.ptz_stop(uuid)
    return no_content()
