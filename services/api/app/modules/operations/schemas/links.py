"""Camera link schemas."""

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, model_validator

from app.modules.operations.enums import LinkKind

__all__ = ["CameraLinkRead", "CameraLinkUpdate"]


class CameraLinkUpdate(BaseModel):
    """New connection of a camera.

    Attributes:
        parent_uuid: Public id of the device the camera connects through, or null for no link.
        link: How the camera connects, set exactly when parent_uuid is.
    """

    parent_uuid: UUID | None
    link: LinkKind | None = None

    @model_validator(mode="after")
    def link_needs_parent(self):
        """Require the parent and the link kind to be given together.

        Returns:
            The validated update.

        Raises:
            ValueError: A parent is given without a link kind, or a link kind without a parent.
        """
        if self.parent_uuid is not None and self.link is None:
            raise ValueError("link is required when the camera connects through a device")
        if self.parent_uuid is None and self.link is not None:
            raise ValueError("link needs a device to connect through")
        return self


class CameraLinkRead(BaseModel):
    """Camera connection as returned by the API.

    Attributes:
        camera_uuid: Public id of the camera.
        parent_uuid: Public id of the device it connects through, or None when it has no link.
        parent_name: Name of that device.
        link: How the camera connects.
        updated_at: When the link last changed, or None when it has no link.
    """

    camera_uuid: UUID
    parent_uuid: UUID | None
    parent_name: str | None
    link: LinkKind | None
    updated_at: datetime | None
