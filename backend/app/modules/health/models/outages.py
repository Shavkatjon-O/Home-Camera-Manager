from datetime import datetime
from uuid import UUID

from sqlalchemy import DateTime, Integer, String, Uuid
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel

__all__ = ["Outage"]


class Outage(BaseModel):
    __tablename__ = "outages"

    target_kind: Mapped[str] = mapped_column(String(10), nullable=False)
    target_uuid: Mapped[UUID] = mapped_column(Uuid(as_uuid=True), nullable=False, index=True)

    started_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    ended_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    failed_samples: Mapped[int] = mapped_column(Integer, nullable=False, default=0)

    upstream_uuid: Mapped[UUID | None] = mapped_column(Uuid(as_uuid=True), nullable=True)
