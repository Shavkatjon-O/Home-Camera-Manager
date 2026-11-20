"""Bootstrap of an installation from before organisations: its admin owns one organisation with one site.

The backend runs it at every start. It assigns every row that has no site or organisation yet to the admin's
organisation and site, creating them on the first run, and does nothing once every row is assigned, so it is safe
to run any number of times. It never runs inside a migration.
"""

import logging
from dataclasses import dataclass, field
from datetime import UTC, datetime

from sqlalchemy import func, select, text, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.core.database import async_session_maker
from app.models import Camera, Device, FaceSample, Membership, Organisation, Plan, Site, User
from app.models.ownership import SiteOwned
from app.modules.billing.services.catalog import INTERNAL_PLAN
from app.modules.devices.services.manifests import camera_manifest
from app.modules.tenancy.enums import Role, SiteKind
from app.modules.tenancy.services.scope import ORGANISATION_SCOPED, SITE_SCOPED

__all__ = ["BOOTSTRAP_CONSENT_VERSION", "BootstrapReport", "bootstrap", "run_bootstrap"]

logger = logging.getLogger(__name__)

LOCK_KEY = 726_001
BOOTSTRAP_CONSENT_VERSION = "existing"


@dataclass
class BootstrapReport:
    """What one bootstrap run did.

    Attributes:
        organisation_created: Whether it created the organisation.
        site_created: Whether it created the site.
        membership_created: Whether it made the admin the owner.
        assigned: Rows assigned per table.
        devices: Devices created for cameras registered before devices existed.
        platform_admin: Whether the admin of the settings became the first platform admin.
        internal_plan: Whether the admin's own organisation moved to the internal plan.
    """

    organisation_created: bool = False
    site_created: bool = False
    membership_created: bool = False
    assigned: dict[str, int] = field(default_factory=dict)
    devices: int = 0
    platform_admin: bool = False
    internal_plan: bool = False

    @property
    def changed(self) -> bool:
        """bool: Whether the run changed anything."""
        return (
            self.organisation_created
            or self.site_created
            or self.membership_created
            or any(self.assigned.values())
            or bool(self.devices)
            or self.platform_admin
            or self.internal_plan
        )


async def unassigned(session: AsyncSession) -> bool:
    """Tell whether any row lacks its site or organisation.

    Args:
        session: Database session.

    Returns:
        True when a site row has no site or an organisation row has no organisation.
    """
    for model in SITE_SCOPED:
        if await session.scalar(select(model.id).where(model.site_id.is_(None)).limit(1)) is not None:
            return True
    for model in ORGANISATION_SCOPED:
        if await session.scalar(select(model.id).where(model.organisation_id.is_(None)).limit(1)) is not None:
            return True
    return False


async def owner_target(session: AsyncSession, admin: User, report: BootstrapReport) -> tuple[Organisation, Site]:
    """Find or create the organisation and site the admin's rows belong to.

    Args:
        session: Database session.
        admin: The admin user of the settings.
        report: Report to note creations in.

    Returns:
        The organisation and its first site.
    """
    organisation = await session.scalar(
        select(Organisation)
        .join(Membership, Membership.organisation_id == Organisation.id)
        .where(
            Membership.user_id == admin.id,
            Membership.role == Role.OWNER.value,
            Organisation.deleted_at.is_(None),
        )
        .order_by(Membership.created_at, Membership.id)
        .limit(1)
    )
    if organisation is None:
        now = datetime.now(UTC)
        organisation = Organisation(
            name=settings.bootstrap_organisation_name,
            faces_enabled=True,
            faces_consent_at=now,
            faces_consent_by_id=admin.id,
            faces_consent_version=BOOTSTRAP_CONSENT_VERSION,
        )
        session.add(organisation)
        await session.flush()
        session.add(
            Membership(user_id=admin.id, organisation_id=organisation.id, role=Role.OWNER.value, all_sites=True)
        )
        report.organisation_created = True
        report.membership_created = True
    site = await session.scalar(
        select(Site)
        .where(Site.organisation_id == organisation.id, Site.deleted_at.is_(None))
        .order_by(Site.position, Site.id)
        .limit(1)
    )
    if site is None:
        site = Site(
            organisation_id=organisation.id,
            name=settings.bootstrap_site_name,
            kind=SiteKind(settings.bootstrap_site_kind).value,
            timezone=settings.timezone,
            position=0,
        )
        session.add(site)
        await session.flush()
        report.site_created = True
    return organisation, site


