"""Network device service."""

from uuid import UUID

from sqlalchemy import func, select

from app.core.base_service import BaseModelService
from app.core.exceptions import Conflict, Unprocessable
from app.models import Camera, CameraLink, NetworkDevice
from app.modules.health.enums import DeviceKind, LinkKind
from app.modules.health.schemas import (
    NetworkDeviceCreate,
    NetworkDeviceList,
    NetworkDeviceRead,
    NetworkDeviceUpdate,
)

__all__ = ["NetworkDeviceService", "creates_cycle", "in_use_message"]

ENUM_FIELDS = {"kind": DeviceKind, "link": LinkKind}


def creates_cycle(device_uuid: UUID, parent_uuid: UUID | None, parents: dict[UUID, UUID | None]) -> bool:
    """Check whether giving a device a parent would make the devices connect through each other in a loop.

    Args:
        device_uuid: Public id of the device being given a parent.
        parent_uuid: Public id of the proposed parent.
        parents: Parent of every device keyed by device id.

    Returns:
        True when following the parents from the proposed parent leads back to the device.
    """
    seen: set[UUID] = set()
    current = parent_uuid
    while current is not None and current not in seen:
        if current == device_uuid:
            return True
        seen.add(current)
        current = parents.get(current)
    return False


def counted(count: int, noun: str) -> str:
    """Format a count with a noun, pluralized when the count is not one.

    Args:
        count: Number to show.
        noun: Singular noun.

    Returns:
        Text such as "1 device" or "2 devices".
    """
    return f"{count} {noun}" if count == 1 else f"{count} {noun}s"


def in_use_message(name: str, devices: int, cameras: int) -> str:
    """Build the message that asks the user to move what is connected through a device.

    Args:
        name: Name of the device that cannot be deleted.
        devices: Number of devices connected through it.
        cameras: Number of cameras connected through it.

    Returns:
        The message naming the devices and cameras that must be moved.
    """
    parts = [counted(count, noun) for count, noun in ((devices, "device"), (cameras, "camera")) if count]
    return f"Move the {' and '.join(parts)} connected through {name} first"


def stored(field: str, value):
    """Convert a field value to the form stored in the database.

    Args:
        field: Name of the field.
        value: Value from the request.

    Returns:
        The plain string of an enum field, or the value unchanged for other fields and for None.
    """
    kind = ENUM_FIELDS.get(field)
    if kind is None or value is None:
        return value
    return kind(value).value


