"""Push target endpoints of the apps."""

from uuid import UUID

from fastapi import APIRouter, Depends, Response, status

from app.modules.alerting.deps import get_push_service
from app.modules.alerting.schemas import PushProviders, PushTargetCreate, PushTargetList, PushTargetRead, PushTestResult
from app.modules.alerting.services import PushTargetService

router = APIRouter()


@router.get("/providers", response_model=PushProviders)
async def list_push_providers(service: PushTargetService = Depends(get_push_service)) -> PushProviders:
    """Tell which push services this backend delivers through.

    Args:
        service: Push target service.

    Returns:
        The providers that are set up.
    """
    return service.info()


@router.get("/targets", response_model=PushTargetList)
async def list_push_targets(service: PushTargetService = Depends(get_push_service)) -> PushTargetList:
    """List the push targets of the current app session.

    Args:
        service: Push target service.

    Returns:
        The targets.
    """
    return await service.list()


@router.post("/targets", response_model=PushTargetRead, status_code=status.HTTP_201_CREATED)
async def register_push_target(
    payload: PushTargetCreate, service: PushTargetService = Depends(get_push_service)
) -> PushTargetRead:
    """Receive alert pushes on the device of the current app session.

    Args:
        payload: Provider and token.
        service: Push target service.

    Returns:
        The target.
    """
    return await service.register(payload)


@router.delete("/targets/{uuid}", status_code=status.HTTP_204_NO_CONTENT, response_class=Response)
async def delete_push_target(uuid: UUID, service: PushTargetService = Depends(get_push_service)) -> Response:
    """Stop pushes to a target of the current app session.

    Args:
        uuid: Public id of the target.
        service: Push target service.

    Returns:
        Empty response.
    """
    await service.delete(uuid)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post("/test", response_model=PushTestResult)
async def send_test_push(service: PushTargetService = Depends(get_push_service)) -> PushTestResult:
    """Send a test push to the current app session's targets.

    Args:
        service: Push target service.

    Returns:
        How many arrived at their provider.
    """
    return await service.test()
