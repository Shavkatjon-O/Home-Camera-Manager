"""Which sites a user may reach, with which role, and the site a request acts on."""

from dataclasses import dataclass
from uuid import UUID

from sqlalchemy import and_, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.core.exceptions import Forbidden, NotFound
from app.models import Membership, MembershipSite, Organisation, Site
from app.modules.tenancy.enums import Role, role_rank

__all__ = [
    "OrganisationAccess",
    "SiteAccess",
    "accessible_sites",
    "check_role",
    "resolve_organisation_access",
    "resolve_site_access",
]


@dataclass(frozen=True)
class SiteAccess:
    """A member acting on one site.

    Attributes:
        user: The member.
        organisation_id: Database id of the site's organisation.
        organisation_uuid: Public id of that organisation.
        site_id: Database id of the site.
        site_uuid: Public id of the site.
        site_name: Name of the site.
        role: The member's role in the organisation.
        timezone: Time zone of the site.
        faces_enabled: Whether the organisation has face recognition on.
    """

    user: UserContext
    organisation_id: int
    organisation_uuid: UUID
    site_id: int
    site_uuid: UUID
    site_name: str
    role: Role
    timezone: str
    faces_enabled: bool

    def allows(self, role: Role) -> bool:
        """Tell whether the member's role reaches a role.

        Args:
            role: The least role needed.

        Returns:
            True when the member's role is that role or a stronger one.
        """
        return role_rank(self.role) >= role_rank(role)


@dataclass(frozen=True)
class OrganisationAccess:
    """A member acting on an organisation.

    Attributes:
        user: The member.
        organisation: The organisation.
        membership: The member's membership.
        role: The member's role.
        site_ids: Sites the membership covers, or None when it covers every site.
    """

    user: UserContext
    organisation: Organisation
    membership: Membership
    role: Role
    site_ids: frozenset[int] | None

    def allows(self, role: Role) -> bool:
        """Tell whether the member's role reaches a role.

        Args:
            role: The least role needed.

        Returns:
            True when the member's role is that role or a stronger one.
        """
        return role_rank(self.role) >= role_rank(role)


def check_role(role: Role, needed: Role) -> None:
    """Refuse a member whose role is weaker than needed.

    Args:
        role: The member's role.
        needed: The least role needed.

    Raises:
        Forbidden: The role is weaker.
    """
    if role_rank(role) < role_rank(needed):
        raise Forbidden("role_required", f"This needs the {needed.value} role or a stronger one")


def refuse_suspended(organisation: Organisation) -> None:
    """Refuse members of an organisation a platform admin suspended.

    Args:
        organisation: The organisation.

    Raises:
        Forbidden: The organisation is suspended.
    """
    if organisation.suspended_at is not None:
        raise Forbidden("organisation_suspended", "This organisation is suspended; contact support")


def site_rows(user_id: int):
    """Build the query of the sites a user's memberships cover, in a stable order.

    Args:
        user_id: Database id of the user.

    Returns:
        Select of site, membership and organisation rows.
    """
    covered = select(MembershipSite.id).where(
        MembershipSite.membership_id == Membership.id, MembershipSite.site_id == Site.id
    )
    return (
        select(Site, Membership, Organisation)
        .join(Organisation, and_(Organisation.id == Site.organisation_id, Organisation.deleted_at.is_(None)))
        .join(Membership, and_(Membership.organisation_id == Organisation.id, Membership.user_id == user_id))
        .where(Site.deleted_at.is_(None), or_(Membership.all_sites, covered.exists()))
        .order_by(Organisation.created_at, Organisation.id, Site.position, Site.id)
    )


async def accessible_sites(session: AsyncSession, user_id: int) -> list[tuple[Site, Membership, Organisation]]:
    """List every site a user may reach.

    Args:
        session: Database session.
        user_id: Database id of the user.

    Returns:
        Site, membership and organisation of each reachable site, by organisation and site order.
    """
    return [tuple(row) for row in (await session.execute(site_rows(user_id))).all()]


async def resolve_site_access(
    session: AsyncSession, user: UserContext, site_uuid: UUID | None, strict: bool = True
) -> SiteAccess:
    """Find the site a request acts on and the member's role there.

    Args:
        session: Database session.
        user: The signed-in user.
        site_uuid: Site the request names, or None for the user's first site.
        strict: Whether a named site the user cannot reach is an error; otherwise the first site is used.

    Returns:
        The access.

    Raises:
        NotFound: The named site does not exist or the user may not reach it, in strict mode.
        Forbidden: The user may not reach any site yet.
    """
    row = None
    if site_uuid is not None:
        row = (await session.execute(site_rows(user.id).where(Site.uuid == site_uuid).limit(1))).first()
        if row is None and strict:
            raise NotFound("site_not_found", f"Site {site_uuid} does not exist")
    if row is None:
        row = (await session.execute(site_rows(user.id).limit(1))).first()
    if row is None:
        raise Forbidden("no_site", "Create an organisation with a site, or accept an invitation, first")
    site, membership, organisation = row
    refuse_suspended(organisation)
    return SiteAccess(
        user=user,
        organisation_id=organisation.id,
        organisation_uuid=organisation.uuid,
        site_id=site.id,
        site_uuid=site.uuid,
        site_name=site.name,
        role=Role(membership.role),
        timezone=site.timezone,
        faces_enabled=organisation.faces_enabled,
    )


async def resolve_organisation_access(
    session: AsyncSession, user: UserContext, organisation_uuid: UUID, needed: Role = Role.VIEWER
) -> OrganisationAccess:
    """Find a member's membership of an organisation and check its role.

    Args:
        session: Database session.
        user: The signed-in user.
        organisation_uuid: Public id of the organisation.
        needed: The least role needed.

    Returns:
        The access.

    Raises:
        NotFound: The organisation does not exist or the user is not a member.
        Forbidden: The member's role is weaker than needed.
    """
    row = (
        await session.execute(
            select(Organisation, Membership)
            .join(Membership, Membership.organisation_id == Organisation.id)
            .where(
                Organisation.uuid == organisation_uuid,
                Organisation.deleted_at.is_(None),
                Membership.user_id == user.id,
            )
        )
    ).first()
    if row is None:
        raise NotFound("organisation_not_found", f"Organisation {organisation_uuid} does not exist")
    organisation, membership = row
    refuse_suspended(organisation)
    role = Role(membership.role)
    check_role(role, needed)
    site_ids = None
    if not membership.all_sites:
        rows = await session.scalars(
            select(MembershipSite.site_id).where(MembershipSite.membership_id == membership.id)
        )
        site_ids = frozenset(rows)
    return OrganisationAccess(user=user, organisation=organisation, membership=membership, role=role, site_ids=site_ids)