class NetworkDeviceService(BaseModelService[NetworkDevice]):
    """Manage network devices and the topology they form."""

    model = NetworkDevice
    not_found_code = "network_device_not_found"

    def live(self):
        """Build a query for devices that are not deleted.

        Returns:
            The select statement.
        """
        return select(NetworkDevice).where(NetworkDevice.deleted_at.is_(None))

    async def parents(self) -> dict[UUID, UUID | None]:
        """Map every live device to its parent.

        Returns:
            The parent id of each device keyed by device id.
        """
        rows = await self.session.execute(
            select(NetworkDevice.uuid, NetworkDevice.parent_uuid).where(NetworkDevice.deleted_at.is_(None))
        )
        return {device_uuid: parent_uuid for device_uuid, parent_uuid in rows.all()}

    async def name_of(self, device_uuid: UUID | None) -> str | None:
        """Look up the name of a live device.

        Args:
            device_uuid: Public id of the device, if any.

        Returns:
            The name, or None when no id is given or the device does not exist.
        """
        if device_uuid is None:
            return None
        return await self.session.scalar(
            select(NetworkDevice.name).where(NetworkDevice.uuid == device_uuid, NetworkDevice.deleted_at.is_(None))
        )

    def read(self, device: NetworkDevice, parent_name: str | None) -> NetworkDeviceRead:
        """Convert a device row to its API form.

        Args:
            device: Device row.
            parent_name: Name of its parent device.

        Returns:
            The device as the API returns it.
        """
        return NetworkDeviceRead(
            uuid=device.uuid,
            name=device.name,
            kind=DeviceKind(device.kind),
            host=device.host,
            probe_port=device.probe_port,
            parent_uuid=device.parent_uuid,
            parent_name=parent_name,
            link=LinkKind(device.link) if device.link else None,
            notes=device.notes,
            enabled=device.enabled,
            created_at=device.created_at,
            updated_at=device.updated_at,
        )

    async def list_page(self, page: int, page_size: int) -> NetworkDeviceList:
        """List devices, newest first, with their parents' names.

        Args:
            page: One-based page number.
            page_size: Devices per page.

        Returns:
            The requested page of devices.
        """
        total = await self.session.scalar(
            select(func.count()).select_from(NetworkDevice).where(NetworkDevice.deleted_at.is_(None))
        )
        rows = list(
            await self.session.scalars(
                self.live()
                .order_by(NetworkDevice.created_at.desc(), NetworkDevice.id.desc())
                .offset((page - 1) * page_size)
                .limit(page_size)
            )
        )
        parent_uuids = {device.parent_uuid for device in rows if device.parent_uuid is not None}
        names: dict[UUID, str] = {}
        if parent_uuids:
            result = await self.session.execute(
                select(NetworkDevice.uuid, NetworkDevice.name).where(
                    NetworkDevice.uuid.in_(parent_uuids), NetworkDevice.deleted_at.is_(None)
                )
            )
            names = {device_uuid: name for device_uuid, name in result.all()}
        return NetworkDeviceList(
            items=[self.read(device, names.get(device.parent_uuid)) for device in rows],
            total=total or 0,
            page=page,
            page_size=page_size,
        )

    async def detail(self, uuid: UUID) -> NetworkDeviceRead:
        """Load one device.

        Args:
            uuid: Public id of the device.

        Returns:
            The device with its parent's name.
        """
        device = await self.get(uuid)
        return self.read(device, await self.name_of(device.parent_uuid))

    async def check_parent(self, device_uuid: UUID | None, parent_uuid: UUID | None) -> None:
        """Check that a device may connect through a parent.

        Args:
            device_uuid: Public id of the device being created or changed, or None for a new device.
            parent_uuid: Public id of the proposed parent, if any.

        Raises:
            Unprocessable: The parent is the device itself, does not exist or sits behind the device.
        """
        if parent_uuid is None:
            return
        if parent_uuid == device_uuid:
            raise Unprocessable("invalid_parent", "A device cannot connect through itself")
        parents = await self.parents()
        if parent_uuid not in parents:
            raise Unprocessable("parent_not_found", f"Network device {parent_uuid} does not exist")
        if device_uuid is not None and creates_cycle(device_uuid, parent_uuid, parents):
            raise Unprocessable("invalid_parent", "A device cannot connect through a device behind it")

    async def create(self, payload: NetworkDeviceCreate) -> NetworkDeviceRead:
        """Create a device.

        Args:
            payload: Fields of the new device.

        Returns:
            The created device.
        """
        await self.check_parent(None, payload.parent_uuid)
        device = NetworkDevice(
            name=payload.name,
            kind=payload.kind.value,
            host=payload.host,
            probe_port=payload.probe_port,
            parent_uuid=payload.parent_uuid,
            link=payload.link.value if payload.link else None,
            notes=payload.notes,
            enabled=payload.enabled,
        )
        self.session.add(device)
        await self.commit()
        await self.session.refresh(device)
        return self.read(device, await self.name_of(device.parent_uuid))

    async def update(self, uuid: UUID, payload: NetworkDeviceUpdate) -> NetworkDeviceRead:
        """Change fields of a device.

        The parent is checked only when the request changes it.

        Args:
            uuid: Public id of the device.
            payload: Fields to change.

        Returns:
            The updated device.
        """
        device = await self.get(uuid)
        changes = payload.model_dump(exclude_unset=True)
        if "parent_uuid" in changes and changes["parent_uuid"] != device.parent_uuid:
            await self.check_parent(device.uuid, changes["parent_uuid"])
        for field, value in changes.items():
            setattr(device, field, stored(field, value))
        await self.commit()
        await self.session.refresh(device)
        return self.read(device, await self.name_of(device.parent_uuid))

    async def delete(self, uuid: UUID) -> None:
        """Soft-delete a device that nothing connects through.

        Args:
            uuid: Public id of the device.

        Raises:
            Conflict: Another device or a camera still connects through it.
        """
        device = await self.get(uuid)
        devices = await self.session.scalar(
            select(func.count())
            .select_from(NetworkDevice)
            .where(NetworkDevice.parent_uuid == device.uuid, NetworkDevice.deleted_at.is_(None))
        )
        cameras = await self.session.scalar(
            select(func.count())
            .select_from(CameraLink)
            .where(
                CameraLink.parent_uuid == device.uuid,
                CameraLink.deleted_at.is_(None),
                CameraLink.camera_uuid.in_(select(Camera.uuid).where(Camera.deleted_at.is_(None))),
            )
        )
        if devices or cameras:
            raise Conflict("network_device_in_use", in_use_message(device.name, devices or 0, cameras or 0))
        device.deleted_at = func.now()
        await self.commit()
