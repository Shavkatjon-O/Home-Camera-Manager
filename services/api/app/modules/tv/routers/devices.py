"""Routes for listing and revoking paired TV devices."""

from uuid import UUID

from fastapi import APIRouter, Depends, Response, status

from app.modules.tenancy.deps import require_admin
from app.modules.tv.deps import get_device_service
from app.modules.tv.schemas import TvDeviceList
from app.modules.tv.services import TvDeviceService

router = APIRouter()


@router.get("/devices", dependencies=[Depends(require_admin)], response_model=TvDeviceList)
async def list_tv_devices(service: TvDeviceService = Depends(get_device_service)) -> TvDeviceList:
    """List the active paired TV devices.

    Args:
        service: Device service for the signed-in user.

    Returns:
        Active devices, newest first.
    """
    return await service.list_all()


@router.delete("/devices/{uuid}", dependencies=[Depends(require_admin)], status_code=status.HTTP_204_NO_CONTENT)
async def revoke_tv_device(uuid: UUID, service: TvDeviceService = Depends(get_device_service)) -> Response:
    """Revoke a paired TV device so its token stops working.

    Args:
        uuid: Public id of the device.
        service: Device service for the signed-in user.

    Returns:
        Empty response.
    """
    await service.revoke(uuid)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
