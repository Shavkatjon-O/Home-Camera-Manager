"""Members: listing, changing roles and sites, and removing members."""

from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.core.exceptions import Forbidden, NotFound
from app.models import Membership, User
from app.modules.organisations.enums import Role
from app.modules.organisations.schemas import MemberList, MemberRead, MemberUpdate
from app.modules.organisations.services.memberships import membership_site_uuids, set_membership_sites
from app.tenancy.access import OrganisationAccess, check_role, resolve_organisation_access

__all__ = ["MemberService"]


class MemberService:
    """Maintains the members of an organisation.

    Attributes:
        session: Database session.
        actor: Signed-in user.
    """

    def __init__(self, session: AsyncSession, actor: UserContext):
        """Bind the service to a database session and the signed-in user.

        Args:
            session: Database session.
            actor: Signed-in user.
        """
        self.session = session
        self.actor = actor

    async def reads(self, rows: list[tuple[Membership, User]]) -> list[MemberRead]:
        """Build the API views of memberships.

        Args:
            rows: Membership and user of each member.

        Returns:
            The members in the given order.
        """
        sites = await membership_site_uuids(
            self.session, [membership.id for membership, _ in rows if not membership.all_sites]
        )
        return [
            MemberRead(
                uuid=membership.uuid,
                user=user.uuid,
                email=user.email,
                name=user.name,
                role=Role(membership.role),
                all_sites=membership.all_sites,
                sites=[] if membership.all_sites else sites.get(membership.id, []),
                joined_at=membership.created_at,
                you=user.id == self.actor.id,
            )
            for membership, user in rows
        ]

    async def member(self, access: OrganisationAccess, member_uuid: UUID) -> tuple[Membership, User]:
        """Load a membership of the organisation with its user.

        Args:
            access: The caller's access.
            member_uuid: Public id of the membership.

        Returns:
            Membership and user.

        Raises:
            NotFound: The membership is not one of this organisation.
        """
        row = (
            await self.session.execute(
                select(Membership, User)
                .join(User, User.id == Membership.user_id)
                .where(Membership.uuid == member_uuid, Membership.organisation_id == access.organisation.id)
            )
        ).first()
        if row is None:
            raise NotFound("member_not_found", f"Member {member_uuid} does not exist")
        return row[0], row[1]

    async def list(self, organisation_uuid: UUID) -> MemberList:
        """List the members of an organisation.

        Args:
            organisation_uuid: Public id of the organisation.

        Returns:
            The members, oldest first.
        """
        access = await resolve_organisation_access(self.session, self.actor, organisation_uuid, Role.ADMIN)
        rows = (
            await self.session.execute(
                select(Membership, User)
                .join(User, User.id == Membership.user_id)
                .where(Membership.organisation_id == access.organisation.id)
                .order_by(Membership.created_at, Membership.id)
            )
        ).all()
        return MemberList(items=await self.reads([tuple(row) for row in rows]))

    async def update(self, organisation_uuid: UUID, member_uuid: UUID, payload: MemberUpdate) -> MemberRead:
        """Change a member's role or the sites the membership covers.

        Owners change only through a transfer of ownership, and nobody can make a member an owner here.

        Args:
            organisation_uuid: Public id of the organisation.
            member_uuid: Public id of the membership.
            payload: Fields to change.

        Returns:
            The member.

        Raises:
            Forbidden: The member is the owner, or the new role is owner.
        """
        access = await resolve_organisation_access(self.session, self.actor, organisation_uuid, Role.ADMIN)
        membership, user = await self.member(access, member_uuid)
        if membership.role == Role.OWNER.value:
            raise Forbidden("owner_protected", "The owner changes only through a transfer of ownership")
        if payload.role == Role.OWNER:
            raise Forbidden("owner_protected", "Make a member the owner through a transfer of ownership")
        if payload.role is not None:
            membership.role = payload.role.value
        if payload.all_sites is not None or payload.sites is not None:
            all_sites = payload.all_sites if payload.all_sites is not None else membership.all_sites
            current = (await membership_site_uuids(self.session, [membership.id])).get(membership.id, [])
            await set_membership_sites(self.session, membership, all_sites, payload.sites or current)
        await self.session.commit()
        await self.session.refresh(membership)
        return (await self.reads([(membership, user)]))[0]

    async def remove(self, organisation_uuid: UUID, member_uuid: UUID) -> None:
        """Remove a member, or let a member leave.

        Args:
            organisation_uuid: Public id of the organisation.
            member_uuid: Public id of the membership.

        Raises:
            Forbidden: The member is the owner, or the caller is not an admin removing someone else.
        """
        access = await resolve_organisation_access(self.session, self.actor, organisation_uuid)
        membership, _ = await self.member(access, member_uuid)
        if membership.role == Role.OWNER.value:
            raise Forbidden("owner_protected", "The owner cannot leave; transfer the ownership first")
        if membership.id != access.membership.id:
            check_role(access.role, Role.ADMIN)
        await self.session.delete(membership)
        await self.session.commit()