async def assign_rows(session: AsyncSession, organisation: Organisation, site: Site, report: BootstrapReport) -> None:
    """Assign every row without a site or organisation to the target.

    Args:
        session: Database session.
        organisation: Target organisation.
        site: Target site.
        report: Report to count assignments in.
    """
    for model in SITE_SCOPED:
        result = await session.execute(
            update(model)
            .where(model.site_id.is_(None))
            .values(site_id=site.id, organisation_id=organisation.id)
            .execution_options(synchronize_session=False)
        )
        if result.rowcount:
            report.assigned[model.__tablename__] = result.rowcount
    for model in ORGANISATION_SCOPED:
        values = {"organisation_id": organisation.id}
        result = await session.execute(
            update(model)
            .where(model.organisation_id.is_(None))
            .values(**values)
            .execution_options(synchronize_session=False)
        )
        if result.rowcount:
            report.assigned[model.__tablename__] = result.rowcount
        if issubclass(model, SiteOwned):
            await session.execute(
                update(FaceSample)
                .where(FaceSample.site_id.is_(None), FaceSample.camera_uuid.is_not(None))
                .values(site_id=site.id)
                .execution_options(synchronize_session=False)
            )


async def backfill_devices(session: AsyncSession, report: BootstrapReport) -> None:
    """Give every camera from before devices existed a device of its own, as its first channel.

    The device takes the camera's site, organisation, connector, brand as adapter and addresses, and the camera
    receives the manifest its adapter gives for what is known about it. Cameras with a device, and cameras that
    still lack a site, are left alone.

    Args:
        session: Database session without a scope.
        report: Report to count the devices in.
    """
    cameras = list(await session.scalars(select(Camera).where(Camera.device_id.is_(None), Camera.site_id.is_not(None))))
    for camera in cameras:
        manifest = camera_manifest(camera)
        device = Device(
            site_id=camera.site_id,
            organisation_id=camera.organisation_id,
            connector_id=camera.connector_id,
            kind="camera",
            adapter=camera.brand,
            name=camera.name,
            host=camera.device_host or camera.host,
            onvif_port=camera.onvif_port,
            rtsp_port=camera.rtsp_port,
            channel_count=1,
            capabilities=manifest.to_dict(),
            deleted_at=camera.deleted_at,
        )
        session.add(device)
        await session.flush()
        camera.device_id = device.id
        camera.channel = 1
        if not camera.capabilities:
            camera.capabilities = manifest.to_dict()
        report.devices += 1


async def promote_admin(session: AsyncSession, admin: User, report: BootstrapReport) -> None:
    """Make the admin of the settings the first platform admin and put its own organisation on the internal plan.

    Nothing changes once any platform admin exists, or once the organisation has a plan of its own.

    Args:
        session: Database session without a scope.
        admin: The admin user of the settings.
        report: Report to note the changes in.
    """
    exists = await session.scalar(select(User.id).where(User.is_platform_admin.is_(True)).limit(1))
    if exists is None:
        admin.is_platform_admin = True
        report.platform_admin = True
    organisation = await session.scalar(
        select(Organisation)
        .join(Membership, Membership.organisation_id == Organisation.id)
        .where(Membership.user_id == admin.id, Membership.role == "owner", Organisation.deleted_at.is_(None))
        .order_by(Organisation.created_at, Organisation.id)
        .limit(1)
    )
    if organisation is None or organisation.plan_id is not None:
        return
    plan = await session.scalar(select(Plan.id).where(Plan.key == INTERNAL_PLAN))
    if plan is not None:
        organisation.plan_id = plan
        report.internal_plan = True


async def bootstrap(session: AsyncSession) -> BootstrapReport:
    """Run the bootstrap in a session and commit it.

    Args:
        session: Database session without a scope.

    Returns:
        What the run did.
    """
    report = BootstrapReport()
    await session.execute(text("SELECT pg_advisory_xact_lock(:key)"), {"key": LOCK_KEY})
    username = settings.admin_username.strip()
    admin = None
    if username:
        admin = await session.scalar(select(User).where(User.username == username, User.deleted_at.is_(None)))
    pending = await unassigned(session)
    if admin is None and pending:
        logger.warning("Rows without a site exist but SSS_ADMIN_USERNAME names no user to own them")
    if admin is not None:
        memberships = await session.scalar(
            select(func.count()).select_from(Membership).where(Membership.user_id == admin.id)
        )
        if pending or not memberships:
            organisation, site = await owner_target(session, admin, report)
            await assign_rows(session, organisation, site, report)
        await promote_admin(session, admin, report)
    await backfill_devices(session, report)
    if report.changed:
        await session.commit()
    else:
        await session.rollback()
    return report


async def run_bootstrap() -> BootstrapReport:
    """Run the bootstrap in its own session and log what it did.

    Returns:
        What the run did.
    """
    async with async_session_maker() as session:
        report = await bootstrap(session)
    if report.changed:
        logger.info(
            "Bootstrap: organisation created %s, site created %s, rows assigned %s, devices created %s, "
            "platform admin %s, internal plan %s",
            report.organisation_created,
            report.site_created,
            report.assigned,
            report.devices,
            report.platform_admin,
            report.internal_plan,
        )
    return report
