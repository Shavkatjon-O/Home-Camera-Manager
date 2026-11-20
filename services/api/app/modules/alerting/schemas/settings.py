"""Schemas of the analytics settings."""

from pydantic import BaseModel

from app.modules.analytics.enums import ArmMode

__all__ = ["AnalyticsSettingsRead", "AnalyticsSettingsUpdate"]


class AnalyticsSettingsRead(BaseModel):
    """Global analytics settings.

    Attributes:
        arm_mode: The arm mode.
    """

    arm_mode: ArmMode


class AnalyticsSettingsUpdate(BaseModel):
    """Change of the global analytics settings.

    Attributes:
        arm_mode: The new arm mode.
    """

    arm_mode: ArmMode
