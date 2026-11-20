"""Invitations: single-use links that add a member with a role and a site scope."""

from datetime import UTC, datetime, timedelta
from uuid import UUID

from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.core.config import settings
from app.core.exceptions import Conflict, Forbidden, NotFound, Unprocessable
from app.core.mail import Mailer, invitation_mail, mailer
from app.core.security import hash_token, new_token
from app.models import Invitation, Membership, Organisation, Site, User
from app.modules.tenancy.enums import Role
from app.modules.tenancy.schemas import (
    InvitationCreate,
    InvitationList,
    InvitationPreview,
    InvitationRead,
    InvitationStatus,
)
from app.modules.tenancy.services.access import resolve_organisation_access
from app.modules.tenancy.services.memberships import set_membership_sites

__all__ = ["InvitationService", "invitation_status"]


def invitation_status(invitation: Invitation, now: datetime) -> InvitationStatus:
    """Tell the state of an invitation.

    Args:
        invitation: The invitation.
        now: Current time.

    Returns:
        accepted, revoked, expired or pending.
    """
    if invitation.accepted_at is not None:
        return InvitationStatus.ACCEPTED
    if invitation.revoked_at is not None:
        return InvitationStatus.REVOKED
    if invitation.expires_at <= now:
        return InvitationStatus.EXPIRED
    return InvitationStatus.PENDING


def display_name(user: User | None) -> str | None:
    """Return how a user is named to others.

    Args:
        user: The user, if any.

    Returns:
        The name, else the email address, else the sign-in name.
    """
    if user is None:
        return None
    return user.name or user.email or user.username


