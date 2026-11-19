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
    return TvDeviceRead(
        uuid=device.uuid,
        name=device.name,
        created_at=device.created_at,
        last_seen_at=device.last_seen_at,
    )


def not_paired() -> Unauthorized:
    return Unauthorized("tv_not_paired", "Pair this TV again")


class TvDeviceService(BaseModelService[TvDevice]):
    model = TvDevice
    not_found_code = "tv_not_found"

    def active(self):
        return select(TvDevice).where(TvDevice.deleted_at.is_(None), TvDevice.revoked.is_(False))

    async def list_all(self) -> TvDeviceList:
        rows = await self.session.scalars(self.active().order_by(TvDevice.created_at.desc(), TvDevice.id.desc()))
        return TvDeviceList(items=[device_read(device) for device in rows])

    async def revoke(self, uuid) -> None:
        device = await self.get(uuid)
        device.revoked = True
        device.deleted_at = func.now()
        await self.commit()

    async def authenticate(self, token: str | None) -> TvDeviceContext:
        if not token:
            raise not_paired()
        device = await self.session.scalar(self.active().where(TvDevice.token_hash == hash_token(token)))
        if device is None:
            raise not_paired()
        now = datetime.now(UTC)
        if device.last_seen_at is None or now - device.last_seen_at >= LAST_SEEN_STEP:
            device.last_seen_at = now
            await self.commit()
        return TvDeviceContext(id=device.id, uuid=device.uuid, name=device.name)
