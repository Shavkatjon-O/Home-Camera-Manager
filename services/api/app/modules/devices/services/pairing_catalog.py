"""The pairing method catalog: which ways of adding a device work now, for the site and what was scanned."""

from datetime import UTC, datetime
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.core.exceptions import NotFound, Unprocessable
from app.models import Connector, DiscoveredCamera
from app.modules.devices.schemas.pairing import (
    LabelRead,
    PairingMethod,
    PairingMethodId,
    PairingMethodList,
    PairingParameter,
)
from app.modules.devices.services.connectors import connector_online
from camera_adapters.base import LabelInfo
from camera_adapters.registry import Registry, default_registry

__all__ = ["PairingCatalogService", "label_read"]

ID = PairingMethodId


def parameter(name: str, kind: str, required: bool, description: str, prefill=None, default=None) -> PairingParameter:
    """Describe one parameter of a method.

    Args:
        name: Field name.
        kind: Value type.
        required: Whether it is needed.
        description: What it is.
        prefill: Value read from the context.
        default: Value used when omitted.

    Returns:
        The parameter.
    """
    return PairingParameter(
        name=name, type=kind, required=required, description=description, prefill=prefill, default=default
    )


def label_methods(label: LabelInfo) -> list[PairingMethodId]:
    """List the methods that can continue from a label.

    Args:
        label: What the label says.

    Returns:
        Method ids, best first.
    """
    if label.url and label.url.lower().startswith(("rtsp://", "rtsps://")):
        return [ID.RTSP_URL]
    if label.kind != "camera":
        return [ID.NVR_IMPORT, ID.CONNECTOR_DISCOVERY, ID.MANUAL_HOST]
    if label.host:
        return [ID.MANUAL_HOST]
    return [ID.CONNECTOR_DISCOVERY, ID.MANUAL_HOST]


def label_read(label: LabelInfo) -> LabelRead:
    """Build the API view of a label.

    Args:
        label: What the label says.

    Returns:
        The label with the methods that continue from it.
    """
    return LabelRead(
        adapter=label.adapter,
        format=label.format,
        confirmed=label.confirmed,
        kind=str(label.kind),
        vendor=label.vendor,
        model=label.model,
        serial=label.serial,
        code=label.code,
        device_id=label.device_id,
        host=label.host,
        port=label.port,
        url=label.url,
        methods=label_methods(label),
    )


