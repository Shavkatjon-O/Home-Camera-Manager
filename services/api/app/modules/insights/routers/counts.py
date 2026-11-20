"""Routes of line counts and area occupancy."""

from datetime import datetime
from typing import Literal
from uuid import UUID

from fastapi import APIRouter, Depends, Query, Response, status

from app.modules.insights.deps import get_area_service, get_count_service
from app.modules.insights.schemas.counts import AreaCreate, AreaList, AreaRead, AreaReset, AreaUpdate, CountsRead
from app.modules.insights.services.counts import AreaService, CountService
from app.modules.operations.deps import audited
from app.modules.operations.enums import AuditAction
from app.modules.tenancy.deps import require_admin, require_operator

router = APIRouter()


@router.get("/counts", response_model=CountsRead, response_model_by_alias=True)
async def read_counts(
    start: datetime,
    end: datetime,
    bucket: Literal["hour", "day"] = Query("hour"),
    service: CountService = Depends(get_count_service),
) -> CountsRead:
    """Sum the crossings of every line over a range by hour or day.

    Args:
        start: Start of the range, inclusive, with its offset.
        end: End of the range, exclusive.
        bucket: hour or day.
        service: Count service.

    Returns:
        The lines, the non-empty buckets and the totals.
    """
    return await service.counts(start, end, bucket)


@router.get("/areas", response_model=AreaList)
async def list_areas(service: AreaService = Depends(get_area_service)) -> AreaList:
    """List every area with its occupancy.

    Args:
        service: Area service.

    Returns:
        The areas.
    """
    return await service.areas()


@router.post(
    "/areas",
    dependencies=[Depends(audited(AuditAction.RULES_UPDATE, "area")), Depends(require_admin)],
    response_model=AreaRead,
    status_code=status.HTTP_201_CREATED,
)
async def create_area(payload: AreaCreate, service: AreaService = Depends(get_area_service)) -> AreaRead:
    """Create an area bounded by counting lines.

    Args:
        payload: The area.
        service: Area service.

    Returns:
        The created area.
    """
    return await service.create(payload)


@router.patch(
    "/areas/{uuid}",
    dependencies=[Depends(audited(AuditAction.RULES_UPDATE, "area")), Depends(require_admin)],
    response_model=AreaRead,
)
async def update_area(uuid: UUID, payload: AreaUpdate, service: AreaService = Depends(get_area_service)) -> AreaRead:
    """Change an area.

    Args:
        uuid: Area id.
        payload: The changes.
        service: Area service.

    Returns:
        The area after the change.
    """
    return await service.update(uuid, payload)


@router.delete(
    "/areas/{uuid}",
    dependencies=[Depends(audited(AuditAction.RULES_UPDATE, "area")), Depends(require_admin)],
    status_code=status.HTTP_204_NO_CONTENT,
)
async def delete_area(uuid: UUID, service: AreaService = Depends(get_area_service)) -> Response:
    """Delete an area.

    Args:
        uuid: Area id.
        service: Area service.

    Returns:
        Empty response.
    """
    await service.delete(uuid)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post("/areas/{uuid}/reset", dependencies=[Depends(require_operator)], response_model=AreaRead)
async def reset_area(uuid: UUID, payload: AreaReset, service: AreaService = Depends(get_area_service)) -> AreaRead:
    """Set an area's occupancy now and count on from it.

    Args:
        uuid: Area id.
        payload: The occupancy now.
        service: Area service.

    Returns:
        The area after the change.
    """
    return await service.reset(uuid, payload)
