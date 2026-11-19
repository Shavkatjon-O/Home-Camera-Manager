from uuid import UUID

from sqlalchemy import Boolean, Integer, String, Text, Uuid
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel

__all__ = ["NetworkDevice"]


class NetworkDevice(BaseModel):
    __tablename__ = "network_devices"

    name: Mapped[str] = mapped_column(String(100), nullable=False)
    kind: Mapped[str] = mapped_column(String(20), nullable=False)

    host: Mapped[str] = mapped_column(String(255), nullable=False)
    probe_port: Mapped[int] = mapped_column(Integer, nullable=False, default=80, server_default="80")

    parent_uuid: Mapped[UUID | None] = mapped_column(Uuid(as_uuid=True), nullable=True)
    link: Mapped[str | None] = mapped_column(String(10), nullable=True)

    notes: Mapped[str | None] = mapped_column(Text, nullable=True)
    enabled: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
