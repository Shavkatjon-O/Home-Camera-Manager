"""Routes of the TV pairing flow."""

from uuid import UUID

from fastapi import APIRouter, Depends, Request, status

from app.modules.tv.deps import get_pairing_admin_service, get_pairing_service
from app.modules.tv.schemas import PairingApprove, PairingCreate, PairingCreated, PairingStatus, TvDeviceRead
from app.modules.tv.services import TvPairingService

router = APIRouter()

UNKNOWN_CLIENT = "unknown"


def client_key(request: Request) -> str:
    """Identify the client of a request for rate limiting.

    Args:
        request: Incoming request.

    Returns:
        Client IP address, or a fixed placeholder when it is unknown.
    """
    return request.client.host if request.client else UNKNOWN_CLIENT


@router.post("/pairings", response_model=PairingCreated, status_code=status.HTTP_201_CREATED)
async def create_pairing(
    request: Request,
    payload: PairingCreate | None = None,
    service: TvPairingService = Depends(get_pairing_service),
) -> PairingCreated:
    """Open a pairing for a TV that has no token yet.

    Args:
        request: Incoming request, used to rate limit by client address.
        payload: Device name the TV asks for; the default name is used when the body is empty.
        service: Pairing service without an acting user.

    Returns:
        Pairing id to poll and the code to show on the TV.
    """
    return await service.create(payload or PairingCreate(), client_key(request))


@router.post("/pairings/approve", response_model=TvDeviceRead, status_code=status.HTTP_201_CREATED)
async def approve_pairing(
    payload: PairingApprove,
    service: TvPairingService = Depends(get_pairing_admin_service),
) -> TvDeviceRead:
    """Approve the TV that shows a code and create its device.

    Args:
        payload: Code shown on the TV.
        service: Pairing service for the signed-in user.

    Returns:
        The newly paired device.
    """
    return await service.approve(payload.code)


@router.get("/pairings/{uuid}", response_model=PairingStatus, response_model_exclude_none=True)
async def pairing_status(uuid: UUID, service: TvPairingService = Depends(get_pairing_service)) -> PairingStatus:
    """Report the status of a pairing, handing over the device token once it is approved.

    Args:
        uuid: Pairing id returned when it was opened.
        service: Pairing service without an acting user.

    Returns:
        Pairing status, with the device token in the response that hands it over.
    """
    return await service.status(uuid)
