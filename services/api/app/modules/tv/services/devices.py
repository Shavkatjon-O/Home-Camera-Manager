"""Service for paired TV devices and their token authentication."""

from datetime import UTC, datetime, timedelta

from sqlalchemy import func, select

from app.auth.context import TvDeviceContext
from app.core.base_service import BaseModelService
from app.core.exceptions import Unauthorized
from app.core.security import hash_token
from app.models import TvDevice
from app.modules.tv.schemas import TvDeviceList, TvDeviceRead

__all__ = ["TvDeviceService", "device_read"]

LAST_SEEN_STEP = timedelta(seconds=60)


def device_read(device: TvDevice) -> TvDeviceRead:
    """Convert a device row to its response schema.

    Args:
        device: Device row.

    Returns:
        The device as shown to users.
    """
    return TvDeviceRead(
        uuid=device.uuid,
        name=device.name,
        created_at=device.created_at,
        last_seen_at=device.last_seen_at,
    )


def not_paired() -> Unauthorized:
    """Build the error that tells a TV to pair again.

    Returns:
        Unauthorized error with the code tv_not_paired.
    """
    return Unauthorized("tv_not_paired", "Pair this TV again")


class TvDeviceService(BaseModelService[TvDevice]):
    """List, revoke and authenticate paired TV devices.

    Attributes:
        model: Paired TV devices.
        not_found_code: Error code of an unknown TV.
    """

    model = TvDevice
    not_found_code = "tv_not_found"

    def active(self):
        """Build the query for devices that are neither deleted nor revoked.

        Returns:
            Select statement over active devices.
        """
        return select(TvDevice).where(TvDevice.deleted_at.is_(None), TvDevice.revoked.is_(False))

    async def list_all(self) -> TvDeviceList:
        """List the active devices.

        Returns:
            Active devices, newest first.
        """
        rows = await self.session.scalars(self.active().order_by(TvDevice.created_at.desc(), TvDevice.id.desc()))
        return TvDeviceList(items=[device_read(device) for device in rows])

    async def revoke(self, uuid) -> None:
        """Revoke a device and soft-delete it, so its token stops working.

        Args:
            uuid: Public id of the device.
        """
        device = await self.get(uuid)
        device.revoked = True
        device.deleted_at = func.now()
        await self.commit()

    async def authenticate(self, token: str | None) -> TvDeviceContext:
        """Find the active device that owns a token and record that it was seen.

        The last seen time is written at most once per minute, so frequent requests do not each cost a commit.

        Args:
            token: Plain device token sent by the TV, if any.

        Returns:
            Identity of the device.

        Raises:
            Unauthorized: When the token is missing or matches no active device.
        """
        if not token:
            raise not_paired()
        device = await self.session.scalar(self.active().where(TvDevice.token_hash == hash_token(token)))
        if device is None:
            raise not_paired()
        now = datetime.now(UTC)
        if device.last_seen_at is None or now - device.last_seen_at >= LAST_SEEN_STEP:
            device.last_seen_at = now
            await self.commit()
        return TvDeviceContext(
            id=device.id,
            uuid=device.uuid,
            name=device.name,
            site_id=device.site_id,
            organisation_id=device.organisation_id,
        )
