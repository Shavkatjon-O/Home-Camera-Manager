"""Network device endpoints."""

from uuid import UUID

from fastapi import APIRouter, Depends, Query, Response, status

from app.modules.health.deps import get_network_device_service
from app.modules.health.schemas import NetworkDeviceCreate, NetworkDeviceList, NetworkDeviceRead, NetworkDeviceUpdate
from app.modules.health.services import NetworkDeviceService

router = APIRouter()

PAGE_SIZE_DEFAULT = 50
PAGE_SIZE_MAX = 200


@router.get("", response_model=NetworkDeviceList)
async def list_devices(
    page: int = Query(1, ge=1),
    page_size: int = Query(PAGE_SIZE_DEFAULT, ge=1, le=PAGE_SIZE_MAX),
    service: NetworkDeviceService = Depends(get_network_device_service),
) -> NetworkDeviceList:
    """List network devices, newest first.

    Args:
        page: One-based page number.
        page_size: Devices per page.
        service: Network device service for the request.

    Returns:
        The requested page of devices.
    """
    return await service.list_page(page, page_size)


@router.post("", response_model=NetworkDeviceRead, status_code=status.HTTP_201_CREATED)
async def create_device(
    payload: NetworkDeviceCreate,
    service: NetworkDeviceService = Depends(get_network_device_service),
) -> NetworkDeviceRead:
    """Create a network device.

    Args:
        payload: Fields of the new device.
        service: Network device service for the request.

    Returns:
        The created device.
    """
    return await service.create(payload)


@router.get("/{uuid}", response_model=NetworkDeviceRead)
async def get_device(
    uuid: UUID, service: NetworkDeviceService = Depends(get_network_device_service)
) -> NetworkDeviceRead:
    """Return one network device.

    Args:
        uuid: Public id of the device.
        service: Network device service for the request.

    Returns:
        The device.
    """
    return await service.detail(uuid)


@router.patch("/{uuid}", response_model=NetworkDeviceRead)
async def update_device(
    uuid: UUID,
    payload: NetworkDeviceUpdate,
    service: NetworkDeviceService = Depends(get_network_device_service),
) -> NetworkDeviceRead:
    """Change fields of a network device.

    Args:
        uuid: Public id of the device.
        payload: Fields to change.
        service: Network device service for the request.

    Returns:
        The updated device.
    """
    return await service.update(uuid, payload)


@router.delete("/{uuid}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_device(uuid: UUID, service: NetworkDeviceService = Depends(get_network_device_service)) -> Response:
    """Delete a network device.

    Args:
        uuid: Public id of the device.
        service: Network device service for the request.

    Returns:
        An empty 204 response.
    """
    await service.delete(uuid)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
