"""Routes of the global analytics settings."""

from fastapi import APIRouter, Depends

from app.modules.alerting.deps import get_settings_service
from app.modules.alerting.schemas import AnalyticsSettingsRead, AnalyticsSettingsUpdate
from app.modules.alerting.services import AnalyticsSettingsService
from app.modules.operations.deps import audited
from app.modules.operations.enums import AuditAction
from app.modules.tenancy.deps import require_operator

router = APIRouter()


@router.get("/settings", response_model=AnalyticsSettingsRead)
async def read_analytics_settings(
    service: AnalyticsSettingsService = Depends(get_settings_service),
) -> AnalyticsSettingsRead:
    """Return the global analytics settings.

    Args:
        service: Settings service.

    Returns:
        The settings.
    """
    return await service.read()


@router.put(
    "/settings",
    dependencies=[Depends(audited(AuditAction.ARM_MODE_CHANGE, "site")), Depends(require_operator)],
    response_model=AnalyticsSettingsRead,
)
async def update_analytics_settings(
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
