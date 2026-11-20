"""Service for the TV pairing flow."""

import secrets
from datetime import UTC, datetime, timedelta
from uuid import UUID

from sqlalchemy import delete, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.core.base_service import BaseModelService
from app.core.exceptions import NotFound, TooManyRequests, Unavailable
from app.core.rate_limit import RateLimiter
from app.core.security import hash_token, new_token
from app.models import TvDevice, TvPairing
from app.modules.tv.enums import PairingState
from app.modules.tv.schemas import PairingCreate, PairingCreated, PairingStatus, TvDeviceRead
from app.modules.tv.services.devices import device_read

__all__ = ["TvPairingService", "new_code", "pairing_limiter", "pairing_state"]

PAIRING_LIFETIME = timedelta(minutes=10)
PAIRING_RETENTION = timedelta(hours=24)
OPEN_PAIRINGS_MAX = 5

PAIRINGS_PER_WINDOW = 10
PAIRING_WINDOW_SECONDS = 60.0

CODE_SPACE = 1_000_000
CODE_ATTEMPTS = 50

pairing_limiter = RateLimiter(PAIRINGS_PER_WINDOW, PAIRING_WINDOW_SECONDS)


def new_code() -> str:
    """Generate a random pairing code.

    Returns:
        Six digits, zero-padded.
    """
    return f"{secrets.randbelow(CODE_SPACE):06d}"


def pairing_state(pairing: TvPairing, now: datetime) -> PairingState:
    """Work out the progress of a pairing.

    Args:
        pairing: Pairing row.
        now: Current time.

    Returns:
        Approved when approved, otherwise expired once past its expiry time, otherwise pending.
    """
    if pairing.approved:
        return PairingState.APPROVED
    if pairing.expires_at <= now:
        return PairingState.EXPIRED
    return PairingState.PENDING


class TvPairingService(BaseModelService[TvPairing]):
    """Open, poll and approve TV pairings.

    Attributes:
        limiter: Rate limiter applied to pairing requests per client.
    """

    model = TvPairing
    not_found_code = "pairing_not_found"

    def __init__(
        self,
        session: AsyncSession,
        actor: UserContext | None = None,
        limiter: RateLimiter = pairing_limiter,
    ):
        """Bind the service to a session, the acting user and a rate limiter.

        Args:
            session: Database session the service works in.
            actor: Signed-in user making the request, if any.
            limiter: Rate limiter applied to pairing requests per client.
        """
        super().__init__(session, actor)
        self.limiter = limiter

    def open_filter(self, now: datetime) -> tuple:
        """Build the conditions that select pairings still waiting for approval.

        Args:
            now: Current time.

        Returns:
            Conditions for pairings that are not deleted, not approved and not expired.
        """
        return (
            TvPairing.deleted_at.is_(None),
            TvPairing.approved.is_(False),
            TvPairing.expires_at > now,
        )

    async def purge(self, now: datetime) -> None:
        """Delete pairings that expired more than the retention period ago.

        Args:
            now: Current time.
        """
        await self.session.execute(delete(TvPairing).where(TvPairing.expires_at < now - PAIRING_RETENTION))

    async def unique_code(self, now: datetime) -> str:
        """Pick a code that no waiting pairing uses.

        Args:
            now: Current time.

        Returns:
            Free six-digit code.

        Raises:
            Unavailable: When no free code is found after several attempts.
        """
        taken = set(await self.session.scalars(select(TvPairing.code).where(*self.open_filter(now))))
        for _ in range(CODE_ATTEMPTS):
            code = new_code()
            if code not in taken:
                return code
        raise Unavailable("pairing_code_unavailable", "No free pairing code, try again")

    async def create(self, payload: PairingCreate, client: str) -> PairingCreated:
        """Open a pairing for a TV.

        Applies the per-client rate limit, removes long-expired pairings and refuses new ones while too many
        TVs are already waiting.

        Args:
            payload: Device name the TV asks for.
            client: Key of the requesting client, used for rate limiting.

        Returns:
            Pairing id and code, with the time the code expires.

        Raises:
            TooManyRequests: When the client is over its rate limit or too many pairings are waiting.
        """
        if not self.limiter.allow(client):
            raise TooManyRequests("rate_limited", "Too many pairing requests, try again in a minute")
        now = datetime.now(UTC)
        await self.purge(now)
        waiting = await self.session.scalar(select(func.count()).select_from(TvPairing).where(*self.open_filter(now)))
        if (waiting or 0) >= OPEN_PAIRINGS_MAX:
            raise TooManyRequests("too_many_pairings", "Too many TVs are waiting to pair, try again later")
        pairing = TvPairing(
            code=await self.unique_code(now),
            device_name=payload.device_name,
            expires_at=now + PAIRING_LIFETIME,
            approved=False,
        )
        self.session.add(pairing)
        await self.commit()
        await self.session.refresh(pairing)
        return PairingCreated(id=pairing.uuid, code=pairing.code, expires_at=pairing.expires_at)

    async def status(self, uuid: UUID) -> PairingStatus:
        """Report the status of a pairing and hand over the device token once it is approved.

        The pairing row is locked while it is read. An approved pairing is soft-deleted, a fresh token is issued
        for its device and returned, so the token is handed over exactly once. When the device has since been
        revoked or removed, the pairing reports as expired instead.

        Args:
            uuid: Public id of the pairing.

        Returns:
            Pairing status, with the device token only on the call that hands it over.

        Raises:
            NotFound: When the pairing does not exist.
        """
        pairing = await self.session.scalar(
            select(TvPairing).where(TvPairing.uuid == uuid, TvPairing.deleted_at.is_(None)).with_for_update()
        )
        if pairing is None:
            raise NotFound(self.not_found_code, "The pairing does not exist")
        now = datetime.now(UTC)
        state = pairing_state(pairing, now)
        if state != PairingState.APPROVED:
            return PairingStatus(status=state)
        device = None
        if pairing.device_id is not None:
            device = await self.session.scalar(
                select(TvDevice).where(
                    TvDevice.id == pairing.device_id,
                    TvDevice.deleted_at.is_(None),
                    TvDevice.revoked.is_(False),
                )
            )
        pairing.deleted_at = now
        if device is None:
            await self.commit()
            return PairingStatus(status=PairingState.EXPIRED)
        token = new_token()
        device.token_hash = hash_token(token)
        await self.commit()
        return PairingStatus(status=PairingState.APPROVED, token=token)

    async def approve(self, code: str) -> TvDeviceRead:
        """Approve the newest waiting pairing with a code and create its device.

        Args:
            code: Six-digit code shown on the TV.

        Returns:
            The newly created device.

        Raises:
            NotFound: When no waiting pairing has the code.
        """
        now = datetime.now(UTC)
        pairing = await self.session.scalar(
            select(TvPairing)
            .where(*self.open_filter(now), TvPairing.code == code)
            .order_by(TvPairing.created_at.desc(), TvPairing.id.desc())
            .limit(1)
            .with_for_update()
        )
        if pairing is None:
            raise NotFound(self.not_found_code, "No TV is waiting with this code")
        device = TvDevice(name=pairing.device_name, token_hash=hash_token(new_token()), revoked=False)
        self.session.add(device)
        await self.session.flush()
        pairing.approved = True
        pairing.device_id = device.id
        await self.commit()
        await self.session.refresh(device)
        return device_read(device)
