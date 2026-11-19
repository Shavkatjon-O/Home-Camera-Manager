from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, model_validator

from app.modules.health.enums import LinkKind

__all__ = ["CameraLinkRead", "CameraLinkUpdate"]


class CameraLinkUpdate(BaseModel):
    parent_uuid: UUID | None
    link: LinkKind | None = None

    @model_validator(mode="after")
    def link_needs_parent(self):
        if self.parent_uuid is not None and self.link is None:
            raise ValueError("link is required when the camera connects through a device")
        if self.parent_uuid is None and self.link is not None:
            raise ValueError("link needs a device to connect through")
        return self


class CameraLinkRead(BaseModel):
    camera_uuid: UUID
    parent_uuid: UUID | None
    parent_name: str | None
    link: LinkKind | None
    updated_at: datetime | None
