"""Endpoints a connector calls: RFC 8628 pairing, heartbeat, discovery reports and its camera list."""

from fastapi import APIRouter, Depends, Request, Response, status
from fastapi.responses import JSONResponse

from app.modules.devices.deps import get_connector_device_service, get_connector_pairing_service
from app.modules.devices.schemas import (
    ConnectorConfig,
    ConnectorToken,
    DeviceAuthorization,
    DeviceCodeRequest,
    DeviceGrantErrorBody,
    DeviceTokenRequest,
    DiscoveryReport,
    HeartbeatAck,
    HeartbeatIn,
)
from app.modules.devices.services import ConnectorDeviceService, DeviceGrantRefusal, PairingService

router = APIRouter()


def client_address(request: Request) -> str:
    """Return the source address of a request.

    Args:
        request: The request.

    Returns:
        The address, or unknown.
    """
    return request.client.host if request.client else "unknown"


@router.post("/device-code", response_model=DeviceAuthorization)
async def create_device_code(
    payload: DeviceCodeRequest, request: Request, service: PairingService = Depends(get_connector_pairing_service)
) -> DeviceAuthorization:
    """Open a pairing: the connector shows the user code and its QR code and polls with the device code.

    Args:
        payload: The connector's name, version and WireGuard public key.
        request: The request, for its source address.
        service: Pairing service.

    Returns:
        The RFC 8628 device authorization.
    """
    return await service.open(payload, client_address(request))


@router.post(
    "/token",
    response_model=ConnectorToken,
    responses={400: {"model": DeviceGrantErrorBody, "description": "RFC 8628 error, such as authorization_pending"}},
)
async def poll_device_token(
    payload: DeviceTokenRequest, service: PairingService = Depends(get_connector_pairing_service)
) -> ConnectorToken | JSONResponse:
    """Poll for the connector's credentials, which arrive once a member claimed the code.

    Args:
        payload: The grant type and the device code.
        service: Pairing service.

    Returns:
        The credentials, or an RFC 8628 error with status 400.
    """
    try:
        return await service.token(payload.grant_type, payload.device_code)
    except DeviceGrantRefusal as refusal:
        body = DeviceGrantErrorBody(
            error=refusal.error, error_description=refusal.description, interval=refusal.interval
        )
        return JSONResponse(status_code=400, content=body.model_dump(mode="json", exclude_none=True))


@router.post("/heartbeat", response_model=HeartbeatAck)
async def send_heartbeat(
    payload: HeartbeatIn, request: Request, service: ConnectorDeviceService = Depends(get_connector_device_service)
) -> HeartbeatAck:
    """Report the connector's version, address, health and camera reachability.

    Args:
        payload: The heartbeat.
        request: The request, for its source address.
        service: Service of the authenticated connector.

    Returns:
        Whether a discovery run is wanted and the digest of the camera list.
    """
    return await service.heartbeat(payload, client_address(request))


@router.post("/discovery", status_code=status.HTTP_204_NO_CONTENT, response_class=Response)
async def report_discovery(
    payload: DiscoveryReport, service: ConnectorDeviceService = Depends(get_connector_device_service)
) -> Response:
    """Report the cameras a discovery run found.

    Args:
        payload: The candidates.
        service: Service of the authenticated connector.

    Returns:
        Empty response.
    """
    await service.report_discovery(payload)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.get("/config", response_model=ConnectorConfig)
async def get_connector_config(
    service: ConnectorDeviceService = Depends(get_connector_device_service),
) -> ConnectorConfig:
    """Return the connector's camera list, without credentials, which the connector keeps itself.

    Args:
        service: Service of the authenticated connector.

    Returns:
        The cameras.
    """
    return await service.config()
