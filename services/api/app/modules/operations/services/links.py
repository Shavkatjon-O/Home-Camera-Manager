"""Camera link service."""

from uuid import UUID

from sqlalchemy import func, select

from app.core.base_service import BaseModelService
from app.core.exceptions import NotFound, Unprocessable
from app.models import Camera, CameraLink, NetworkDevice
from app.modules.health.enums import LinkKind
from app.modules.health.schemas import CameraLinkRead, CameraLinkUpdate

__all__ = ["CameraLinkService"]


class CameraLinkService(BaseModelService[CameraLink]):
    """Set and clear the device each camera connects through.

    Attributes:
        model: Camera links.
        not_found_code: Error code of an unknown link.
    """

    model = CameraLink
    not_found_code = "camera_link_not_found"

    async def put(self, camera_uuid: UUID, payload: CameraLinkUpdate) -> CameraLinkRead:
        """Set a camera's link, or clear it when no parent or link kind is given.

        Clearing soft-deletes the stored link. Setting a link on a camera that had a cleared one revives the row.

        Args:
            camera_uuid: Public id of the camera.
            payload: New parent device and link kind.

        Returns:
            The camera's link after the change.

        Raises:
            NotFound: The camera does not exist.
            Unprocessable: The parent device does not exist.
        """
        camera = await self.session.scalar(
            select(Camera.id).where(Camera.uuid == camera_uuid, Camera.deleted_at.is_(None))
        )
        if camera is None:
            raise NotFound("camera_not_found", f"Camera {camera_uuid} does not exist")
        parent_name = None
        if payload.parent_uuid is not None:
            parent_name = await self.session.scalar(
                select(NetworkDevice.name).where(
                    NetworkDevice.uuid == payload.parent_uuid, NetworkDevice.deleted_at.is_(None)
                )
            )
            if parent_name is None:
                raise Unprocessable("parent_not_found", f"Network device {payload.parent_uuid} does not exist")
        link = await self.session.scalar(select(CameraLink).where(CameraLink.camera_uuid == camera_uuid))
        if payload.parent_uuid is None or payload.link is None:
            if link is not None and link.deleted_at is None:
                link.deleted_at = func.now()
                await self.commit()
            return CameraLinkRead(
                camera_uuid=camera_uuid, parent_uuid=None, parent_name=None, link=None, updated_at=None
            )
        if link is None:
            link = CameraLink(camera_uuid=camera_uuid, parent_uuid=payload.parent_uuid, link=payload.link.value)
            self.session.add(link)
        else:
            link.parent_uuid = payload.parent_uuid
            link.link = payload.link.value
            link.deleted_at = None
        await self.commit()
        await self.session.refresh(link)
        return CameraLinkRead(
            camera_uuid=camera_uuid,
            parent_uuid=link.parent_uuid,
            parent_name=parent_name,
            link=LinkKind(link.link),
            updated_at=link.updated_at,
        )
