"""Model of a TV pairing request."""

from datetime import datetime

from sqlalchemy import BigInteger, Boolean, DateTime, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel

__all__ = ["TvPairing"]


class TvPairing(BaseModel):
    """Pairing request that a TV opened and a signed-in user approves with its code.

    Attributes:
        code: Six-digit code shown on the TV.
        device_name: Name the TV asked to be paired under.
        expires_at: Time after which the request can no longer be approved.
        approved: Whether a user has approved the request.
        device_id: Database id of the device created on approval, if any.
    """

    __tablename__ = "tv_pairings"

    code: Mapped[str] = mapped_column(String(6), nullable=False, index=True)
    device_name: Mapped[str] = mapped_column(String(100), nullable=False)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)

    approved: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    device_id: Mapped[int | None] = mapped_column(
        BigInteger, ForeignKey("tv_devices.id", ondelete="SET NULL"), nullable=True
    )
