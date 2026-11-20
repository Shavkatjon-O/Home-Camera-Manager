"""Routes of the analytics views, their rules, live objects and fresh pictures."""

from uuid import UUID

from fastapi import APIRouter, Depends, Query
from fastapi.responses import Response

from app.analytics import client
from app.modules.analytics.deps import get_view_service
from app.modules.analytics.schemas import RulesUpdate, ViewList, ViewRead, ViewUpdate
from app.modules.analytics.services import AnalyticsViewService

router = APIRouter()


@router.get("/views", response_model=ViewList)
async def list_views(
    camera_uuid: UUID | None = Query(None),
    service: AnalyticsViewService = Depends(get_view_service),
) -> ViewList:
    """List analytics views, creating the missing ones.

    Args:
        camera_uuid: Only the views of this camera.
        service: View service.

    Returns:
        The views.
    """
    return await service.list(camera_uuid)


@router.patch("/views/{uuid}", response_model=ViewRead)
async def update_view(
    uuid: UUID,
    data: ViewUpdate,
    service: AnalyticsViewService = Depends(get_view_service),
) -> ViewRead:
    """Change a view.

    Args:
        uuid: View id.
        data: The changes.
        service: View service.

    Returns:
        The view.
    """
    return await service.update(uuid, data)


@router.put("/views/{uuid}/rules", response_model=ViewRead)
async def replace_rules(
    uuid: UUID,
    data: RulesUpdate,
    service: AnalyticsViewService = Depends(get_view_service),
) -> ViewRead:
    """Replace every zone and line of a view.

    Args:
        uuid: View id.
        data: The zones and lines.
        service: View service.

    Returns:
        The view.
    """
    return await service.replace_rules(uuid, data)


@router.get("/views/{uuid}/snapshot")
async def view_snapshot(
    uuid: UUID,
    reference: bool = Query(False),
    service: AnalyticsViewService = Depends(get_view_service),
) -> Response:
    """Return a fresh picture of a view, optionally kept as a zone reference.

    Args:
        uuid: View id.
        reference: Keep the picture as the reference of zones drawn on it.
        service: View service.

    Returns:
        The JPEG, with the X-Reference header when it was kept.
    """
    await service.get(uuid)
    data, kept = await client.snapshot(str(uuid), reference)
    headers = {"Cache-Control": "no-store"}
    if kept:
        headers["X-Reference"] = kept
    return Response(content=data, media_type="image/jpeg", headers=headers)


@router.get("/views/{uuid}/objects")
async def view_objects(uuid: UUID, service: AnalyticsViewService = Depends(get_view_service)) -> dict:
    """Return the tracked objects of a view's latest frame.

    Args:
        uuid: View id.
        service: View service.

    Returns:
        The view id, the frame time and the objects.
    """
    await service.get(uuid)
    return await client.live_objects(str(uuid))
