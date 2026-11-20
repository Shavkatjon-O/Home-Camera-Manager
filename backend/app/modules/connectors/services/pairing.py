"""RFC 8628 pairing of connectors: device codes, claims by a member, and token delivery."""

import secrets
from datetime import UTC, datetime, timedelta
from uuid import UUID

from sqlalchemy import delete, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.core.config import settings
from app.core.exceptions import NotFound, TooManyRequests, Unprocessable
from app.core.mail import link
from app.core.rate_limit import RateLimiter
from app.core.security import encrypt_secret, hash_token, new_token
from app.models import Connector, ConnectorPairing, Organisation, Site
from app.modules.connectors.enums import DEVICE_GRANT, DeviceGrantError, PairingStatus
from app.modules.connectors.schemas import (
    ConnectorToken,
    DeviceAuthorization,
    DeviceCodeRequest,
    PairingRead,
)

__all__ = [
    "CODE_ALPHABET",
    "DeviceGrantRefusal",
    "PairingService",
    "format_user_code",
    "new_user_code",
    "pairing_limiter",
    "pairing_status",
]

CODE_ALPHABET = "BCDFGHJKLMNPQRSTVWXZ"
CODE_LENGTH = 8
SLOW_DOWN_STEP = 5
PAIRINGS_PER_WINDOW = 10
PAIRING_WINDOW_SECONDS = 60.0
RETENTION = timedelta(days=1)
STREAM_USERNAME = "central"
HEARTBEAT_SECONDS = 30

pairing_limiter = RateLimiter(PAIRINGS_PER_WINDOW, PAIRING_WINDOW_SECONDS)


class DeviceGrantRefusal(Exception):
    """A refusal of the token endpoint in the RFC 8628 error form.

    Attributes:
        error: Error code.
        description: Explanation.
        interval: New poll interval for slow_down.
    """

    def __init__(self, error: DeviceGrantError, description: str, interval: int | None = None):
        """Create the refusal.

        Args:
            error: Error code.
            description: Explanation.
            interval: New poll interval for slow_down.
        """
        super().__init__(description)
        self.error = error
        self.description = description
        self.interval = interval


def new_user_code() -> str:
    """Draw a pairing code of consonants, which cannot spell words or be misread as digits.

    Returns:
        Eight upper-case letters.
    """
    return "".join(secrets.choice(CODE_ALPHABET) for _ in range(CODE_LENGTH))


def format_user_code(code: str) -> str:
    """Format a pairing code for display.

    Args:
        code: Eight letters.

    Returns:
        The code with a hyphen in the middle, such as BCDF-GHJK.
    """
    return f"{code[:4]}-{code[4:]}"


def pairing_status(pairing: ConnectorPairing, now: datetime) -> PairingStatus:
    """Tell the state of a pairing.

    Args:
        pairing: The pairing.
        now: Current time.

    Returns:
        delivered, claimed, expired or pending.
    """
    if pairing.delivered_at is not None:
        return PairingStatus.DELIVERED
    if pairing.expires_at <= now:
        return PairingStatus.EXPIRED
    if pairing.claimed_at is not None:
        return PairingStatus.CLAIMED
    return PairingStatus.PENDING


