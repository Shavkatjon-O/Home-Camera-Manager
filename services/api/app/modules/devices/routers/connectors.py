"""Connector endpoints of the apps: pairing, status, discovery and stream tests."""

from uuid import UUID

from fastapi import APIRouter, Depends, Response, status

from app.modules.connectors.deps import get_connector_service, get_pairing_admin_service
from app.modules.connectors.schemas import (
    ConnectorClaim,
    ConnectorList,
    ConnectorRead,
    ConnectorUpdate,
    DiscoveredList,
    PairingRead,
    StreamTest,
    StreamTestResult,
)
from app.modules.connectors.services import ConnectorService, PairingService
from app.tenancy.access import SiteAccess
from app.tenancy.dependencies import require_admin

router = APIRouter()


@router.get("", response_model=ConnectorList)
async def list_connectors(service: ConnectorService = Depends(get_connector_service)) -> ConnectorList:
    """List the connectors of the site.

    Args:
        service: Connector service.

    Returns:
        The connectors.
    """
    return await service.list()


@router.post("/claim", response_model=PairingRead, status_code=status.HTTP_201_CREATED)
async def claim_connector(
    payload: ConnectorClaim,
    access: SiteAccess = Depends(require_admin),
    service: PairingService = Depends(get_pairing_admin_service),
) -> PairingRead:
    """Pair the connector that shows a code to the site; admins and owners only.

    The connector receives its token on its next poll; follow the pairing until its status is delivered.

    Args:
        payload: The code and an optional name.
        access: Access of the signed-in admin to the site.
        service: Pairing service.

    Returns:
        The claimed pairing.
    """
    return await service.claim(access.site_id, payload.user_code, payload.name)


@router.get("/pairings/{uuid}", response_model=PairingRead)
async def get_pairing(
    uuid: UUID,
    access: SiteAccess = Depends(require_admin),
    service: PairingService = Depends(get_pairing_admin_service),
) -> PairingRead:
    """Follow a claimed pairing until the connector picked up its token; admins and owners only.

    Args:
        uuid: Public id of the pairing.
        access: Access of the signed-in admin to the site.
        service: Pairing service.

    Returns:
        The pairing.
    """
    return await service.status(access.site_id, uuid)


@router.get("/{uuid}", response_model=ConnectorRead)
async def get_connector(uuid: UUID, service: ConnectorService = Depends(get_connector_service)) -> ConnectorRead:
    """Return one connector of the site.

    Args:
        uuid: Public id.
        service: Connector service.

    Returns:
        The connector.
    """
    return await service.read(uuid)


@router.patch("/{uuid}", response_model=ConnectorRead, dependencies=[Depends(require_admin)])
async def update_connector(
    uuid: UUID, payload: ConnectorUpdate, service: ConnectorService = Depends(get_connector_service)
) -> ConnectorRead:
    """Rename a connector or pin the address central reaches it at; admins and owners only.

    Args:
        uuid: Public id.
        payload: Fields to change.
        service: Connector service.

    Returns:
        The connector.
    """
    return await service.update(uuid, payload)


@router.delete(
    "/{uuid}", status_code=status.HTTP_204_NO_CONTENT, response_class=Response, dependencies=[Depends(require_admin)]
)
async def remove_connector(uuid: UUID, service: ConnectorService = Depends(get_connector_service)) -> Response:
    """Unpair a connector and remove its cameras; admins and owners only.

    Args:
        uuid: Public id.
        service: Connector service.

    Returns:
        Empty response.
    """
    await service.remove(uuid)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post("/{uuid}/discovery", response_model=ConnectorRead, dependencies=[Depends(require_admin)])
async def request_discovery(uuid: UUID, service: ConnectorService = Depends(get_connector_service)) -> ConnectorRead:
    """Ask a connector to look for cameras on its network now; admins and owners only.

    Args:
        uuid: Public id.
        service: Connector service.

    Returns:
        The connector with the time of the request.
    """
    return await service.request_discovery(uuid)


@router.get("/{uuid}/discovered", response_model=DiscoveredList, dependencies=[Depends(require_admin)])
async def list_discovered_cameras(
    uuid: UUID, service: ConnectorService = Depends(get_connector_service)
) -> DiscoveredList:
    """List the cameras a connector found; admins and owners only.

    Args:
        uuid: Public id.
        service: Connector service.

    Returns:
        The candidates.
    """
    return await service.discovered(uuid)


@router.post("/{uuid}/test", response_model=StreamTestResult, dependencies=[Depends(require_admin)])
async def test_camera_stream(
    uuid: UUID, payload: StreamTest, service: ConnectorService = Depends(get_connector_service)
) -> StreamTestResult:
    """Test a camera's credentials and find its streams through a connector; admins and owners only.

    Args:
        uuid: Public id of the connector.
        payload: The camera.
        service: Connector service.

    Returns:
        What the connector found.
    """
    return await service.test(uuid, payload)
