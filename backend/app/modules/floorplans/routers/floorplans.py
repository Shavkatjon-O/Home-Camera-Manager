"""Routes for floor plans."""

from uuid import UUID

from fastapi import APIRouter, Depends, Query, Response, status

from app.modules.floorplans.deps import get_floor_plan_service
from app.modules.floorplans.schemas import FloorPlanCreate, FloorPlanList, FloorPlanRead, FloorPlanUpdate
from app.modules.floorplans.services import FloorPlanService
from app.tenancy.dependencies import require_admin

router = APIRouter()

PAGE_SIZE_DEFAULT = 50
PAGE_SIZE_MAX = 200


@router.get("", response_model=FloorPlanList)
async def list_floor_plans(
    page: int = Query(1, ge=1),
    page_size: int = Query(PAGE_SIZE_DEFAULT, ge=1, le=PAGE_SIZE_MAX),
    service: FloorPlanService = Depends(get_floor_plan_service),
) -> FloorPlanList:
    """List floor plans, newest first.

    Args:
        page: One-based page number.
        page_size: Number of plans per page.
        service: Floor plan service for the signed-in user.

    Returns:
        One page of plan summaries with the total count.
    """
    return await service.list_page(page, page_size)


@router.post(
    "", dependencies=[Depends(require_admin)], response_model=FloorPlanRead, status_code=status.HTTP_201_CREATED
)
async def create_floor_plan(
    payload: FloorPlanCreate,
    service: FloorPlanService = Depends(get_floor_plan_service),
) -> FloorPlanRead:
    """Create a floor plan.

    Args:
        payload: Plan to create.
        service: Floor plan service for the signed-in user.

    Returns:
        The created plan.
    """
    return await service.create(payload)


@router.get("/{uuid}", response_model=FloorPlanRead)
async def get_floor_plan(uuid: UUID, service: FloorPlanService = Depends(get_floor_plan_service)) -> FloorPlanRead:
    """Return one floor plan with its background image.

    Args:
        uuid: Public id of the plan.
        service: Floor plan service for the signed-in user.

    Returns:
        The plan.
    """
    return await service.detail(uuid)


@router.patch("/{uuid}", dependencies=[Depends(require_admin)], response_model=FloorPlanRead)
async def update_floor_plan(
    uuid: UUID,
    payload: FloorPlanUpdate,
    service: FloorPlanService = Depends(get_floor_plan_service),
) -> FloorPlanRead:
    """Change the given fields of a floor plan.

    Args:
        uuid: Public id of the plan.
        payload: Fields to change.
        service: Floor plan service for the signed-in user.

    Returns:
        The updated plan.
    """
    return await service.update(uuid, payload)


@router.delete("/{uuid}", dependencies=[Depends(require_admin)], status_code=status.HTTP_204_NO_CONTENT)
async def delete_floor_plan(uuid: UUID, service: FloorPlanService = Depends(get_floor_plan_service)) -> Response:
    """Delete a floor plan.

    Args:
        uuid: Public id of the plan.
        service: Floor plan service for the signed-in user.

    Returns:
        Empty response.
    """
    await service.delete(uuid)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
