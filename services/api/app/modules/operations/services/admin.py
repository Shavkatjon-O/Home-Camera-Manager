"""Platform administration: every organisation's plan, usage and suspension, every connector, the whole audit log."""

from datetime import UTC, datetime
from uuid import UUID

from sqlalchemy import func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.core.exceptions import NotFound, Unprocessable
from app.models import Connector, Membership, Organisation, Plan, Site, User
from app.modules.billing.enums import Feature, Limit
from app.modules.billing.services.entitlements import current_usage, entitlements_for
from app.modules.devices.services.connectors import connector_online
from app.modules.operations.enums import AuditAction
from app.modules.operations.schemas.admin import (
    AdminConnectorList,
    AdminConnectorRead,
    AdminOrganisationList,
    AdminOrganisationRead,
    AdminOrganisationUpdate,
    PlanOverrides,
)
from app.modules.operations.schemas.audit import AuditList
from app.modules.operations.services.audit import audit_query, record_audit
from app.modules.tenancy.services.scope import UNSCOPED_OPTION

__all__ = ["AdminService"]

UNSCOPED = {UNSCOPED_OPTION: True}


class AdminService:
    """What platform admins do across organisations; every change is audited.

    Attributes:
        session: Database session without a scope.
        actor: The platform admin.
        ip: Address of the request.
    """

    def __init__(self, session: AsyncSession, actor: UserContext, ip: str | None = None):
        """Bind the service to a request.

        Args:
            session: Database session without a scope.
            actor: The platform admin.
            ip: Address of the request.
        """
        self.session = session
        self.actor = actor
        self.ip = ip

    async def organisation(self, uuid: UUID) -> Organisation:
        """Load an organisation.

        Args:
            uuid: Public id.

        Returns:
            The organisation.

        Raises:
            NotFound: No live organisation has that id.
        """
        row = await self.session.scalar(
            select(Organisation)
            .where(Organisation.uuid == uuid, Organisation.deleted_at.is_(None))
            .execution_options(**UNSCOPED)
        )
        if row is None:
            raise NotFound("organisation_not_found", f"Organisation {uuid} does not exist")
        return row

    async def read(self, organisation: Organisation) -> AdminOrganisationRead:
        """Build the admin view of an organisation.

        Args:
            organisation: The organisation.

        Returns:
            The view with plan, limits, features and usage.
        """
        granted = await entitlements_for(self.session, organisation.id)
        owner = (
            await self.session.execute(
                select(User.email, User.username)
                .join(Membership, Membership.user_id == User.id)
                .where(Membership.organisation_id == organisation.id, Membership.role == "owner")
                .limit(1)
                .execution_options(**UNSCOPED)
            )
        ).first()
        overrides = organisation.plan_overrides or {}
        return AdminOrganisationRead(
            uuid=organisation.uuid,
            name=organisation.name,
            owner=(owner[0] or owner[1]) if owner else None,
            plan=granted.plan,
            plan_name=granted.plan_name,
            limits=granted.limits,
            features=sorted(granted.features),
            overrides=PlanOverrides(limits=overrides.get("limits") or {}, features=overrides.get("features") or {}),
            usage=await current_usage(self.session, organisation.id),
            suspended_at=organisation.suspended_at,
            suspended_reason=organisation.suspended_reason,
            created_at=organisation.created_at,
        )

    async def organisations(self, search: str | None, page: int, page_size: int) -> AdminOrganisationList:
        """List the organisations, newest first.

        Args:
            search: Part of the name or of the owner's address, if given.
            page: Page from 1.
            page_size: Organisations per page.

        Returns:
            The page.
        """
        conditions = [Organisation.deleted_at.is_(None)]
        if search:
            pattern = f"%{search.strip()}%"
            owners = (
                select(Membership.organisation_id)
                .join(User, User.id == Membership.user_id)
                .where(Membership.role == "owner", or_(User.email.ilike(pattern), User.username.ilike(pattern)))
            )
            conditions.append(or_(Organisation.name.ilike(pattern), Organisation.id.in_(owners)))
        total = await self.session.scalar(
            select(func.count()).select_from(Organisation).where(*conditions).execution_options(**UNSCOPED)
        )
        rows = await self.session.scalars(
            select(Organisation)
            .where(*conditions)
            .order_by(Organisation.created_at.desc(), Organisation.id.desc())
            .offset((page - 1) * page_size)
            .limit(page_size)
            .execution_options(**UNSCOPED)
        )
        return AdminOrganisationList(
            items=[await self.read(row) for row in rows], total=int(total or 0), page=page, page_size=page_size
        )

    async def update(self, uuid: UUID, payload: AdminOrganisationUpdate) -> AdminOrganisationRead:
        """Change an organisation's plan or overrides.

        Args:
            uuid: Public id of the organisation.
            payload: The change.

        Returns:
            The organisation.

        Raises:
            Unprocessable: The plan, a limit or a feature does not exist.
        """
        organisation = await self.organisation(uuid)
        before = {"plan_id": organisation.plan_id, "overrides": organisation.plan_overrides}
        if payload.plan is not None:
            plan = await self.session.scalar(select(Plan).where(Plan.key == payload.plan).execution_options(**UNSCOPED))
            if plan is None:
                raise Unprocessable("unknown_plan", f"There is no {payload.plan} plan")
            organisation.plan_id = plan.id
        if payload.overrides is not None:
            unknown_limits = set(payload.overrides.limits) - {item.value for item in Limit}
            unknown_features = set(payload.overrides.features) - {item.value for item in Feature}
            if unknown_limits or unknown_features:
                raise Unprocessable(
                    "unknown_override", f"Unknown limits or features: {sorted(unknown_limits | unknown_features)}"
                )
            organisation.plan_overrides = payload.overrides.model_dump()
        await record_audit(
            self.session,
            AuditAction.ADMIN_PLAN_CHANGE,
            actor=self.actor,
            organisation_id=organisation.id,
            target_kind="organisation",
            target_uuid=organisation.uuid,
            details={
                "plan": payload.plan,
                "overrides": payload.overrides.model_dump() if payload.overrides else None,
                "before": before,
            },
            ip=self.ip,
        )
        await self.session.commit()
        return await self.read(organisation)

    async def suspend(self, uuid: UUID, reason: str | None) -> AdminOrganisationRead:
        """Suspend an organisation, or restore it when no reason is given.

        Args:
            uuid: Public id of the organisation.
            reason: Why it is suspended, None to restore it.

        Returns:
            The organisation.
        """
        organisation = await self.organisation(uuid)
        organisation.suspended_at = datetime.now(UTC) if reason else None
        organisation.suspended_reason = reason
        await record_audit(
            self.session,
            AuditAction.ADMIN_SUSPEND if reason else AuditAction.ADMIN_RESTORE,
            actor=self.actor,
            organisation_id=organisation.id,
            target_kind="organisation",
            target_uuid=organisation.uuid,
            details={"reason": reason} if reason else {},
            ip=self.ip,
        )
        await self.session.commit()
        return await self.read(organisation)

    async def connectors(self, page: int, page_size: int) -> AdminConnectorList:
        """List every connector, most recently seen first.

        Args:
            page: Page from 1.
            page_size: Connectors per page.

        Returns:
            The page.
        """
        total = await self.session.scalar(
            select(func.count())
            .select_from(Connector)
            .where(Connector.deleted_at.is_(None))
            .execution_options(**UNSCOPED)
        )
        rows = (
            await self.session.execute(
                select(Connector, Organisation.uuid, Organisation.name, Site.uuid, Site.name)
                .outerjoin(Organisation, Organisation.id == Connector.organisation_id)
                .outerjoin(Site, Site.id == Connector.site_id)
                .where(Connector.deleted_at.is_(None))
                .order_by(Connector.last_seen_at.desc().nulls_last(), Connector.id.desc())
                .offset((page - 1) * page_size)
                .limit(page_size)
                .execution_options(**UNSCOPED)
            )
        ).all()
        now = datetime.now(UTC)
        return AdminConnectorList(
            items=[
                AdminConnectorRead(
                    uuid=connector.uuid,
                    name=connector.name,
                    organisation=organisation_uuid,
                    organisation_name=organisation_name,
                    site=site_uuid,
                    site_name=site_name,
                    version=connector.version,
                    mode=connector.mode,
                    online=connector_online(connector, now) and connector.revoked_at is None,
                    last_seen_at=connector.last_seen_at,
                    revoked_at=connector.revoked_at,
                )
                for connector, organisation_uuid, organisation_name, site_uuid, site_name in rows
            ],
            total=int(total or 0),
            page=page,
            page_size=page_size,
        )

    async def audit(
        self,
        organisation: UUID | None,
        action: str | None,
        since: datetime | None,
        until: datetime | None,
        page: int,
        page_size: int,
    ) -> AuditList:
        """Read the audit log of every organisation, or of one.

        Args:
            organisation: Only this organisation's records, if given.
            action: Only this action, if given.
            since: Only records from this time on.
            until: Only records before this time.
            page: Page from 1.
            page_size: Records per page.

        Returns:
            The page.
        """
        organisation_id = (await self.organisation(organisation)).id if organisation else None
        return await audit_query(self.session, organisation_id, action, since, until, page, page_size)
