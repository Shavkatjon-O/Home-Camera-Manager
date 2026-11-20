"""FastAPI dependencies of the connectors module."""

from fastapi import Depends
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.modules.connectors.services import (
    ConnectorDeviceService,
    ConnectorService,
    PairingService,
    authenticate_connector,
)
from app.tenancy.access import SiteAccess
from app.tenancy.dependencies import get_site_access

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


def get_pairing_admin_service(
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


def get_pairing_service(session: AsyncSession = Depends(get_db)) -> PairingService:
    """Build the pairing service for a connector that has no token yet.

    Args:
        session: Request-scoped database session.

    Returns:
        The service.
    """
    return PairingService(session)


async def get_device_service(
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
