from uuid import UUID

from fastapi import APIRouter, Depends, Query

from app.modules.health.deps import get_health_overview_service
from app.modules.health.enums import HealthRange
from app.modules.health.schemas import HealthOverview, TargetDetail
from app.modules.health.services import HealthOverviewService

router = APIRouter()


@router.get("/overview", response_model=HealthOverview)
async def health_overview(
    health_range: HealthRange = Query(HealthRange.HOUR, alias="range"),
    service: HealthOverviewService = Depends(get_health_overview_service),
) -> HealthOverview:
    return await service.overview(health_range)


@router.get("/targets/{uuid}", response_model=TargetDetail)
async def health_target(
    uuid: UUID,
    health_range: HealthRange = Query(HealthRange.HOUR, alias="range"),
    service: HealthOverviewService = Depends(get_health_overview_service),
) -> TargetDetail:
    return await service.target(uuid, health_range)
