"""FastAPI dependencies of the events module."""

from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.modules.events.services import EventService
from app.tenancy.access import SiteAccess
from app.tenancy.dependencies import get_site_access


def get_event_service(
    session: AsyncSession = Depends(get_db),
    access: SiteAccess = Depends(get_site_access),
) -> EventService:
    """Build the event service for a signed-in request.

    Args:
        session: Request-scoped database session.
        access: Access of the signed-in member to the request's site.

    Returns:
        The service.
    """
    return EventService(session, access.user)