class PairingService:
    """Opens, claims and completes connector pairings.

    Attributes:
        session: Database session.
        actor: Signed-in member claiming a pairing, if any.
        limiter: Limit on pairings opened per client address.
    """

    def __init__(self, session: AsyncSession, actor: UserContext | None = None, limiter: RateLimiter = pairing_limiter):
        """Bind the service to a database session.

        Args:
            session: Database session.
            actor: Signed-in member, if any.
            limiter: Limit on pairings opened per client address.
        """
        self.session = session
        self.actor = actor
        self.limiter = limiter

    async def open(self, request: DeviceCodeRequest, client: str) -> DeviceAuthorization:
        """Open a pairing for a connector that has no token yet.

        Args:
            request: The connector's name, version and public key.
            client: Address of the connector, for rate limiting.

        Returns:
            The device and user codes.

        Raises:
            TooManyRequests: The address opened too many pairings in the last minute.
        """
        if not self.limiter.allow(client):
            raise TooManyRequests("rate_limited", "Too many pairing requests, try again in a minute")
        now = datetime.now(UTC)
        await self.session.execute(delete(ConnectorPairing).where(ConnectorPairing.expires_at < now - RETENTION))
        device_code = new_token()
        user_code = new_user_code()
        lifetime = timedelta(minutes=settings.connector_code_minutes)
        self.session.add(
            ConnectorPairing(
                device_code_hash=hash_token(device_code),
                user_code=user_code,
                name=request.name.strip() or "Connector",
                version=request.version,
                public_key=request.public_key,
                expires_at=now + lifetime,
                interval=settings.connector_poll_seconds,
            )
        )
        await self.session.commit()
        display = format_user_code(user_code)
        return DeviceAuthorization(
            device_code=device_code,
            user_code=display,
            verification_uri=link("/connect"),
            verification_uri_complete=link(f"/connect?code={display}"),
            expires_in=int(lifetime.total_seconds()),
            interval=settings.connector_poll_seconds,
        )

    async def token(self, grant_type: str, device_code: str) -> ConnectorToken:
        """Answer a connector's poll: pending until a member claims it, then its credentials, once.

        Args:
            grant_type: Must be the device code grant.
            device_code: The device code.

        Returns:
            The connector's credentials.

        Raises:
            DeviceGrantRefusal: The grant is unsupported, the code unknown, used or expired, not claimed yet, or
                polled faster than its interval.
        """
        if grant_type != DEVICE_GRANT:
            raise DeviceGrantRefusal(DeviceGrantError.UNSUPPORTED, "Only the device code grant is supported")
        now = datetime.now(UTC)
        pairing = await self.session.scalar(
            select(ConnectorPairing)
            .where(ConnectorPairing.device_code_hash == hash_token(device_code))
            .with_for_update()
        )
        if pairing is None:
            raise DeviceGrantRefusal(DeviceGrantError.INVALID_GRANT, "The device code is not known")
        if pairing.delivered_at is not None:
            raise DeviceGrantRefusal(DeviceGrantError.INVALID_GRANT, "The device code was already used")
        if pairing.expires_at <= now:
            raise DeviceGrantRefusal(DeviceGrantError.EXPIRED, "The pairing code expired; start again")
        last = pairing.last_polled_at
        pairing.last_polled_at = now
        if pairing.claimed_at is None:
            if last is not None and (now - last).total_seconds() < pairing.interval - 0.5:
                pairing.interval += SLOW_DOWN_STEP
                await self.session.commit()
                raise DeviceGrantRefusal(DeviceGrantError.SLOW_DOWN, "Polling too fast", pairing.interval)
            await self.session.commit()
            raise DeviceGrantRefusal(DeviceGrantError.PENDING, "Waiting for a member to enter the code")
        site = await self.session.get(Site, pairing.site_id)
        if site is None or site.deleted_at is not None:
            raise DeviceGrantRefusal(DeviceGrantError.DENIED, "The site of the pairing no longer exists")
        organisation = await self.session.get(Organisation, site.organisation_id)
        token = new_token()
        agent_key = new_token()
        stream_password = secrets.token_urlsafe(24)
        connector = Connector(
            site_id=site.id,
            organisation_id=site.organisation_id,
            name=pairing.name,
            token_hash=hash_token(token),
            agent_key_encrypted=encrypt_secret(agent_key),
            stream_username=STREAM_USERNAME,
            stream_password_encrypted=encrypt_secret(stream_password),
            version=pairing.version,
            public_key=pairing.public_key,
            health={},
        )
        self.session.add(connector)
        await self.session.flush()
        pairing.connector_id = connector.id
        pairing.delivered_at = now
        await self.session.commit()
        return ConnectorToken(
            access_token=token,
            connector=connector.uuid,
            site=site.uuid,
            organisation=organisation.uuid,
            agent_key=agent_key,
            stream_username=STREAM_USERNAME,
            stream_password=stream_password,
            heartbeat_interval=HEARTBEAT_SECONDS,
        )

    def read(self, pairing: ConnectorPairing, connector_uuid: UUID | None, now: datetime) -> PairingRead:
        """Build the app's view of a pairing.

        Args:
            pairing: The pairing.
            connector_uuid: Public id of the connector it created, if any.
            now: Current time.

        Returns:
            The pairing.
        """
        return PairingRead(
            uuid=pairing.uuid,
            name=pairing.name,
            status=pairing_status(pairing, now),
            expires_at=pairing.expires_at,
            connector=connector_uuid,
        )

    async def claim(self, site_id: int, user_code: str, name: str | None) -> PairingRead:
        """Claim the pairing that shows a code for a site.

        Args:
            site_id: Database id of the request's site.
            user_code: The eight letters.
            name: Name for the connector, if given.

        Returns:
            The claimed pairing.

        Raises:
            NotFound: No open pairing shows the code.
            Unprocessable: The pairing was already claimed.
        """
        now = datetime.now(UTC)
        pairing = await self.session.scalar(
            select(ConnectorPairing)
            .where(
                ConnectorPairing.user_code == user_code,
                ConnectorPairing.expires_at > now,
                ConnectorPairing.delivered_at.is_(None),
            )
            .order_by(ConnectorPairing.created_at.desc())
            .limit(1)
            .with_for_update()
        )
        if pairing is None:
            raise NotFound("pairing_not_found", "No connector shows this code; check it or restart the connector")
        if pairing.claimed_at is not None:
            raise Unprocessable("pairing_claimed", "This code was already entered")
        pairing.site_id = site_id
        pairing.claimed_by_id = self.actor.id if self.actor is not None else None
        pairing.claimed_at = now
        if name:
            pairing.name = name.strip()
        await self.session.commit()
        return self.read(pairing, None, now)

    async def status(self, site_id: int, uuid: UUID) -> PairingRead:
        """Follow a pairing claimed for a site until the connector picks up its token.

        Args:
            site_id: Database id of the request's site.
            uuid: Public id of the pairing.

        Returns:
            The pairing.

        Raises:
            NotFound: The pairing was not claimed for the site.
        """
        row = (
            await self.session.execute(
                select(ConnectorPairing, Connector.uuid)
                .outerjoin(Connector, Connector.id == ConnectorPairing.connector_id)
                .where(ConnectorPairing.uuid == uuid, ConnectorPairing.site_id == site_id)
            )
        ).first()
        if row is None:
            raise NotFound("pairing_not_found", f"Pairing {uuid} does not exist")
        return self.read(row[0], row[1], datetime.now(UTC))