class InvitationService:
    """Sends, lists, withdraws and accepts invitations.

    Attributes:
        session: Database session.
        actor: Signed-in user, if any.
        mail: Mailer the invitation links go through.
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

    def read(self, invitation: Invitation, inviter: User | None, now: datetime) -> InvitationRead:
        """Build the admin view of an invitation.

        Args:
            invitation: The invitation.
            inviter: Member who sent it, if still known.
            now: Current time.

        Returns:
            The invitation.
        """
        return InvitationRead(
            uuid=invitation.uuid,
            email=invitation.email,
            role=Role(invitation.role),
            all_sites=invitation.all_sites,
            sites=[UUID(value) for value in invitation.site_uuids],
            status=invitation_status(invitation, now),
            expires_at=invitation.expires_at,
            invited_by=display_name(inviter),
            created_at=invitation.created_at,
            accepted_at=invitation.accepted_at,
        )

    async def list(self, organisation_uuid: UUID) -> InvitationList:
        """List the invitations of an organisation.

        Args:
            organisation_uuid: Public id of the organisation.

        Returns:
            The invitations, newest first.
        """
        access = await resolve_organisation_access(self.session, self.actor, organisation_uuid, Role.ADMIN)
        rows = (
            await self.session.execute(
                select(Invitation, User)
                .outerjoin(User, User.id == Invitation.invited_by_id)
                .where(Invitation.organisation_id == access.organisation.id)
                .order_by(Invitation.created_at.desc(), Invitation.id.desc())
            )
        ).all()
        now = datetime.now(UTC)
        return InvitationList(items=[self.read(invitation, inviter, now) for invitation, inviter in rows])

    async def create(self, organisation_uuid: UUID, payload: InvitationCreate) -> InvitationRead:
        """Invite an address into an organisation and mail it the link.

        A pending invitation of the same address is withdrawn, so only the newest link works.

        Args:
            organisation_uuid: Public id of the organisation.
            payload: The invitation.

        Returns:
            The invitation.

        Raises:
            Conflict: The address already belongs to a member.
            Unprocessable: A listed site is not a site of the organisation.
        """
        access = await resolve_organisation_access(self.session, self.actor, organisation_uuid, Role.ADMIN)
        organisation = access.organisation
        member = await self.session.scalar(
            select(Membership.id)
            .join(User, User.id == Membership.user_id)
            .where(Membership.organisation_id == organisation.id, User.email == payload.email)
        )
        if member is not None:
            raise Conflict("already_member", f"{payload.email} is already a member")
        site_uuids: list[str] = []
        if not payload.all_sites:
            wanted = set(payload.sites)
            found = set(
                await self.session.scalars(
                    select(Site.uuid).where(
                        Site.uuid.in_(wanted), Site.organisation_id == organisation.id, Site.deleted_at.is_(None)
                    )
                )
            )
            missing = wanted - found
            if missing:
                raise Unprocessable("site_not_found", f"Site {sorted(missing)[0]} is not a site of this organisation")
            site_uuids = [str(value) for value in payload.sites]
        now = datetime.now(UTC)
        await self.session.execute(
            update(Invitation)
            .where(
                Invitation.organisation_id == organisation.id,
                Invitation.email == payload.email,
                Invitation.accepted_at.is_(None),
                Invitation.revoked_at.is_(None),
            )
            .values(revoked_at=now)
        )
        token = new_token()
        invitation = Invitation(
            organisation_id=organisation.id,
            email=payload.email,
            role=payload.role.value,
            all_sites=payload.all_sites,
            site_uuids=site_uuids,
            token_hash=hash_token(token),
            expires_at=now + timedelta(days=settings.invitation_days),
            invited_by_id=self.actor.id,
        )
        self.session.add(invitation)
        await self.session.commit()
        await self.session.refresh(invitation)
        inviter = await self.session.get(User, self.actor.id)
        await self.mail.send(
            invitation_mail(payload.email, organisation.name, display_name(inviter) or "A member", payload.role, token)
        )
        return self.read(invitation, inviter, now)

    async def revoke(self, organisation_uuid: UUID, invitation_uuid: UUID) -> None:
        """Withdraw a pending invitation.

        Args:
            organisation_uuid: Public id of the organisation.
            invitation_uuid: Public id of the invitation.

        Raises:
            NotFound: The invitation is not one of this organisation.
        """
        access = await resolve_organisation_access(self.session, self.actor, organisation_uuid, Role.ADMIN)
        invitation = await self.session.scalar(
            select(Invitation).where(
                Invitation.uuid == invitation_uuid, Invitation.organisation_id == access.organisation.id
            )
        )
        if invitation is None:
            raise NotFound("invitation_not_found", f"Invitation {invitation_uuid} does not exist")
        if invitation.accepted_at is None and invitation.revoked_at is None:
            invitation.revoked_at = datetime.now(UTC)
        await self.session.commit()

    async def by_token(self, token: str, lock: bool = False) -> tuple[Invitation, Organisation, User | None]:
        """Load an invitation by the token of its link.

        Args:
            token: The token.
            lock: Whether to lock the invitation row.

        Returns:
            Invitation, organisation and inviter.

        Raises:
            NotFound: No invitation has the token, or its organisation is gone.
        """
        query = (
            select(Invitation, Organisation, User)
            .join(Organisation, Organisation.id == Invitation.organisation_id)
            .outerjoin(User, User.id == Invitation.invited_by_id)
            .where(Invitation.token_hash == hash_token(token), Organisation.deleted_at.is_(None))
        )
        if lock:
            query = query.with_for_update(of=Invitation)
        row = (await self.session.execute(query)).first()
        if row is None:
            raise NotFound("invitation_not_found", "The invitation link is not valid")
        return row[0], row[1], row[2]

    async def preview(self, token: str) -> InvitationPreview:
        """Describe an invitation before it is accepted.

        Args:
            token: The token.

        Returns:
            What the invitation offers.
        """
        invitation, organisation, inviter = await self.by_token(token)
        return InvitationPreview(
            organisation=organisation.name,
            role=Role(invitation.role),
            invited_by=display_name(inviter),
            email=invitation.email,
            status=invitation_status(invitation, datetime.now(UTC)),
            expires_at=invitation.expires_at,
        )

    async def accept(self, token: str) -> UUID:
        """Accept an invitation as the signed-in user, who must own its confirmed address.

        Args:
            token: The token.

        Returns:
            Public id of the organisation joined.

        Raises:
            Unprocessable: The invitation was used, withdrawn or has expired.
            Forbidden: The signed-in account does not own the invited address.
            Conflict: The user is already a member.
        """
        invitation, organisation, _ = await self.by_token(token, lock=True)
        now = datetime.now(UTC)
        status = invitation_status(invitation, now)
        if status != InvitationStatus.PENDING:
            raise Unprocessable("invitation_" + status.value, f"The invitation is {status.value}")
        user = await self.session.get(User, self.actor.id)
        if user is None or user.email != invitation.email or user.email_verified_at is None:
            raise Forbidden(
                "invitation_email_mismatch", "Sign in with the confirmed address the invitation was sent to"
            )
        existing = await self.session.scalar(
            select(Membership.id).where(Membership.user_id == user.id, Membership.organisation_id == organisation.id)
        )
        if existing is not None:
            raise Conflict("already_member", "You are already a member of this organisation")
        membership = Membership(
            user_id=user.id, organisation_id=organisation.id, role=invitation.role, all_sites=invitation.all_sites
        )
        self.session.add(membership)
        await self.session.flush()
        if not invitation.all_sites:
            await set_membership_sites(
                self.session, membership, False, [UUID(value) for value in invitation.site_uuids]
            )
        invitation.accepted_at = now
        invitation.accepted_by_id = user.id
        await self.session.commit()
        return organisation.uuid
