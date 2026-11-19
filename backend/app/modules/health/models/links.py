from uuid import UUID

from sqlalchemy import String, Uuid
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel

__all__ = ["CameraLink"]


class CameraLink(BaseModel):
    __tablename__ = "camera_links"

    camera_uuid: Mapped[UUID] = mapped_column(Uuid(as_uuid=True), unique=True, nullable=False)

    parent_uuid: Mapped[UUID] = mapped_column(Uuid(as_uuid=True), nullable=False)
    link: Mapped[str] = mapped_column(String(10), nullable=False)
