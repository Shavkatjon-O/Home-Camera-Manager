"""Camera link model."""

from uuid import UUID

from sqlalchemy import String, Uuid
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel

__all__ = ["CameraLink"]


class CameraLink(BaseModel):
    """Connection of a camera to the network device it hangs off.

    Attributes:
        camera_uuid: Public id of the camera, unique among links.
        parent_uuid: Public id of the network device the camera connects through.
        link: How the camera connects, a LinkKind value.
    """

    __tablename__ = "camera_links"

    camera_uuid: Mapped[UUID] = mapped_column(Uuid(as_uuid=True), unique=True, nullable=False)

    parent_uuid: Mapped[UUID] = mapped_column(Uuid(as_uuid=True), nullable=False)
    link: Mapped[str] = mapped_column(String(10), nullable=False)
