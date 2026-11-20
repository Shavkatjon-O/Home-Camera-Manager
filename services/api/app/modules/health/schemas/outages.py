"""Outage schemas."""

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel

from app.modules.health.enums import TargetKind

__all__ = ["OutageList", "OutageRead"]


class OutageRead(BaseModel):
    """Outage as returned by the API.

    Attributes:
        uuid: Public id.
        target_kind: Kind of the device or camera that was down.
        target_uuid: Public id of that target.
        target_name: Name of that target.
        started_at: Time of the first failed sample.
        ended_at: Time the target answered again, or None while the outage continues.
        ongoing: True while the outage is open.
        duration_seconds: Length of the outage so far, or in total once it has ended.
        failed_samples: Number of failed samples in the outage.
        upstream_uuid: Public id of the device whose outage caused this one, if any.
        upstream_name: Name of that device.
        created_at: When the outage was recorded.
        updated_at: When the record last changed.
    """

    uuid: UUID
    target_kind: TargetKind
    target_uuid: UUID
    target_name: str | None
    started_at: datetime
    ended_at: datetime | None
    ongoing: bool
    duration_seconds: float
    failed_samples: int
    upstream_uuid: UUID | None
    upstream_name: str | None
    created_at: datetime
    updated_at: datetime


class OutageList(BaseModel):
    """One page of outages.

    Attributes:
        items: Outages on the page.
        total: Number of outages in all pages.
        page: One-based page number.
        page_size: Outages per page.
    """

    items: list[OutageRead]
    total: int
    page: int
    page_size: int
