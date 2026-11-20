"""Health overview endpoints."""

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
    """Return the health of every device and camera over a time range.

    Args:
        health_range: Time range to cover, passed as the range query parameter.
        service: Health overview service for the request.

    Returns:
        The overview with one entry per target.
    """
    return await service.overview(health_range)


@router.get("/targets/{uuid}", response_model=TargetDetail)
async def health_target(
    uuid: UUID,
    health_range: HealthRange = Query(HealthRange.HOUR, alias="range"),
    service: HealthOverviewService = Depends(get_health_overview_service),
) -> TargetDetail:
    """Return the health of one device or camera over a time range, with finer buckets.

    Args:
        uuid: Public id of the device or camera.
        health_range: Time range to cover, passed as the range query parameter.
        service: Health overview service for the request.

    Returns:
        The target's health detail.
    """
    return await service.target(uuid, health_range)
