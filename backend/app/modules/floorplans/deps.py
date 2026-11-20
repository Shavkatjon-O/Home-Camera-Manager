"""FastAPI dependencies of the floor plan module."""

from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.modules.floorplans.services import FloorPlanService
from app.tenancy.access import SiteAccess
from app.tenancy.dependencies import get_site_access


def get_floor_plan_service(
    session: AsyncSession = Depends(get_db),
    access: SiteAccess = Depends(get_site_access),
) -> FloorPlanService:
    """Build the floor plan service for a signed-in user.

    Args:
        session: Database session for the request.
        access: Access of the signed-in member to the request's site.

    Returns:
        Floor plan service acting for the user.
    """
    return FloorPlanService(session, access.user)
