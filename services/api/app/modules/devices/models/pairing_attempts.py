"""Database model of a pairing attempt, the telemetry that shows which pairing methods work."""

from datetime import datetime

from sqlalchemy import BigInteger, DateTime, ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel
from app.models.ownership import OrganisationOwned

__all__ = ["PairingAttempt"]


class PairingAttempt(OrganisationOwned, BaseModel):
    """One attempt to add a device or a connector with one method; it holds no personal data and no address.

    Attributes:
        site_id: Site the attempt was for, if any.
        method: Pairing method id.
        adapter: Adapter involved, if known.
        last_step: Last step reached, such as identify or create.
        outcome: started, succeeded, failed or abandoned.
        error_code: Stable error code of a failure.
        duration_ms: Time from start to the outcome.
        finished_at: When the outcome was reached.
    """

    __tablename__ = "pairing_attempts"

    site_id: Mapped[int | None] = mapped_column(BigInteger, ForeignKey("sites.id"), nullable=True, index=True)
    method: Mapped[str] = mapped_column(String(30), nullable=False, index=True)
    adapter: Mapped[str | None] = mapped_column(String(20), nullable=True)
    last_step: Mapped[str] = mapped_column(String(30), nullable=False)
    outcome: Mapped[str] = mapped_column(String(12), nullable=False)
    error_code: Mapped[str | None] = mapped_column(String(40), nullable=True)
    duration_ms: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    finished_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
