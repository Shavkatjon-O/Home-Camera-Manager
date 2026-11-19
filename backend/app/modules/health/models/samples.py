from uuid import UUID

from sqlalchemy import Boolean, Double, Index, String, Uuid
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel

__all__ = ["HealthSample"]


class HealthSample(BaseModel):
    __tablename__ = "health_samples"
    __table_args__ = (Index("ix_health_samples_target_uuid_created_at", "target_uuid", "created_at"),)

    target_kind: Mapped[str] = mapped_column(String(10), nullable=False)
    target_uuid: Mapped[UUID] = mapped_column(Uuid(as_uuid=True), nullable=False)

    ok: Mapped[bool] = mapped_column(Boolean, nullable=False)
    latency_ms: Mapped[float | None] = mapped_column(Double, nullable=True)
    error: Mapped[str | None] = mapped_column(String(100), nullable=True)
