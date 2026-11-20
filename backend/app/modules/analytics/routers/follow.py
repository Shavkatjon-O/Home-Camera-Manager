"""Internal PTZ routes for the analytics service's auto-follow; nginx never proxies them."""

from uuid import UUID

from fastapi import APIRouter, Depends, Response, status

from app.modules.analytics.deps import get_follow_service
from app.modules.analytics.schemas.follow import PtzHomeIn, PtzMoveIn
from app.modules.analytics.services.follow import FollowPtzService

router = APIRouter()


@router.post("/ptz/{camera_uuid}/move", status_code=status.HTTP_204_NO_CONTENT)
async def move(
    camera_uuid: UUID, payload: PtzMoveIn, service: FollowPtzService = Depends(get_follow_service)
) -> Response:
    """Start a continuous move, or stop when both speeds are zero.

    Args:
        camera_uuid: Camera id.
        payload: Pan and tilt speeds.
        service: Follow PTZ service.

    Returns:
        Empty response.
    """
    await service.send(camera_uuid, payload.pan, payload.tilt)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post("/ptz/{camera_uuid}/stop", status_code=status.HTTP_204_NO_CONTENT)
async def stop(camera_uuid: UUID, service: FollowPtzService = Depends(get_follow_service)) -> Response:
    """Stop any move.

    Args:
        camera_uuid: Camera id.
        service: Follow PTZ service.

    Returns:
        Empty response.
    """
    await service.send(camera_uuid, 0.0, 0.0)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post("/ptz/{camera_uuid}/home", status_code=status.HTTP_204_NO_CONTENT)
async def home(
    camera_uuid: UUID, payload: PtzHomeIn, service: FollowPtzService = Depends(get_follow_service)
) -> Response:
    """Save the position follow starts from, or return to it.

    Args:
        camera_uuid: Camera id.
        payload: save or return.
        service: Follow PTZ service.

    Returns:
        Empty response; Conflict when the camera keeps no presets.
    """
    if payload.action == "save":
        await service.save_home(camera_uuid)
    else:
        await service.return_home(camera_uuid)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
