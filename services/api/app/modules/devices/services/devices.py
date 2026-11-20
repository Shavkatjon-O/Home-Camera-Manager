"""Devices of a site: cameras, NVRs and DVRs with the channels added as cameras."""

from uuid import UUID

from sqlalchemy import select

from app.core.base_service import BaseModelService
from app.models import Camera, Connector, Device
from app.modules.devices.schemas.capabilities import capabilities_read
from app.modules.devices.schemas.devices import DeviceChannelRead, DeviceList, DeviceRead

__all__ = ["DeviceService"]


class DeviceService(BaseModelService[Device]):
    """Lists and reads the devices of the request's site.

    Attributes:
        model: Devices.
        not_found_code: Error code of an unknown device.
    """

    model = Device
    not_found_code = "device_not_found"

    async def reads(self, devices: list[Device]) -> list[DeviceRead]:
        """Build the API views of devices with their channels.

        Args:
            devices: The devices.

        Returns:
            The devices in the given order.
        """
        ids = [device.id for device in devices]
        cameras = list(
            await self.session.scalars(
                select(Camera)
                .where(Camera.device_id.in_(ids), Camera.deleted_at.is_(None))
                .order_by(Camera.channel, Camera.id)
            )
        )
        connector_ids = {device.connector_id for device in devices if device.connector_id}
        connectors = (
            dict(
                (
                    await self.session.execute(
                        select(Connector.id, Connector.uuid).where(Connector.id.in_(connector_ids))
                    )
                ).all()
            )
            if connector_ids
            else {}
        )
        return [
            DeviceRead(
                uuid=device.uuid,
                kind=device.kind,
                adapter=device.adapter,
                name=device.name,
                vendor=device.vendor,
                model=device.model,
                connector=connectors.get(device.connector_id),
                channel_count=device.channel_count,
                channels=[
                    DeviceChannelRead(
                        camera=camera.uuid, channel=camera.channel or 1, name=camera.name, enabled=camera.enabled
                    )
                    for camera in cameras
                    if camera.device_id == device.id
                ],
                capabilities=capabilities_read(device.capabilities or {"adapter": device.adapter, "kind": device.kind}),
                identified_at=device.identified_at,
                created_at=device.created_at,
            )
            for device in devices
        ]

    async def list(self) -> DeviceList:
        """List the site's devices.

        Returns:
            The devices, oldest first.
        """
        rows = await self.session.scalars(
            select(Device).where(Device.deleted_at.is_(None)).order_by(Device.created_at, Device.id)
        )
        return DeviceList(items=await self.reads(list(rows)))

    async def read(self, uuid: UUID) -> DeviceRead:
        """Return one device.

        Args:
            uuid: Public id.

        Returns:
            The device.
        """
        return (await self.reads([await self.get(uuid)]))[0]
