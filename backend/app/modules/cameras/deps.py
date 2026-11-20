"""FastAPI dependencies of the camera registry module."""

from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.modules.cameras.services import CameraService
from app.tenancy.access import SiteAccess
from app.tenancy.dependencies import get_site_access


def get_camera_service(
    session: AsyncSession = Depends(get_db),
    access: SiteAccess = Depends(get_site_access),
) -> CameraService:
    """Build the camera service for a signed-in request.

    Args:
        session: Request-scoped database session.
        access: Access of the signed-in member to the request's site.

    Returns:
        Camera service bound to the session and the user.
    """
    return CameraService(session, access.user)
