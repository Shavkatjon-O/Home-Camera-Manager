"""Route of the analytics service status."""

from fastapi import APIRouter, Depends

from app.analytics.observations import observations
from app.auth.context import UserContext
from app.auth.dependencies import get_current_user
from app.modules.analytics.schemas import AnalyticsStatus

router = APIRouter()


@router.get("/status", response_model=AnalyticsStatus)
async def read_status(user: UserContext = Depends(get_current_user)) -> AnalyticsStatus:
    """Return the latest state the analytics service reported.

    Args:
        user: Signed-in user.

    Returns:
        The status.
    """
    return AnalyticsStatus(
        pipeline=observations.pipeline,
        gpu=observations.gpu,
        updated_at=observations.updated_at,
        views=observations.views,
    )
