"""Plan endpoints: the offered plans, an organisation's entitlements and its metered usage."""

from uuid import UUID

from fastapi import APIRouter, Depends, Query

from app.modules.billing.deps import get_plan_service
from app.modules.billing.schemas.plans import EntitlementsRead, PlanList, UsageRead
from app.modules.billing.services.plans import PlanService

router = APIRouter()


@router.get("/plans", response_model=PlanList)
async def list_plans(service: PlanService = Depends(get_plan_service)) -> PlanList:
    """List the plans offered to customers.

    Args:
        service: Plan service.

    Returns:
        The plans.
    """
    return await service.plans()


@router.get("/organisations/{organisation}/plan", response_model=EntitlementsRead)
async def get_organisation_plan(
    organisation: UUID, service: PlanService = Depends(get_plan_service)
) -> EntitlementsRead:
    """Return the organisation's plan, limits, features and current usage, for any member.

    Args:
        organisation: Public id of the organisation.
        service: Plan service.

    Returns:
        The entitlements.
    """
    return await service.entitlements(organisation)


@router.get("/organisations/{organisation}/usage", response_model=UsageRead)
async def get_organisation_usage(
    organisation: UUID,
    days: int = Query(7, ge=1, le=400),
    bucket: str = Query("day", pattern="^(hour|day)$"),
    service: PlanService = Depends(get_plan_service),
) -> UsageRead:
    """Sum the organisation's metered usage: camera-hours, view-hours, events, clip bytes and notifications.

    Admins and owners only.

    Args:
        organisation: Public id of the organisation.
        days: Length of the period in days.
        bucket: hour or day.
        service: Plan service.

    Returns:
        Totals and the series per bucket.
    """
    return await service.usage(organisation, days, bucket)
