"""Route of the analytics service status."""

from fastapi import APIRouter, Depends

from app.modules.analytics.deps import get_status_service
from app.modules.analytics.schemas import AnalyticsStatus
from app.modules.analytics.services.status import AnalyticsStatusService

router = APIRouter()


@router.get("/status", response_model=AnalyticsStatus)
async def read_analytics_status(service: AnalyticsStatusService = Depends(get_status_service)) -> AnalyticsStatus:
    """Return the latest state the analytics service reported, with the views of the request's site only.

    Args:
        service: Status service limited to the site.

    Returns:
        The status.
    """
    return await service.read()
