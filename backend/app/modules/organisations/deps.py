"""FastAPI dependencies of the organisations module."""

from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.auth.dependencies import get_current_user
from app.core.database import get_db
from app.modules.organisations.services import InvitationService, MemberService, OrganisationService, SiteService


def get_organisation_service(
    session: AsyncSession = Depends(get_db), actor: UserContext = Depends(get_current_user)
) -> OrganisationService:
    """Build the organisation service for a signed-in request.

    Args:
        session: Request-scoped database session.
        actor: Signed-in user.

    Returns:
        The service.
    """
    return OrganisationService(session, actor)


def get_site_service(
    session: AsyncSession = Depends(get_db), actor: UserContext = Depends(get_current_user)
) -> SiteService:
    """Build the site service for a signed-in request.

    Args:
        session: Request-scoped database session.
        actor: Signed-in user.

    Returns:
        The service.
    """
    return SiteService(session, actor)


def get_member_service(
    session: AsyncSession = Depends(get_db), actor: UserContext = Depends(get_current_user)
) -> MemberService:
    """Build the member service for a signed-in request.

    Args:
        session: Request-scoped database session.
        actor: Signed-in user.

    Returns:
        The service.
    """
    return MemberService(session, actor)


def get_invitation_service(
    session: AsyncSession = Depends(get_db), actor: UserContext = Depends(get_current_user)
) -> InvitationService:
    """Build the invitation service for a signed-in request.

    Args:
        session: Request-scoped database session.
        actor: Signed-in user.

    Returns:
        The service.
    """
    return InvitationService(session, actor)


def get_public_invitation_service(session: AsyncSession = Depends(get_db)) -> InvitationService:
    """Build the invitation service for a request that is not signed in, such as an invitation preview.

    Args:
        session: Request-scoped database session.

    Returns:
        The service.
    """
    return InvitationService(session)
