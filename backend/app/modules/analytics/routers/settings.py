"""Routes of the global analytics settings."""

from fastapi import APIRouter, Depends

from app.modules.analytics.deps import get_settings_service
from app.modules.analytics.schemas import AnalyticsSettingsRead, AnalyticsSettingsUpdate
from app.modules.analytics.services import AnalyticsSettingsService

router = APIRouter()


@router.get("/settings", response_model=AnalyticsSettingsRead)
async def read_settings(service: AnalyticsSettingsService = Depends(get_settings_service)) -> AnalyticsSettingsRead:
    """Return the global analytics settings.

    Args:
        service: Settings service.

    Returns:
        The settings.
    """
    return await service.read()


@router.put("/settings", response_model=AnalyticsSettingsRead)
async def update_settings(
    data: AnalyticsSettingsUpdate,
    service: AnalyticsSettingsService = Depends(get_settings_service),
) -> AnalyticsSettingsRead:
    """Change the global analytics settings.

    Args:
        data: The new settings.
        service: Settings service.

    Returns:
        The settings after the change.
    """
    return await service.update(data)
