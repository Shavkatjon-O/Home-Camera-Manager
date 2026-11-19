from uuid import UUID

from fastapi import APIRouter, Depends, Response, status

from app.modules.tv.deps import get_device_service
from app.modules.tv.schemas import TvDeviceList
from app.modules.tv.services import TvDeviceService

router = APIRouter()


@router.get("/devices", response_model=TvDeviceList)
async def list_devices(service: TvDeviceService = Depends(get_device_service)) -> TvDeviceList:
    return await service.list_all()


@router.delete("/devices/{uuid}", status_code=status.HTTP_204_NO_CONTENT)
async def revoke_device(uuid: UUID, service: TvDeviceService = Depends(get_device_service)) -> Response:
    await service.revoke(uuid)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