class PairingCatalogService:
    """Lists the pairing methods that work for the request's site.

    Attributes:
        session: Database session limited to the request's site.
        registry: Adapter registry that reads labels.
        is_admin: Whether the member may add devices.
    """

    def __init__(self, session: AsyncSession, is_admin: bool, registry: Registry | None = None):
        """Bind the service to a scoped session.

        Args:
            session: Database session limited to the request's site.
            is_admin: Whether the member may add devices.
            registry: Adapter registry, the default one when omitted.
        """
        self.session = session
        self.is_admin = is_admin
        self.registry = registry or default_registry()

    async def online_connectors(self) -> list[UUID]:
        """List the site's paired connectors that sent a heartbeat recently.

        Returns:
            Their public ids.
        """
        rows = await self.session.scalars(
            select(Connector).where(Connector.deleted_at.is_(None), Connector.revoked_at.is_(None))
        )
        now = datetime.now(UTC)
        return [connector.uuid for connector in rows if connector_online(connector, now)]

    def label(self, payload: str) -> LabelRead:
        """Read a scanned label.

        Args:
            payload: The decoded QR text.

        Returns:
            What the label says.

        Raises:
            Unprocessable: No adapter reads the label.
        """
        label = self.registry.parse_label(payload)
        if label is None:
            raise Unprocessable("unknown_label", "This QR code is not a camera or recorder label we know")
        return label_read(label)

    async def discovered(self, uuid: UUID) -> DiscoveredCamera:
        """Load a discovered camera of the site.

        Args:
            uuid: Public id.

        Returns:
            The candidate.

        Raises:
            NotFound: The site has no such candidate.
        """
        row = await self.session.scalar(select(DiscoveredCamera).where(DiscoveredCamera.uuid == uuid))
        if row is None:
            raise NotFound("discovered_camera_not_found", f"Discovered camera {uuid} does not exist")
        return row

    async def methods(self, label: str | None = None, discovered: UUID | None = None) -> PairingMethodList:
        """List the methods that work now, ordered for the context.

        A method is offered only when it can succeed: connector discovery needs an online connector, adding by
        address needs a connector or a backend allowed to reach cameras itself, and Wi-Fi provisioning methods
        appear only once an adapter implements them, which none does yet.

        Args:
            label: A scanned label payload, if any.
            discovered: A discovered camera the member picked, if any.

        Returns:
            The methods, best first.
        """
        connectors = await self.online_connectors()
        direct = settings.direct_cameras
        reach = bool(connectors) or direct
        context_label = self.registry.parse_label(label) if label else None
        candidate = await self.discovered(discovered) if discovered else None
        prefill: dict[str, str | int | None] = {}
        adapter = None
        if context_label is not None:
            adapter = context_label.adapter
            prefill = {
                "host": context_label.host,
                "port": context_label.port,
                "password": context_label.code,
                "device_id": context_label.device_id,
                "rtsp_url": context_label.url if (context_label.url or "").startswith("rtsp") else None,
            }
        if candidate is not None:
            adapter = candidate.brand or adapter
            prefill = {**prefill, "host": candidate.host, "port": candidate.onvif_port}
        connector_parameter = parameter(
            "connector",
            "uuid",
            not direct,
            "Connector that reaches the device",
            prefill=str(connectors[0]) if connectors else None,
        )
        address = [
            parameter("host", "string", True, "Address of the device on the site's network", prefill.get("host")),
            parameter("port", "integer", False, "Control port, such as the ONVIF port", prefill.get("port")),
            parameter("username", "string", False, "Login of the device", default="admin"),
            parameter("password", "password", False, "Password of the device", prefill.get("password")),
            connector_parameter,
        ]
        catalog: dict[PairingMethodId, PairingMethod] = {}
        if self.is_admin and connectors:
            catalog[ID.CONNECTOR_DISCOVERY] = PairingMethod(
                id=ID.CONNECTOR_DISCOVERY,
                title="Find cameras on the network",
                description="The connector looks for cameras on the site's network; pick one and enter its login.",
                requires=["admin", "connector"],
                parameters=[connector_parameter, parameter("discovered", "uuid", True, "Camera the connector found")],
                endpoint="request_discovery",
                adapter=adapter,
            )
        if self.is_admin:
            catalog[ID.CONNECTOR_QR] = PairingMethod(
                id=ID.CONNECTOR_QR,
                title="Scan the connector's code",
                description="Scan the QR code the connector shows to pair it with this site.",
                requires=["admin", "camera_app"],
                parameters=[parameter("user_code", "qr", True, "The QR code or its link")],
                endpoint="claim_connector",
            )
            catalog[ID.CONNECTOR_CODE] = PairingMethod(
                id=ID.CONNECTOR_CODE,
                title="Type the connector's code",
                description="Type the eight letters the connector shows to pair it with this site.",
                requires=["admin"],
                parameters=[parameter("user_code", "string", True, "The eight letters, such as BCDF-GHJK")],
                endpoint="claim_connector",
            )
            catalog[ID.CONNECTOR_MDNS] = PairingMethod(
                id=ID.CONNECTOR_MDNS,
                title="Find a connector on this Wi-Fi",
                description="The app finds a connector that waits for pairing on the same network and claims it.",
                requires=["admin", "same_wifi"],
                parameters=[
                    parameter("user_code", "string", True, "Code the connector announces as _sss-connector._tcp")
                ],
                endpoint="claim_connector",
            )
            catalog[ID.LABEL_QR] = PairingMethod(
                id=ID.LABEL_QR,
                title="Scan the label",
                description="Scan the QR code on the device's label; what it says fills in the next step.",
                requires=["admin", "camera_app"],
                parameters=[parameter("payload", "qr", True, "The decoded QR text")],
                endpoint="read_label",
            )
        if self.is_admin and reach:
            catalog[ID.MANUAL_HOST] = PairingMethod(
                id=ID.MANUAL_HOST,
                title="Enter the address",
                description="Enter the device's address and login; the adapter is found from what it answers.",
                requires=["admin", "connector" if not direct else "direct"],
                parameters=address,
                endpoint="create_paired_device",
                adapter=adapter,
            )
            catalog[ID.NVR_IMPORT] = PairingMethod(
                id=ID.NVR_IMPORT,
                title="Import a recorder's channels",
                description="Enter an NVR or DVR's address and login, then pick the channels to add as cameras.",
                requires=["admin", "connector" if not direct else "direct"],
                parameters=[*address, parameter("channels", "list", True, "Channel numbers to add")],
                endpoint="create_paired_device",
                adapter=adapter,
            )
            catalog[ID.RTSP_URL] = PairingMethod(
                id=ID.RTSP_URL,
                title="Enter a stream address",
                description="Enter an rtsp:// address of any camera; it is added as a plain stream.",
                requires=["admin", "connector" if not direct else "direct"],
                parameters=[
                    parameter("rtsp_url", "url", True, "The stream address", prefill.get("rtsp_url")),
                    parameter("username", "string", False, "Login of the stream"),
                    parameter("password", "password", False, "Password of the stream"),
                    connector_parameter,
                ],
                endpoint="create_paired_device",
            )
        if context_label is not None:
            order = label_methods(context_label)
        elif candidate is not None:
            order = [ID.CONNECTOR_DISCOVERY, ID.NVR_IMPORT, ID.MANUAL_HOST]
        elif connectors:
            order = [ID.CONNECTOR_DISCOVERY, ID.LABEL_QR, ID.MANUAL_HOST, ID.NVR_IMPORT, ID.RTSP_URL]
        else:
            order = [ID.CONNECTOR_QR, ID.CONNECTOR_MDNS, ID.CONNECTOR_CODE, ID.LABEL_QR, ID.MANUAL_HOST]
        ranked = [catalog[method] for method in order if method in catalog]
        ranked += [method for key, method in catalog.items() if key not in order]
        if ranked:
            ranked[0] = ranked[0].model_copy(update={"recommended": True})
        return PairingMethodList(items=ranked, connectors=connectors, direct=direct)
