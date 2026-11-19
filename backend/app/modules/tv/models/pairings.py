from datetime import datetime

from sqlalchemy import BigInteger, Boolean, DateTime, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel

__all__ = ["TvPairing"]


class TvPairing(BaseModel):
    __tablename__ = "tv_pairings"

    code: Mapped[str] = mapped_column(String(6), nullable=False, index=True)
    device_name: Mapped[str] = mapped_column(String(100), nullable=False)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)

    approved: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    device_id: Mapped[int | None] = mapped_column(
        BigInteger, ForeignKey("tv_devices.id", ondelete="SET NULL"), nullable=True
    )
