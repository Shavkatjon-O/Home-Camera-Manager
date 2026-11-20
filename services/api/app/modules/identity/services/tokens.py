"""Device sessions of the apps: token pairs, refresh rotation with reuse detection, and revocation."""

import logging
from datetime import UTC, datetime, timedelta
from uuid import UUID

from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.core.config import settings
from app.core.exceptions import NotFound, Unauthorized
from app.core.security import hash_token, new_token
from app.core.tokens import create_access_token
from app.models import AuthSession, PushTarget, RefreshToken, User
from app.modules.identity.schemas import SessionList, SessionRead, TokenPair

__all__ = ["REVOKE_REASONS", "TokenService", "revoke_user_sessions"]

logger = logging.getLogger(__name__)

REVOKE_REASONS = ("signed_out", "revoked", "reuse", "password_changed", "password_reset", "account_deleted")


def session_read(session: AuthSession, current_id: int | None = None) -> SessionRead:
    """Build the API view of a device session.

    Args:
        session: The session row.
        current_id: Database id of the session making the request, if any.

    Returns:
        The session.
    """
    return SessionRead(
        uuid=session.uuid,
        name=session.name,
        platform=session.platform,
        created_at=session.created_at,
        last_used_at=session.last_used_at,
        expires_at=session.expires_at,
        current=session.id == current_id,
    )


async def revoke_user_sessions(
    db: AsyncSession, user_id: int, reason: str, keep_id: int | None = None, now: datetime | None = None
) -> None:
    """End every live device session of a user and drop their push targets.

    Args:
        db: Database session; the caller commits.
        user_id: Database id of the user.
        reason: Reason stored on the sessions.
        keep_id: Session to leave alive, such as the one changing the password.
        now: Time of the revocation.
    """
    moment = now or datetime.now(UTC)
    condition = [AuthSession.user_id == user_id, AuthSession.revoked_at.is_(None)]
    if keep_id is not None:
        condition.append(AuthSession.id != keep_id)
    ended = select(AuthSession.id).where(*condition)
    await db.execute(
        PushTarget.__table__.delete().where(PushTarget.session_id.in_(ended)),
    )
    await db.execute(update(AuthSession).where(*condition).values(revoked_at=moment, revoke_reason=reason))


