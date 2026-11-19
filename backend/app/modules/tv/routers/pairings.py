from uuid import UUID

from fastapi import APIRouter, Depends, Request, status

from app.modules.tv.deps import get_pairing_admin_service, get_pairing_service
from app.modules.tv.schemas import PairingApprove, PairingCreate, PairingCreated, PairingStatus, TvDeviceRead
from app.modules.tv.services import TvPairingService

router = APIRouter()

UNKNOWN_CLIENT = "unknown"


def client_key(request: Request) -> str:
    return request.client.host if request.client else UNKNOWN_CLIENT


@router.post("/pairings", response_model=PairingCreated, status_code=status.HTTP_201_CREATED)
async def create_pairing(
    request: Request,
    payload: PairingCreate | None = None,
    service: TvPairingService = Depends(get_pairing_service),
) -> PairingCreated:
    return await service.create(payload or PairingCreate(), client_key(request))


@router.post("/pairings/approve", response_model=TvDeviceRead, status_code=status.HTTP_201_CREATED)
async def approve_pairing(
    payload: PairingApprove,
    service: TvPairingService = Depends(get_pairing_admin_service),
) -> TvDeviceRead:
    return await service.approve(payload.code)


@router.get("/pairings/{uuid}", response_model=PairingStatus, response_model_exclude_none=True)
async def pairing_status(uuid: UUID, service: TvPairingService = Depends(get_pairing_service)) -> PairingStatus:
    return await service.status(uuid)
