"""Outage model."""

from datetime import datetime
from uuid import UUID

from sqlalchemy import DateTime, Integer, String, Uuid
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel
from app.models.ownership import SiteOwned

__all__ = ["Outage"]


class Outage(SiteOwned, BaseModel):
    """Period in which a device or camera did not answer probes.

    Attributes:
        target_kind: Kind of the target, a TargetKind value.
        target_uuid: Public id of the device or camera that was down.
        started_at: Time of the first failed sample.
        ended_at: Time the target answered again, or None while the outage continues.
        failed_samples: Number of failed samples in the outage.
        upstream_uuid: Public id of the device whose outage caused this one, if one was found.
    """

    __tablename__ = "outages"

    target_kind: Mapped[str] = mapped_column(String(10), nullable=False)
    target_uuid: Mapped[UUID] = mapped_column(Uuid(as_uuid=True), nullable=False, index=True)

    started_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    ended_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    failed_samples: Mapped[int] = mapped_column(Integer, nullable=False, default=0)

    upstream_uuid: Mapped[UUID | None] = mapped_column(Uuid(as_uuid=True), nullable=True)
