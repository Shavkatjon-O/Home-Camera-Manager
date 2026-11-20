"""Sites: listing what a member may reach, adding, changing and removing sites."""

from datetime import UTC, datetime
from uuid import UUID

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.core.exceptions import Forbidden
from app.models import Camera, Connector, Membership, Organisation, Site
from app.modules.tenancy.enums import Role, SiteKind
from app.modules.tenancy.schemas import SiteCreate, SiteList, SiteRead, SiteUpdate
from app.modules.tenancy.services.access import (
    accessible_sites,
    check_role,
    resolve_organisation_access,
    resolve_site_access,
)
from app.modules.tenancy.services.memberships import delete_site_rows

__all__ = ["SiteService", "site_counts", "site_reads"]


async def site_counts(session: AsyncSession, site_ids: list[int]) -> tuple[dict[int, int], dict[int, int]]:
    """Count the live cameras and paired connectors of sites.

    Args:
        session: Database session.
        site_ids: Database ids of the sites.

    Returns:
        Camera counts and connector counts by site id.
    """
    if not site_ids:
        return {}, {}
    cameras = await session.execute(
        select(Camera.site_id, func.count())
        .where(Camera.site_id.in_(site_ids), Camera.deleted_at.is_(None))
        .group_by(Camera.site_id)
    )
    connectors = await session.execute(
        select(Connector.site_id, func.count())
        .where(Connector.site_id.in_(site_ids), Connector.revoked_at.is_(None), Connector.deleted_at.is_(None))
        .group_by(Connector.site_id)
    )
    return dict(cameras.all()), dict(connectors.all())


async def site_reads(session: AsyncSession, rows: list[tuple[Site, Membership, Organisation]]) -> list[SiteRead]:
    """Build the API views of sites with their counts.

    Args:
        session: Database session.
        rows: Site, membership and organisation of each site.

    Returns:
        The sites in the given order.
    """
    cameras, connectors = await site_counts(session, [site.id for site, _, _ in rows])
    return [
        SiteRead(
            uuid=site.uuid,
            organisation=organisation.uuid,
            organisation_name=organisation.name,
            name=site.name,
            kind=SiteKind(site.kind),
            timezone=site.timezone,
            position=site.position,
            role=Role(membership.role),
            camera_count=cameras.get(site.id, 0),
            connector_count=connectors.get(site.id, 0),
            created_at=site.created_at,
            updated_at=site.updated_at,
        )
        for site, membership, organisation in rows
    ]


class SiteService:
    """Lists and maintains the sites of organisations.

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

    async def list_all(self) -> SiteList:
        """List every site the user may reach, across organisations.

        Returns:
            The sites.
        """
        return SiteList(items=await site_reads(self.session, await accessible_sites(self.session, self.actor.id)))

    async def list(self, organisation_uuid: UUID) -> SiteList:
        """List the sites of one organisation that the user may reach.

        Args:
            organisation_uuid: Public id of the organisation.

        Returns:
            The sites.
        """
        access = await resolve_organisation_access(self.session, self.actor, organisation_uuid)
        rows = [
            row for row in await accessible_sites(self.session, self.actor.id) if row[2].id == access.organisation.id
        ]
        return SiteList(items=await site_reads(self.session, rows))

    async def row(self, site_uuid: UUID) -> tuple[Site, Membership, Organisation]:
        """Load a site the user may reach with the user's membership.

        Args:
            site_uuid: Public id of the site.

        Returns:
            Site, membership and organisation.
        """
        access = await resolve_site_access(self.session, self.actor, site_uuid)
        site = await self.session.get(Site, access.site_id)
        organisation = await self.session.get(Organisation, access.organisation_id)
        membership = await self.session.scalar(
            select(Membership).where(Membership.user_id == self.actor.id, Membership.organisation_id == organisation.id)
        )
        return site, membership, organisation

    async def read(self, site_uuid: UUID) -> SiteRead:
        """Return one site.

        Args:
            site_uuid: Public id of the site.

        Returns:
            The site.
        """
        return (await site_reads(self.session, [await self.row(site_uuid)]))[0]

    async def create(self, organisation_uuid: UUID, payload: SiteCreate) -> SiteRead:
        """Add a site to an organisation.

        Args:
            organisation_uuid: Public id of the organisation.
            payload: The site.

        Returns:
            The new site.

        Raises:
            Forbidden: The member is not an admin covering every site.
        """
        access = await resolve_organisation_access(self.session, self.actor, organisation_uuid, Role.ADMIN)
        if access.site_ids is not None:
            raise Forbidden("all_sites_required", "Only an admin of every site can add sites")
        highest = await self.session.scalar(
            select(func.max(Site.position)).where(
                Site.organisation_id == access.organisation.id, Site.deleted_at.is_(None)
            )
        )
        site = Site(
            organisation_id=access.organisation.id,
            name=payload.name,
            kind=payload.kind.value,
            timezone=payload.timezone,
            position=(highest + 1) if highest is not None else 0,
        )
        self.session.add(site)
        await self.session.commit()
        await self.session.refresh(site)
        return (await site_reads(self.session, [(site, access.membership, access.organisation)]))[0]

    async def update(self, site_uuid: UUID, payload: SiteUpdate) -> SiteRead:
        """Change a site.

        Args:
            site_uuid: Public id of the site.
            payload: Fields to change.

        Returns:
            The site.
        """
        site, membership, organisation = await self.row(site_uuid)
        check_role(Role(membership.role), Role.ADMIN)
        changes = payload.model_dump(exclude_unset=True, exclude_none=True)
        for field, value in changes.items():
            setattr(site, field, value.value if isinstance(value, SiteKind) else value)
        await self.session.commit()
        await self.session.refresh(site)
        return (await site_reads(self.session, [(site, membership, organisation)]))[0]

    async def delete(self, site_uuid: UUID) -> None:
        """Remove a site with its cameras and connectors.

        Args:
            site_uuid: Public id of the site.

        Raises:
            Forbidden: The member is not an admin covering every site.
        """
        site, membership, organisation = await self.row(site_uuid)
        check_role(Role(membership.role), Role.ADMIN)
        if not membership.all_sites:
            raise Forbidden("all_sites_required", "Only an admin of every site can remove sites")
        await delete_site_rows(self.session, [site.id], datetime.now(UTC))
        await self.session.commit()
