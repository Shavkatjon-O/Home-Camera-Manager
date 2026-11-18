from uuid import UUID

from fastapi import APIRouter, Depends, Query, Response, status

from app.modules.floorplans.deps import get_floor_plan_service
from app.modules.floorplans.schemas import FloorPlanCreate, FloorPlanList, FloorPlanRead, FloorPlanUpdate
from app.modules.floorplans.services import FloorPlanService

router = APIRouter()

PAGE_SIZE_DEFAULT = 50
PAGE_SIZE_MAX = 200


@router.get("", response_model=FloorPlanList)
async def list_floor_plans(
    page: int = Query(1, ge=1),
    page_size: int = Query(PAGE_SIZE_DEFAULT, ge=1, le=PAGE_SIZE_MAX),
    service: FloorPlanService = Depends(get_floor_plan_service),
) -> FloorPlanList:
    return await service.list_page(page, page_size)


@router.post("", response_model=FloorPlanRead, status_code=status.HTTP_201_CREATED)
async def create_floor_plan(
    payload: FloorPlanCreate,
    service: FloorPlanService = Depends(get_floor_plan_service),
) -> FloorPlanRead:
    return await service.create(payload)


@router.get("/{uuid}", response_model=FloorPlanRead)
async def get_floor_plan(uuid: UUID, service: FloorPlanService = Depends(get_floor_plan_service)) -> FloorPlanRead:
    return await service.detail(uuid)


@router.patch("/{uuid}", response_model=FloorPlanRead)
async def update_floor_plan(
    uuid: UUID,
    payload: FloorPlanUpdate,
    service: FloorPlanService = Depends(get_floor_plan_service),
) -> FloorPlanRead:
    return await service.update(uuid, payload)


@router.delete("/{uuid}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_floor_plan(uuid: UUID, service: FloorPlanService = Depends(get_floor_plan_service)) -> Response:
    await service.delete(uuid)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
