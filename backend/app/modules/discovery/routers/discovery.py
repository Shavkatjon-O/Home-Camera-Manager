"""Camera discovery endpoints."""

from fastapi import APIRouter, Depends

from app.modules.discovery.deps import get_discovery_service
from app.modules.discovery.schemas import InspectRequest, InspectResult, ScanRequest, ScanResult
from app.modules.discovery.services import DiscoveryService
from app.tenancy.dependencies import require_admin

router = APIRouter()


@router.post("/scan", dependencies=[Depends(require_admin)], response_model=ScanResult)
async def scan_network(
    payload: ScanRequest | None = None,
    service: DiscoveryService = Depends(get_discovery_service),
) -> ScanResult:
    """Scan a subnet for cameras.

    Args:
        payload: Subnet to scan; the configured default subnet is used when it is missing.
        service: Discovery service for the request.

    Returns:
        Cameras found, each marked with the registered camera at its address.
    """
    return await service.scan(payload or ScanRequest())


@router.post("/inspect", dependencies=[Depends(require_admin)], response_model=InspectResult)
async def inspect_camera(
    payload: InspectRequest,
    service: DiscoveryService = Depends(get_discovery_service),
) -> InspectResult:
    """Read the device information and stream profiles of a camera over ONVIF.

    Args:
        payload: Address and optional login of the camera.
        service: Discovery service for the request.

    Returns:
        Device information and the stream profiles the camera reports.
    """
    return await service.inspect(payload)
