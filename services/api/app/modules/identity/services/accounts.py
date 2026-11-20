"""Accounts: sign-up, email confirmation, password reset and change, profile and deletion."""

from datetime import UTC, datetime, timedelta
from uuid import uuid4

from sqlalchemy import delete, select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.core.config import settings
from app.core.exceptions import Conflict, Forbidden, NotFound, Unauthorized, Unprocessable
from app.core.mail import Mailer, mailer, reset_mail, verify_mail
from app.core.security import hash_password, hash_token, new_token, verify_password
from app.models import EmailToken, User
from app.modules.identity.schemas import AccountRead, AccountRegister
from app.modules.identity.services.tokens import revoke_user_sessions
from app.modules.tenancy.services.memberships import release_memberships

__all__ = ["VERIFY", "RESET", "AccountService", "account_read"]

VERIFY = "verify"
RESET = "reset"


def account_read(user: User) -> AccountRead:
    """Build the API view of an account.

    Args:
        user: The user.

    Returns:
        The account.
    """
    return AccountRead(
        uuid=user.uuid,
        username=user.username,
        email=user.email,
        name=user.name,
        email_verified=user.email is None or user.email_verified_at is not None,
        created_at=user.created_at,
    )


class AccountService:
    """Creates and maintains accounts.

    Attributes:
        session: Database session.
        actor: Signed-in user, for the routes that need one.
        mail: Mailer the confirmation and reset links go through.
    """

    def __init__(self, session: AsyncSession, actor: UserContext | None = None, mail: Mailer = mailer):
        """Bind the service to a database session.

        Args:
            session: Database session.
            actor: Signed-in user, if any.
            mail: Mailer of outgoing mail.
        """
        self.session = session
        self.actor = actor
        self.mail = mail

    async def user(self) -> User:
        """Load the signed-in user.

        Returns:
            The user.

        Raises:
            Unauthorized: The account is gone.
        """
        user = await self.session.scalar(select(User).where(User.id == self.actor.id, User.deleted_at.is_(None)))
        if user is None:
            raise Unauthorized("not_authenticated", "Sign in to continue")
        return user

    async def issue(self, user: User, purpose: str, lifetime: timedelta) -> str:
        """Store a new email token for a user.

        Args:
            user: The user.
            purpose: verify or reset.
            lifetime: How long the token stays valid.

        Returns:
            The plain token.
        """
        token = new_token()
        self.session.add(
            EmailToken(
                user_id=user.id,
                purpose=purpose,
                token_hash=hash_token(token),
                expires_at=datetime.now(UTC) + lifetime,
            )
        )
        return token

    async def redeem(self, token: str, purpose: str) -> User:
        """Spend an email token and return its user.

        Every other unused token of the same purpose of that user is spent with it.

        Args:
            token: The plain token.
            purpose: verify or reset.

        Returns:
            The user.

        Raises:
            Unprocessable: The token is unknown, used or expired.
        """
        now = datetime.now(UTC)
        row = (
            await self.session.execute(
                select(EmailToken, User)
                .join(User, User.id == EmailToken.user_id)
                .where(EmailToken.token_hash == hash_token(token), EmailToken.purpose == purpose)
                .with_for_update(of=EmailToken)
            )
        ).first()
        if row is None or row[0].used_at is not None or row[0].expires_at <= now or row[1].deleted_at is not None:
            raise Unprocessable("invalid_token", "The link is not valid any more; ask for a new one")
        stored, user = row
        await self.session.execute(
            update(EmailToken)
            .where(EmailToken.user_id == user.id, EmailToken.purpose == purpose, EmailToken.used_at.is_(None))
            .values(used_at=now)
        )
        stored.used_at = now
        return user

    async def register(self, payload: AccountRegister) -> AccountRead:
        """Create an account and mail its confirmation link.

        Args:
            payload: The new account.

        Returns:
            The account, not yet confirmed.

        Raises:
            Forbidden: Sign-up is turned off.
            Conflict: An account already uses the address.
        """
        if not settings.registration_enabled:
            raise Forbidden("registration_closed", "New accounts cannot be created here")
        taken = await self.session.scalar(
            select(User.id).where((User.email == payload.email) | (User.username == payload.email)).limit(1)
        )
        if taken is not None:
            raise Conflict("email_taken", "An account with this email address already exists")
        user = User(
            username=payload.email,
            email=payload.email,
            name=payload.name,
            password_hash=hash_password(payload.password),
        )
        self.session.add(user)
        await self.session.flush()
        token = await self.issue(user, VERIFY, timedelta(hours=settings.verify_token_hours))
        await self.session.commit()
        await self.session.refresh(user)
        await self.mail.send(verify_mail(user.email, user.name, token))
        return account_read(user)

    async def resend(self, email: str) -> None:
        """Mail a new confirmation link to an unconfirmed account.

        Nothing is sent for an unknown or confirmed address, and the answer is the same either way.

        Args:
            email: The address.
        """
        user = await self.session.scalar(select(User).where(User.email == email, User.deleted_at.is_(None)))
        if user is None or user.email_verified_at is not None:
            return
        token = await self.issue(user, VERIFY, timedelta(hours=settings.verify_token_hours))
        await self.session.commit()
        await self.mail.send(verify_mail(user.email, user.name, token))

    async def verify(self, token: str) -> AccountRead:
        """Confirm an email address with the token from its link.

        Args:
            token: The token.

        Returns:
            The confirmed account.
        """
        user = await self.redeem(token, VERIFY)
        if user.email_verified_at is None:
            user.email_verified_at = datetime.now(UTC)
        await self.session.commit()
        await self.session.refresh(user)
        return account_read(user)

    async def forgot(self, email: str) -> None:
        """Mail a password reset link, answering the same whether or not the address has an account.

        Args:
            email: The address.
        """
        user = await self.session.scalar(select(User).where(User.email == email, User.deleted_at.is_(None)))
        if user is None:
            return
        token = await self.issue(user, RESET, timedelta(minutes=settings.reset_token_minutes))
        await self.session.commit()
        await self.mail.send(reset_mail(user.email, token))

    async def reset(self, token: str, password: str) -> None:
        """Set a new password with a reset token and end every device session of the account.

        A reset also confirms the address, since the link reached it.

        Args:
            token: The token.
            password: The new password.
        """
        user = await self.redeem(token, RESET)
        now = datetime.now(UTC)
        user.password_hash = hash_password(password)
        if user.email_verified_at is None:
            user.email_verified_at = now
        await revoke_user_sessions(self.session, user.id, "password_reset", now=now)
        await self.session.commit()

    async def change_password(self, current: str, new: str) -> None:
        """Change the signed-in user's password and end their other device sessions.

        Args:
            current: Current password.
            new: New password.

        Raises:
            Unauthorized: The current password is wrong.
        """
        user = await self.user()
        if not verify_password(user.password_hash, current):
            raise Unauthorized("invalid_credentials", "The current password is wrong")
        user.password_hash = hash_password(new)
        await revoke_user_sessions(self.session, user.id, "password_changed", keep_id=self.actor.session_id)
        await self.session.commit()

    async def read(self) -> AccountRead:
        """Return the signed-in user's account.

        Returns:
            The account.
        """
        return account_read(await self.user())

    async def update(self, name: str | None) -> AccountRead:
        """Change the signed-in user's display name.

        Args:
            name: New name; blank removes it.

        Returns:
            The account.
        """
        user = await self.user()
        user.name = (name or "").strip() or None
        await self.session.commit()
        await self.session.refresh(user)
        return account_read(user)

    async def delete(self, password: str) -> None:
        """Delete the signed-in account.

        The account's memberships end, organisations it alone belonged to are deleted, every device session ends,
        and the row keeps no email address, name or usable password.

        Args:
            password: Current password, to confirm.

        Raises:
            Unauthorized: The password is wrong.
            Conflict: The account owns an organisation that has other members; ownership must pass on first.
        """
        user = await self.user()
        if not verify_password(user.password_hash, password):
            raise Unauthorized("invalid_credentials", "The password is wrong")
        now = datetime.now(UTC)
        await release_memberships(self.session, user.id, now)
        await revoke_user_sessions(self.session, user.id, "account_deleted", now=now)
        await self.session.execute(delete(EmailToken).where(EmailToken.user_id == user.id))
        user.username = f"deleted-{user.uuid.hex}"
        user.email = None
        user.name = None
        user.email_verified_at = None
        user.password_hash = hash_password(uuid4().hex)
        user.deleted_at = now
        await self.session.commit()


async def lookup_user(session: AsyncSession, user_id: int) -> User:
    """Load a live user by database id.

    Args:
        session: Database session.
        user_id: Database id.

    Returns:
        The user.

    Raises:
        NotFound: No live user has that id.
    """
    user = await session.scalar(select(User).where(User.id == user_id, User.deleted_at.is_(None)))
    if user is None:
        raise NotFound("user_not_found", f"User {user_id} does not exist")
    return user
