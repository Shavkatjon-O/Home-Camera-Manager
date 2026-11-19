"""Schema of the analytics service status."""

from datetime import datetime

from pydantic import BaseModel

__all__ = ["AnalyticsStatus"]


class AnalyticsStatus(BaseModel):
    """Latest state the analytics service reported.

    Attributes:
        pipeline: Pipeline state, None before the first report.
        gpu: GPU memory and utilisation.
        updated_at: Time of the report, None before the first one.
        views: Status per view id.
    """

    pipeline: dict | None
    gpu: dict
    updated_at: datetime | None
    views: dict[str, dict]
