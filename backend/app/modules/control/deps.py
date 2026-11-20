"""FastAPI dependencies of the camera control module."""

from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.modules.control.services import CameraControlService
from app.tenancy.access import SiteAccess
from app.tenancy.dependencies import get_site_access


def get_control_service(
    session: AsyncSession = Depends(get_db),
    access: SiteAccess = Depends(get_site_access),
) -> CameraControlService:
    """Build the camera control service for a request.

    Args:
        session: Database session for the request.
        access: Access of the signed-in member to the request's site.

    Returns:
        Service bound to the session and the user.
    """
    return CameraControlService(session, access.user)
