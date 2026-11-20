"""Device endpoints: cameras, NVRs and DVRs with their channels."""

from uuid import UUID

from fastapi import APIRouter, Depends

from app.modules.devices.deps import get_device_service
from app.modules.devices.schemas.devices import DeviceList, DeviceRead
from app.modules.devices.services.devices import DeviceService

router = APIRouter()


@router.get("", response_model=DeviceList)
async def list_devices(service: DeviceService = Depends(get_device_service)) -> DeviceList:
    """List the devices of the site with the channels added as cameras.

    Args:
        service: Device service.

    Returns:
        The devices.
    """
    return await service.list()


@router.get("/{uuid}", response_model=DeviceRead)
async def get_device(uuid: UUID, service: DeviceService = Depends(get_device_service)) -> DeviceRead:
    """Return one device of the site.

    Args:
        uuid: Public id.
        service: Device service.

    Returns:
        The device.
    """
    return await service.read(uuid)
