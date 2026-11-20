"""Membership helpers shared by the organisation services and account deletion."""

from collections import defaultdict
from datetime import datetime
from uuid import UUID

from sqlalchemy import delete, func, select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import Conflict, Unprocessable
from app.models import Camera, Connector, Invitation, Membership, MembershipSite, Organisation, Site
from app.modules.organisations.enums import Role

__all__ = [
    "delete_organisation_rows",
    "delete_site_rows",
    "membership_site_uuids",
    "release_memberships",
    "set_membership_sites",
]


async def membership_site_uuids(session: AsyncSession, membership_ids: list[int]) -> dict[int, list[UUID]]:
    """Load the sites of memberships limited to a list of sites.

    Args:
        session: Database session.
        membership_ids: Database ids of the memberships.

    Returns:
        Membership id to the public ids of its live sites, in site order.
    """
    if not membership_ids:
        return {}
    rows = await session.execute(
        select(MembershipSite.membership_id, Site.uuid)
        .join(Site, Site.id == MembershipSite.site_id)
        .where(MembershipSite.membership_id.in_(membership_ids), Site.deleted_at.is_(None))
        .order_by(Site.position, Site.id)
    )
    result: dict[int, list[UUID]] = defaultdict(list)
    for membership_id, site_uuid in rows.all():
        result[membership_id].append(site_uuid)
    return result


async def set_membership_sites(
    session: AsyncSession, membership: Membership, all_sites: bool, site_uuids: list[UUID]
) -> None:
    """Set which sites a membership covers.

    Args:
        session: Database session; the caller commits.
        membership: The membership, already flushed.
        all_sites: Whether it covers every site.
        site_uuids: Sites it covers when it does not cover all.

    Raises:
        Unprocessable: A listed site is not a live site of the organisation, or no site is listed.
    """
    membership.all_sites = all_sites
    await session.execute(delete(MembershipSite).where(MembershipSite.membership_id == membership.id))
    if all_sites:
        return
    wanted = set(site_uuids)
    if not wanted:
        raise Unprocessable("sites_required", "Name at least one site or cover all sites")
    rows = await session.execute(
        select(Site.id, Site.uuid).where(
            Site.uuid.in_(wanted), Site.organisation_id == membership.organisation_id, Site.deleted_at.is_(None)
        )
    )
    found = dict((uuid, site_id) for site_id, uuid in rows.all())
    missing = wanted - set(found)
    if missing:
        raise Unprocessable("site_not_found", f"Site {sorted(missing)[0]} is not a site of this organisation")
    session.add_all(MembershipSite(membership_id=membership.id, site_id=site_id) for site_id in found.values())


async def delete_site_rows(session: AsyncSession, site_ids: list[int], now: datetime) -> None:
    """Soft-delete sites with their cameras and revoke their connectors.

    Args:
        session: Database session; the caller commits.
        site_ids: Database ids of the sites.
        now: Deletion time.
    """
    if not site_ids:
        return
    await session.execute(
        update(Camera).where(Camera.site_id.in_(site_ids), Camera.deleted_at.is_(None)).values(deleted_at=now)
    )
    await session.execute(
        update(Connector)
        .where(Connector.site_id.in_(site_ids), Connector.revoked_at.is_(None))
        .values(revoked_at=now, deleted_at=now)
    )
    await session.execute(update(Site).where(Site.id.in_(site_ids), Site.deleted_at.is_(None)).values(deleted_at=now))


async def delete_organisation_rows(session: AsyncSession, organisation: Organisation, now: datetime) -> None:
    """Soft-delete an organisation with its sites, cameras, connectors, invitations and memberships.

    Its events and other recorded data stay until their retention removes them.

    Args:
        session: Database session; the caller commits.
        organisation: The organisation.
        now: Deletion time.
    """
    site_ids = list(await session.scalars(select(Site.id).where(Site.organisation_id == organisation.id)))
    await delete_site_rows(session, site_ids, now)
    await session.execute(
        update(Invitation)
        .where(Invitation.organisation_id == organisation.id, Invitation.accepted_at.is_(None))
        .values(revoked_at=now)
    )
    await session.execute(delete(Membership).where(Membership.organisation_id == organisation.id))
    organisation.deleted_at = now


async def release_memberships(session: AsyncSession, user_id: int, now: datetime) -> None:
    """End every membership of a user who is deleting their account.

    An organisation the user owns alone is deleted with its sites; one where the user is the owner and others
    are members must get a new owner first.

    Args:
        session: Database session; the caller commits.
        user_id: Database id of the user.
        now: Deletion time.

    Raises:
        Conflict: The user owns an organisation that has other members.
    """
    rows = (
        await session.execute(
            select(Membership, Organisation)
            .join(Organisation, Organisation.id == Membership.organisation_id)
            .where(Membership.user_id == user_id, Organisation.deleted_at.is_(None))
        )
    ).all()
    for membership, organisation in rows:
        if membership.role != Role.OWNER.value:
            await session.delete(membership)
            continue
        others = await session.scalar(
            select(func.count())
            .select_from(Membership)
            .where(Membership.organisation_id == organisation.id, Membership.user_id != user_id)
        )
        if others:
            raise Conflict(
                "transfer_ownership",
                f"Make another member the owner of {organisation.name} before deleting the account",
            )
        await delete_organisation_rows(session, organisation, now)