class TokenService:
    """Opens device sessions and rotates their refresh tokens.

    Attributes:
        session: Database session.
        actor: Signed-in user, for the routes that need one.
    """

    def __init__(self, session: AsyncSession, actor: UserContext | None = None):
        """Bind the service to a database session.

        Args:
            session: Database session.
            actor: Signed-in user, if any.
        """
        self.session = session
        self.actor = actor

    def refresh_lifetime(self) -> timedelta:
        """Return how long a refresh token stays valid unused.

        Returns:
            The idle lifetime.
        """
        return timedelta(days=settings.refresh_idle_days)

    async def new_refresh_token(self, device: AuthSession, now: datetime) -> tuple[str, int]:
        """Store a new refresh token for a session.

        Args:
            device: The session.
            now: Current time.

        Returns:
            The plain token and the seconds it stays valid.
        """
        token = new_token()
        expires_at = min(now + self.refresh_lifetime(), device.expires_at)
        self.session.add(RefreshToken(session_id=device.id, token_hash=hash_token(token), expires_at=expires_at))
        return token, max(0, int((expires_at - now).total_seconds()))

    async def pair(self, user: User, device: AuthSession, now: datetime) -> TokenPair:
        """Issue an access token and a new refresh token for a session.

        Args:
            user: The user.
            device: The session.
            now: Current time.

        Returns:
            The token pair; the caller commits.
        """
        refresh, refresh_seconds = await self.new_refresh_token(device, now)
        access, access_seconds = create_access_token(user.uuid, device.uuid, now)
        return TokenPair(
            access_token=access,
            expires_in=access_seconds,
            refresh_token=refresh,
            refresh_expires_in=refresh_seconds,
            session=session_read(device, device.id),
        )

    async def open(self, user: User, device_name: str, platform: str) -> TokenPair:
        """Open a device session for a user whose credentials were checked.

        Args:
            user: The user.
            device_name: Name of the device.
            platform: Platform of the app.

        Returns:
            The first token pair of the session.
        """
        now = datetime.now(UTC)
        device = AuthSession(
            user_id=user.id,
            name=device_name.strip() or "Phone",
            platform=platform.strip().lower() or "android",
            last_used_at=now,
            expires_at=now + timedelta(days=settings.refresh_max_days),
        )
        self.session.add(device)
        await self.session.flush()
        result = await self.pair(user, device, now)
        await self.session.commit()
        return result

    async def refresh(self, token: str) -> TokenPair:
        """Exchange a refresh token for a new pair, revoking the whole session when an old token comes back.

        Args:
            token: The refresh token.

        Returns:
            The new token pair.

        Raises:
            Unauthorized: The token is unknown or expired, its session has ended, or it was already used, in which
                case the session is revoked.
        """
        now = datetime.now(UTC)
        row = (
            await self.session.execute(
                select(RefreshToken, AuthSession, User)
                .join(AuthSession, AuthSession.id == RefreshToken.session_id)
                .join(User, User.id == AuthSession.user_id)
                .where(RefreshToken.token_hash == hash_token(token))
                .with_for_update(of=[RefreshToken, AuthSession])
            )
        ).first()
        if row is None:
            raise Unauthorized("invalid_refresh_token", "The refresh token is not valid")
        stored, device, user = row
        if device.revoked_at is not None or user.deleted_at is not None:
            raise Unauthorized("session_revoked", "The session has ended; sign in again")
        if stored.used_at is not None:
            await revoke_user_sessions_by_id(self.session, device.id, now)
            await self.session.commit()
            logger.warning("A used refresh token of session %s came back; the session is revoked", device.uuid)
            raise Unauthorized("refresh_token_reused", "The refresh token was already used; the session is revoked")
        if stored.expires_at <= now or device.expires_at <= now:
            raise Unauthorized("refresh_token_expired", "The session has expired; sign in again")
        stored.used_at = now
        device.last_used_at = now
        result = await self.pair(user, device, now)
        await self.session.commit()
        return result

    async def revoke_current(self) -> None:
        """End the device session the request was made with.

        Raises:
            Unauthorized: The request was not made with a device session.
        """
        if self.actor is None or self.actor.session_id is None:
            raise Unauthorized("not_a_device_session", "Only an app session can be ended this way")
        await revoke_user_sessions_by_id(self.session, self.actor.session_id, datetime.now(UTC), "signed_out")
        await self.session.commit()

    async def list(self) -> SessionList:
        """List the live device sessions of the signed-in user.

        Returns:
            The sessions, newest first.
        """
        now = datetime.now(UTC)
        rows = await self.session.scalars(
            select(AuthSession)
            .where(
                AuthSession.user_id == self.actor.id,
                AuthSession.revoked_at.is_(None),
                AuthSession.expires_at > now,
            )
            .order_by(AuthSession.created_at.desc(), AuthSession.id.desc())
        )
        return SessionList(items=[session_read(row, self.actor.session_id) for row in rows])

    async def revoke(self, uuid: UUID) -> None:
        """End one device session of the signed-in user.

        Args:
            uuid: Public id of the session.

        Raises:
            NotFound: The user has no live session with that id.
        """
        device = await self.session.scalar(
            select(AuthSession).where(
                AuthSession.uuid == uuid, AuthSession.user_id == self.actor.id, AuthSession.revoked_at.is_(None)
            )
        )
        if device is None:
            raise NotFound("session_not_found", f"Session {uuid} does not exist")
        await revoke_user_sessions_by_id(self.session, device.id, datetime.now(UTC), "revoked")
        await self.session.commit()


async def revoke_user_sessions_by_id(db: AsyncSession, session_id: int, now: datetime, reason: str = "reuse") -> None:
    """End one device session and drop its push targets.

    Args:
        db: Database session; the caller commits.
        session_id: Database id of the device session.
        now: Time of the revocation.
        reason: Reason stored on the session.
    """
    await db.execute(PushTarget.__table__.delete().where(PushTarget.session_id == session_id))
    await db.execute(
        update(AuthSession)
        .where(AuthSession.id == session_id, AuthSession.revoked_at.is_(None))
        .values(revoked_at=now, revoke_reason=reason)
    )
