from datetime import datetime
from uuid import UUID

from pydantic import BaseModel

from app.modules.health.enums import TargetKind

__all__ = ["OutageList", "OutageRead"]


class OutageRead(BaseModel):
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
    items: list[OutageRead]
    total: int
    page: int
    page_size: int
