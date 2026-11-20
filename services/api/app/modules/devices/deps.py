"""FastAPI dependencies of the devices module."""

from fastapi import Depends
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.modules.devices.services import (
    CameraControlService,
    CameraService,
    ConnectorDeviceService,
    ConnectorService,
    DiscoveryService,
    PairingService,
    authenticate_connector,
)
from app.modules.tenancy.deps import get_site_access
from app.modules.tenancy.services.access import SiteAccess


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


connector_bearer = HTTPBearer(auto_error=False, scheme_name="ConnectorToken")


def get_connector_service(
    session: AsyncSession = Depends(get_db), access: SiteAccess = Depends(get_site_access)
) -> ConnectorService:
    """Build the connector service for a member of the request's site.

    Args:
        session: Request-scoped database session, limited to the site.
        access: Access of the signed-in member to the request's site.

    Returns:
        The service.
    """
    return ConnectorService(session, access.user)


def get_connector_pairing_admin_service(
    session: AsyncSession = Depends(get_db), access: SiteAccess = Depends(get_site_access)
) -> PairingService:
    """Build the pairing service for a member claiming a connector.

    Args:
        session: Request-scoped database session.
        access: Access of the signed-in member to the request's site.

    Returns:
        The service.
    """
    return PairingService(session, access.user)


def get_connector_pairing_service(session: AsyncSession = Depends(get_db)) -> PairingService:
    """Build the pairing service for a connector that has no token yet.

    Args:
        session: Request-scoped database session.

    Returns:
        The service.
    """
    return PairingService(session)


async def get_connector_device_service(
    credentials: HTTPAuthorizationCredentials | None = Depends(connector_bearer),
    session: AsyncSession = Depends(get_db),
) -> ConnectorDeviceService:
    """Authenticate a connector from its bearer token and build its service.

    Args:
        credentials: Bearer credentials, if sent.
        session: Request-scoped database session.

    Returns:
        The service for the connector.
    """
    connector = await authenticate_connector(session, credentials.credentials if credentials else None)
    return ConnectorDeviceService(session, connector)


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


def get_discovery_service(
    session: AsyncSession = Depends(get_db),
    access: SiteAccess = Depends(get_site_access),
) -> DiscoveryService:
    """Build the discovery service for a signed-in request.

    Args:
        session: Request-scoped database session.
        access: Access of the signed-in member to the request's site.

    Returns:
        Discovery service bound to the session and the user.
    """
    return DiscoveryService(session, access.user)
