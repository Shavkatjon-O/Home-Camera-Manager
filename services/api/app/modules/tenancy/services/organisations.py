"""Organisations: creating, listing, changing, deleting and handing over ownership."""

from datetime import UTC, datetime
from uuid import UUID

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.core.exceptions import NotFound, Unprocessable
from app.models import Membership, Organisation, Site
from app.modules.tenancy.enums import Role
from app.modules.tenancy.schemas import (
    FacesConsent,
    OrganisationCreate,
    OrganisationList,
    OrganisationRead,
    OrganisationUpdate,
)
from app.modules.tenancy.services.access import accessible_sites, resolve_organisation_access
from app.modules.tenancy.services.memberships import delete_organisation_rows
from app.modules.tenancy.services.sites import site_reads

__all__ = ["FACES_CONSENT", "OrganisationService"]

FACES_CONSENT = FacesConsent(
    version="2026-11-20",
    text=(
        "Face recognition compares the faces your cameras see with the people you add to this organisation's "
        "gallery. It stores face pictures and face measurements, which are biometric data. Turn it on only if "
        "everyone your cameras may see has been told about it and, where the law requires it, has agreed. "
        "Pictures and measurements stay with this organisation, are deleted with their events after the event "
        "retention, and a person's faces are deleted when the person is deleted. You can turn face recognition "
        "off at any time."
    ),
)


class OrganisationService:
    """Creates and maintains the organisations of the signed-in user.

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

    async def reads(self, organisations: list[tuple[Organisation, Membership]]) -> list[OrganisationRead]:
        """Build the API views of organisations with their reachable sites.

        Args:
            organisations: Organisation and the user's membership of each.

        Returns:
            The organisations in the given order.
        """
        sites = await accessible_sites(self.session, self.actor.id)
        reads = await site_reads(self.session, sites)
        by_organisation: dict[int, list] = {}
        for (site, _, organisation), read in zip(sites, reads):
            by_organisation.setdefault(organisation.id, []).append(read)
        ids = [organisation.id for organisation, _ in organisations]
        members = dict(
            (
                await self.session.execute(
                    select(Membership.organisation_id, func.count())
                    .where(Membership.organisation_id.in_(ids))
                    .group_by(Membership.organisation_id)
                )
            ).all()
        )
        return [
            OrganisationRead(
                uuid=organisation.uuid,
                name=organisation.name,
                role=Role(membership.role),
                faces_enabled=organisation.faces_enabled,
                faces_consent_at=organisation.faces_consent_at,
                site_count=len(by_organisation.get(organisation.id, [])),
                member_count=members.get(organisation.id, 0),
                sites=by_organisation.get(organisation.id, []),
                created_at=organisation.created_at,
            )
            for organisation, membership in organisations
        ]

    async def read(self, organisation_uuid: UUID) -> OrganisationRead:
        """Return one organisation of the user.

        Args:
            organisation_uuid: Public id.

        Returns:
            The organisation.
        """
        access = await resolve_organisation_access(self.session, self.actor, organisation_uuid)
        return (await self.reads([(access.organisation, access.membership)]))[0]

    async def list(self) -> OrganisationList:
        """List the user's organisations.

        Returns:
            The organisations, oldest membership first.
        """
        rows = (
            await self.session.execute(
                select(Organisation, Membership)
                .join(Membership, Membership.organisation_id == Organisation.id)
                .where(Membership.user_id == self.actor.id, Organisation.deleted_at.is_(None))
                .order_by(Membership.created_at, Membership.id)
            )
        ).all()
        return OrganisationList(items=await self.reads([tuple(row) for row in rows]))

    async def create(self, payload: OrganisationCreate) -> OrganisationRead:
        """Create an organisation owned by the user, with its first site when one is given.

        New organisations start with face recognition off.

        Args:
            payload: The organisation.

        Returns:
            The new organisation.
        """
        organisation = Organisation(name=payload.name, faces_enabled=False)
        self.session.add(organisation)
        await self.session.flush()
        membership = Membership(
            user_id=self.actor.id, organisation_id=organisation.id, role=Role.OWNER.value, all_sites=True
        )
        self.session.add(membership)
        if payload.site is not None:
            self.session.add(
                Site(
                    organisation_id=organisation.id,
                    name=payload.site.name,
                    kind=payload.site.kind.value,
                    timezone=payload.site.timezone,
                    position=0,
                )
            )
        await self.session.commit()
        await self.session.refresh(organisation)
        return (await self.reads([(organisation, membership)]))[0]

    async def update(self, organisation_uuid: UUID, payload: OrganisationUpdate) -> OrganisationRead:
        """Rename an organisation or turn its face recognition on or off.

        Turning faces on needs the consent flag and the version of the current consent text.

        Args:
            organisation_uuid: Public id.
            payload: Fields to change.

        Returns:
            The organisation.

        Raises:
            Unprocessable: Faces are turned on without consent to the current text.
        """
        access = await resolve_organisation_access(self.session, self.actor, organisation_uuid, Role.ADMIN)
        organisation = access.organisation
        if payload.name is not None:
            organisation.name = payload.name.strip() or organisation.name
        if payload.faces_enabled is True and not organisation.faces_enabled:
            if not payload.faces_consent or payload.consent_version != FACES_CONSENT.version:
                raise Unprocessable(
                    "faces_consent_required", "Accept the current face recognition consent text to turn faces on"
                )
            organisation.faces_enabled = True
            organisation.faces_consent_at = datetime.now(UTC)
            organisation.faces_consent_by_id = self.actor.id
            organisation.faces_consent_version = FACES_CONSENT.version
        elif payload.faces_enabled is False:
            organisation.faces_enabled = False
        await self.session.commit()
        await self.session.refresh(organisation)
        return (await self.reads([(organisation, access.membership)]))[0]

    async def delete(self, organisation_uuid: UUID) -> None:
        """Delete an organisation with its sites, cameras and connectors.

        Args:
            organisation_uuid: Public id.
        """
        access = await resolve_organisation_access(self.session, self.actor, organisation_uuid, Role.OWNER)
        await delete_organisation_rows(self.session, access.organisation, datetime.now(UTC))
        await self.session.commit()

    async def transfer(self, organisation_uuid: UUID, member_uuid: UUID) -> OrganisationRead:
        """Make another member the owner; the current owner becomes an admin of every site.

        Args:
            organisation_uuid: Public id.
            member_uuid: Public id of the membership that becomes the owner.

        Returns:
            The organisation as the former owner now sees it.

        Raises:
            NotFound: The membership is not one of this organisation.
        """
        access = await resolve_organisation_access(self.session, self.actor, organisation_uuid, Role.OWNER)
        target = await self.session.scalar(
            select(Membership).where(
                Membership.uuid == member_uuid, Membership.organisation_id == access.organisation.id
            )
        )
        if target is None:
            raise NotFound("member_not_found", f"Member {member_uuid} does not exist")
        if target.id != access.membership.id:
            target.role = Role.OWNER.value
            target.all_sites = True
            access.membership.role = Role.ADMIN.value
            access.membership.all_sites = True
        await self.session.commit()
        return (await self.reads([(access.organisation, access.membership)]))[0]
