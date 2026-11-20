"""The global arm mode."""

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import AnalyticsSettings
from app.modules.analytics.enums import ArmMode
from app.modules.analytics.schemas import AnalyticsSettingsRead, AnalyticsSettingsUpdate

__all__ = ["AnalyticsSettingsService", "load_settings"]


async def load_settings(session: AsyncSession) -> AnalyticsSettings:
    """Return the settings row, creating it disarmed on first use.

    Args:
        session: Database session.

    Returns:
        The settings row.
    """
    row = await session.scalar(select(AnalyticsSettings).order_by(AnalyticsSettings.id).limit(1))
    if row is None:
        row = AnalyticsSettings(arm_mode=ArmMode.DISARMED.value)
        session.add(row)
        await session.flush()
    return row


class AnalyticsSettingsService:
    """Reads and changes the global analytics settings.

    Attributes:
        session: Database session.
    """

    def __init__(self, session: AsyncSession):
        """Bind the service to a session.

        Args:
            session: Database session.
        """
        self.session = session

    async def read(self) -> AnalyticsSettingsRead:
        """Return the settings.

        Returns:
            The settings.
        """
        row = await load_settings(self.session)
        await self.session.commit()
        return AnalyticsSettingsRead(arm_mode=ArmMode(row.arm_mode))

    async def update(self, data: AnalyticsSettingsUpdate) -> AnalyticsSettingsRead:
        """Change the settings.

        Args:
            data: The new settings.

        Returns:
            The settings after the change.
        """
        row = await load_settings(self.session)
        row.arm_mode = data.arm_mode.value
        await self.session.commit()
        return AnalyticsSettingsRead(arm_mode=data.arm_mode)
