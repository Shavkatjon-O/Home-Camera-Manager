from fastapi import APIRouter, Depends

from app.modules.discovery.deps import get_discovery_service
from app.modules.discovery.schemas import InspectRequest, InspectResult, ScanRequest, ScanResult
from app.modules.discovery.services import DiscoveryService

router = APIRouter()


@router.post("/scan", response_model=ScanResult)
async def scan_network(
    payload: ScanRequest | None = None,
    service: DiscoveryService = Depends(get_discovery_service),
) -> ScanResult:
    return await service.scan(payload or ScanRequest())


@router.post("/inspect", response_model=InspectResult)
async def inspect_camera(
    payload: InspectRequest,
    service: DiscoveryService = Depends(get_discovery_service),
) -> InspectResult:
    return await service.inspect(payload)
