"""Pairing endpoints: the method catalog, labels, identification, adding devices and telemetry."""

from uuid import UUID

from fastapi import APIRouter, Depends, Query, status

from app.modules.devices.deps import (
    get_device_pairing_service,
    get_pairing_catalog_service,
    get_pairing_telemetry_service,
)
from app.modules.devices.schemas.devices import DeviceRead
from app.modules.devices.schemas.pairing import (
    IdentifyRequest,
    IdentifyResult,
    LabelRead,
    LabelRequest,
    PairingAttemptCreate,
    PairingAttemptRead,
    PairingDeviceCreate,
    PairingMethodList,
    PairingStats,
)
from app.modules.devices.services.pairing_catalog import PairingCatalogService
from app.modules.devices.services.pairing_devices import DevicePairingService
from app.modules.devices.services.pairing_telemetry import PairingTelemetryService
from app.modules.operations.deps import audited
from app.modules.operations.enums import AuditAction
from app.modules.tenancy.deps import require_admin

router = APIRouter()


@router.get("/methods", response_model=PairingMethodList)
async def list_pairing_methods(
    label: str | None = Query(None, max_length=2048, description="A scanned label payload"),
    discovered: UUID | None = Query(None, description="A camera a connector found"),
    service: PairingCatalogService = Depends(get_pairing_catalog_service),
) -> PairingMethodList:
    """List the ways to add a device or a connector that work now, best first, for an optional context.

    Args:
        label: A scanned label payload, if any.
        discovered: A discovered camera, if any.
        service: Pairing catalog.

    Returns:
        The methods with their requirements and parameters.
    """
    return await service.methods(label, discovered)


@router.post("/label", response_model=LabelRead, dependencies=[Depends(require_admin)])
async def read_label(
    payload: LabelRequest, service: PairingCatalogService = Depends(get_pairing_catalog_service)
) -> LabelRead:
    """Read a device's label QR code with the adapters' parsers; admins and owners only.

    Args:
        payload: The decoded QR text.
        service: Pairing catalog.

    Returns:
        What the label says and the methods that continue from it.
    """
    return service.label(payload.payload)


@router.post("/identify", response_model=IdentifyResult)
async def identify_device(
    payload: IdentifyRequest, service: DevicePairingService = Depends(get_device_pairing_service)
) -> IdentifyResult:
    """Identify a device through a connector, or directly, with the adapter registry; admins and owners only.

    Args:
        payload: The device's address and login.
        service: Device pairing service.

    Returns:
        Its adapter, kind, vendor, model, channels and capabilities.
    """
    return await service.identify(payload)


@router.post(
    "/devices",
    response_model=DeviceRead,
    status_code=status.HTTP_201_CREATED,
    dependencies=[Depends(audited(AuditAction.DEVICE_PAIR, "device"))],
)
async def create_paired_device(
    payload: PairingDeviceCreate, service: DevicePairingService = Depends(get_device_pairing_service)
) -> DeviceRead:
    """Add a device and the chosen channels as cameras, by any device pairing method; admins and owners only.

    Args:
        payload: The device, its channels and the method used.
        service: Device pairing service.

    Returns:
        The device with its channels.
    """
    return await service.create(payload)


@router.post(
    "/attempts",
    response_model=PairingAttemptRead,
    status_code=status.HTTP_201_CREATED,
    dependencies=[Depends(require_admin)],
)
async def report_pairing_attempt(
    payload: PairingAttemptCreate, service: PairingTelemetryService = Depends(get_pairing_telemetry_service)
) -> PairingAttemptRead:
    """Record a pairing step the app took itself, such as a scan the member abandoned; it carries no personal data.

    Args:
        payload: The attempt.
        service: Pairing telemetry.

    Returns:
        The recorded attempt.
    """
    return await service.report(payload)


@router.get("/stats", response_model=PairingStats, dependencies=[Depends(require_admin)])
async def read_pairing_stats(
    days: int = Query(30, ge=1, le=365),
    service: PairingTelemetryService = Depends(get_pairing_telemetry_service),
) -> PairingStats:
    """Sum up the organisation's pairing attempts per method; admins and owners only.

    Args:
        days: Length of the period in days.
        service: Pairing telemetry.

    Returns:
        Attempts, outcomes, success rate, median duration, top errors and stopping steps per method.
    """
    return await service.stats(days)
