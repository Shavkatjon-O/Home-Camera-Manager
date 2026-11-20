"""FastAPI dependencies of the tenancy module."""

from uuid import UUID

from fastapi import Depends, Header, Request
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.auth.dependencies import get_current_user, get_stream_user
from app.core.database import async_session_maker, get_db
from app.modules.tenancy.enums import Role
from app.modules.tenancy.services import InvitationService, MemberService, OrganisationService, SiteService
from app.modules.tenancy.services.access import SiteAccess, check_role, resolve_site_access
from app.modules.tenancy.services.scope import Scope, install_scope


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


SITE_HEADER = "X-Site"
SITE_QUERY = "site"
SITE_COOKIE = "sss_site"


def parse_uuid(value: str | None) -> UUID | None:
    """Read a UUID from text.

    Args:
        value: Text, if any.

    Returns:
        The UUID, or None when the text is missing or not a UUID.
    """
    if not value:
        return None
    try:
        return UUID(value)
    except ValueError:
        return None


def requested_site(request: Request, header: UUID | None) -> tuple[UUID | None, bool]:
    """Find the site a request names.

    The X-Site header comes first, then the site query parameter, which serves clients that cannot set headers,
    then the web app's site cookie.

    Args:
        request: The request.
        header: Value of the X-Site header, if sent.

    Returns:
        The site and whether it was named explicitly, so that an unreachable cookie site falls back to the
        user's first site instead of failing.
    """
    if header is not None:
        return header, True
    query = parse_uuid(request.query_params.get(SITE_QUERY))
    if query is not None:
        return query, True
    return parse_uuid(request.cookies.get(SITE_COOKIE)), False


def site_scope(access: SiteAccess) -> Scope:
    """Build the row scope of a site access.

    Args:
        access: The access.

    Returns:
        A scope over the one site and its organisation.
    """
    return Scope(organisation_id=access.organisation_id, site_ids=frozenset({access.site_id}), site_id=access.site_id)


async def get_site_access(
    request: Request,
    x_site: UUID | None = Header(
        None,
        alias=SITE_HEADER,
        description="Site the request acts on; the member's first site when omitted.",
    ),
    user: UserContext = Depends(get_current_user),
    session: AsyncSession = Depends(get_db),
) -> SiteAccess:
    """Require a member of the site a request acts on and limit the request's session to that site.

    Args:
        request: The request.
        x_site: Site from the X-Site header, if sent.
        user: Signed-in user.
        session: Request-scoped database session.

    Returns:
        The access; every query of the session is limited to the site from now on.
    """
    site_uuid, strict = requested_site(request, x_site)
    access = await resolve_site_access(session, user, site_uuid, strict=strict)
    install_scope(session, site_scope(access))
    return access


async def require_operator(access: SiteAccess = Depends(get_site_access)) -> SiteAccess:
    """Require an operator, admin or owner of the site.

    Args:
        access: The access.

    Returns:
        The access.
    """
    check_role(access.role, Role.OPERATOR)
    return access


async def require_admin(access: SiteAccess = Depends(get_site_access)) -> SiteAccess:
    """Require an admin or owner of the site.

    Args:
        access: The access.

    Returns:
        The access.
    """
    check_role(access.role, Role.ADMIN)
    return access


async def require_owner(access: SiteAccess = Depends(get_site_access)) -> SiteAccess:
    """Require the owner of the site's organisation.

    Args:
        access: The access.

    Returns:
        The access.
    """
    check_role(access.role, Role.OWNER)
    return access


async def get_stream_site_access(
    request: Request,
    x_site: UUID | None = Header(
        None,
        alias=SITE_HEADER,
        description="Site the request acts on; the member's first site when omitted.",
    ),
    user: UserContext = Depends(get_stream_user),
) -> SiteAccess:
    """Require a member of a site for a long-lived streaming response, checked in a short session of its own.

    Args:
        request: The request.
        x_site: Site from the X-Site header, if sent.
        user: Signed-in user.

    Returns:
        The access.
    """
    site_uuid, strict = requested_site(request, x_site)
    async with async_session_maker() as session:
        return await resolve_site_access(session, user, site_uuid, strict=strict)
