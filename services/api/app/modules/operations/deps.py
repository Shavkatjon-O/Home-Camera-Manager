"""FastAPI dependencies of the operations module: its services and the audit hook routes declare."""

from collections.abc import AsyncIterator, Callable
from uuid import UUID

from fastapi import Depends, Request
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.core.database import get_db
from app.modules.identity.deps import get_current_user, require_platform_admin
from app.modules.operations.enums import AuditAction
from app.modules.operations.services import (
    AdminService,
    AuditService,
    CameraLinkService,
    FloorPlanService,
    HealthOverviewService,
    NetworkDeviceService,
    OutageService,
    write_audit,
)
from app.modules.tenancy.deps import get_site_access
from app.modules.tenancy.services.access import SiteAccess


def get_network_device_service(
    session: AsyncSession = Depends(get_db),
    access: SiteAccess = Depends(get_site_access),
) -> NetworkDeviceService:
    """Build the network device service for a request.

    Args:
        session: Request-scoped database session.
        access: Access of the signed-in member to the request's site.

    Returns:
        The service bound to the session and user.
    """
    return NetworkDeviceService(session, access.user)


def get_camera_link_service(
    session: AsyncSession = Depends(get_db),
    access: SiteAccess = Depends(get_site_access),
) -> CameraLinkService:
    """Build the camera link service for a request.

    Args:
        session: Request-scoped database session.
        access: Access of the signed-in member to the request's site.

    Returns:
        The service bound to the session and user.
    """
    return CameraLinkService(session, access.user)


def get_health_overview_service(
    session: AsyncSession = Depends(get_db),
    access: SiteAccess = Depends(get_site_access),
) -> HealthOverviewService:
    """Build the health overview service for a request.

    Args:
        session: Request-scoped database session.
        access: Access of the signed-in member to the request's site.

    Returns:
        The service bound to the session and user.
    """
    return HealthOverviewService(session, access.user)


def get_outage_service(
    session: AsyncSession = Depends(get_db),
    access: SiteAccess = Depends(get_site_access),
) -> OutageService:
    """Build the outage service for a request.

    Args:
        session: Request-scoped database session.
        access: Access of the signed-in member to the request's site.

    Returns:
        The service bound to the session and user.
    """
    return OutageService(session, access.user)


def get_floor_plan_service(
    session: AsyncSession = Depends(get_db),
    access: SiteAccess = Depends(get_site_access),
) -> FloorPlanService:
    """Build the floor plan service for a signed-in user.

    Args:
        session: Database session for the request.
        access: Access of the signed-in member to the request's site.

    Returns:
        Floor plan service acting for the user.
    """
    return FloorPlanService(session, access.user)


def get_admin_service(
    request: Request,
    session: AsyncSession = Depends(get_db),
    actor: UserContext = Depends(require_platform_admin),
) -> AdminService:
    """Build the platform administration service for a platform admin.

    Args:
        request: The request.
        session: Request-scoped database session.
        actor: The platform admin.

    Returns:
        The service.
    """
    return AdminService(session, actor, client_address(request))


def get_audit_service(
    session: AsyncSession = Depends(get_db), actor: UserContext = Depends(get_current_user)
) -> AuditService:
    """Build the audit log service for a signed-in request.

    Args:
        session: Request-scoped database session.
        actor: Signed-in user.

    Returns:
        The service.
    """
    return AuditService(session, actor)


def client_address(request: Request) -> str | None:
    """Return the address a request came from.

    Args:
        request: The request.

    Returns:
        The address, if known.
    """
    return request.client.host if request.client else None


def path_uuid(request: Request, name: str | None) -> UUID | None:
    """Read a public id from the request path.

    Args:
        request: The request.
        name: Name of the path parameter, None for none.

    Returns:
        The id, None when the path has no such parameter or it is not an id.
    """
    value = request.path_params.get(name) if name else None
    try:
        return UUID(str(value)) if value is not None else None
    except ValueError:
        return None


def audited(action: AuditAction, target_kind: str | None = None, target: str = "uuid") -> Callable:
    """Build a dependency that records an action of a site after the route succeeded.

    The record is written in its own session once the route returned without an error; a route that fails
    leaves no record.

    Args:
        action: What the route does.
        target_kind: Kind of the thing the route acts on.
        target: Path parameter holding the public id of that thing.

    Returns:
        The dependency.
    """

    async def dependency(request: Request, access: SiteAccess = Depends(get_site_access)) -> AsyncIterator[None]:
        """Record the action once the route succeeded.

        Args:
            request: The request.
            access: Access of the signed-in member to the request's site.

        Yields:
            Nothing; the route runs meanwhile.
        """
        yield
        await write_audit(
            action,
            actor=access.user,
            organisation_id=access.organisation_id,
            site_id=access.site_id,
            target_kind=target_kind,
            target_uuid=path_uuid(request, target),
            details={"method": request.method, "path": request.url.path},
            ip=client_address(request),
        )

    return dependency


def audited_account(
    action: AuditAction, target_kind: str | None = None, target: str | None = "uuid", organisation: str = "organisation"
) -> Callable:
    """Build a dependency that records an action outside a site, such as a member change, after it succeeded.

    Args:
        action: What the route does.
        target_kind: Kind of the thing the route acts on.
        target: Path parameter holding the public id of that thing, None when the path has none.
        organisation: Path parameter holding the public id of the organisation, if the route has one.

    Returns:
        The dependency.
    """

    async def dependency(request: Request, user: UserContext = Depends(get_current_user)) -> AsyncIterator[None]:
        """Record the action once the route succeeded.

        Args:
            request: The request.
            user: Signed-in user.

        Yields:
            Nothing; the route runs meanwhile.
        """
        yield
        await write_audit(
            action,
            actor=user,
            organisation_uuid=path_uuid(request, organisation),
            site_uuid=path_uuid(request, "site"),
            target_kind=target_kind,
            target_uuid=path_uuid(request, target),
            details={"method": request.method, "path": request.url.path},
            ip=client_address(request),
        )

    return dependency
