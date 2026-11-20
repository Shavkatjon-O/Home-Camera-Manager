"""The audit log: append-only records of who did what, where and when."""

import asyncio
import logging
from datetime import UTC, datetime, timedelta
from uuid import UUID

from sqlalchemy import delete, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.core.config import settings
from app.core.database import async_session_maker
from app.models import AuditRecord, Organisation, Site
from app.modules.operations.enums import AuditAction
from app.modules.operations.schemas.audit import AuditList, AuditRead
from app.modules.tenancy.enums import Role
from app.modules.tenancy.services.access import resolve_organisation_access
from app.modules.tenancy.services.scope import UNSCOPED_OPTION

__all__ = ["AuditPruner", "AuditService", "audit_pruner", "audit_query", "record_audit", "write_audit"]

logger = logging.getLogger(__name__)

UNSCOPED = {UNSCOPED_OPTION: True}
PRUNE_SECONDS = 6 * 3600


async def record_audit(
    session: AsyncSession,
    action: AuditAction,
    *,
    actor: UserContext | None = None,
    actor_id: int | None = None,
    actor_label: str | None = None,
    organisation_id: int | None = None,
    organisation_uuid: UUID | None = None,
    site_id: int | None = None,
    site_uuid: UUID | None = None,
    target_kind: str | None = None,
    target_uuid: UUID | None = None,
    details: dict | None = None,
    ip: str | None = None,
) -> AuditRecord:
    """Add an audit record to a session; the caller commits.

    Args:
        session: Database session.
        action: What was done.
        actor: Signed-in user who acted, if any.
        actor_id: Database id of the actor, when no user context is at hand.
        actor_label: Sign-in name of the actor, when no user context is at hand.
        organisation_id: Organisation concerned.
        organisation_uuid: Public id of the organisation, resolved when the database id is not known.
        site_id: Site concerned.
        site_uuid: Public id of the site, resolved when the database id is not known.
        target_kind: Kind of the thing acted on.
        target_uuid: Public id of the thing acted on.
        details: Further facts, never secrets.
        ip: Address of the request.

    Returns:
        The record.
    """
    if site_id is None and site_uuid is not None:
        row = (
            await session.execute(
                select(Site.id, Site.organisation_id).where(Site.uuid == site_uuid).execution_options(**UNSCOPED)
            )
        ).first()
        if row is not None:
            site_id, organisation_id = row[0], organisation_id or row[1]
    if organisation_id is None and organisation_uuid is not None:
        organisation_id = await session.scalar(
            select(Organisation.id).where(Organisation.uuid == organisation_uuid).execution_options(**UNSCOPED)
        )
    record = AuditRecord(
        organisation_id=organisation_id,
        site_id=site_id,
        actor_id=actor.id if actor is not None else actor_id,
        actor=actor.username if actor is not None else actor_label,
        action=action.value,
        target_kind=target_kind,
        target_uuid=target_uuid,
        details=details or {},
        ip=ip,
    )
    session.add(record)
    return record


async def write_audit(action: AuditAction, **facts) -> None:
    """Write an audit record in a session of its own, logging rather than raising a failure.

    Args:
        action: What was done.
        **facts: The facts record_audit takes.
    """
    try:
        async with async_session_maker() as session:
            await record_audit(session, action, **facts)
            await session.commit()
    except Exception:
        logger.exception("Writing the audit record of %s failed", action.value)


def audit_read(record: AuditRecord, organisation: UUID | None, site: UUID | None) -> AuditRead:
    """Build the API view of a record.

    Args:
        record: The record.
        organisation: Public id of its organisation.
        site: Public id of its site.

    Returns:
        The view.
    """
    return AuditRead(
        uuid=record.uuid,
        at=record.created_at,
        action=record.action,
        actor=record.actor,
        organisation=organisation,
        site=site,
        target_kind=record.target_kind,
        target_uuid=record.target_uuid,
        details=record.details,
        ip=record.ip,
    )


async def audit_query(
    session: AsyncSession,
    organisation_id: int | None,
    action: str | None,
    since: datetime | None,
    until: datetime | None,
    page: int,
    page_size: int,
) -> AuditList:
    """List audit records, newest first.

    Args:
        session: Database session.
        organisation_id: Only this organisation's records, every record when None.
        action: Only this action, if given.
        since: Only records from this time on.
        until: Only records before this time.
        page: Page from 1.
        page_size: Records per page.

    Returns:
        The page.
    """
    conditions = []
    if organisation_id is not None:
        conditions.append(AuditRecord.organisation_id == organisation_id)
    if action:
        conditions.append(AuditRecord.action == action)
    if since is not None:
        conditions.append(AuditRecord.created_at >= since)
    if until is not None:
        conditions.append(AuditRecord.created_at < until)
    total = await session.scalar(
        select(func.count()).select_from(AuditRecord).where(*conditions).execution_options(**UNSCOPED)
    )
    rows = (
        await session.execute(
            select(AuditRecord, Organisation.uuid, Site.uuid)
            .outerjoin(Organisation, Organisation.id == AuditRecord.organisation_id)
            .outerjoin(Site, Site.id == AuditRecord.site_id)
            .where(*conditions)
            .order_by(AuditRecord.created_at.desc(), AuditRecord.id.desc())
            .offset((page - 1) * page_size)
            .limit(page_size)
            .execution_options(**UNSCOPED)
        )
    ).all()
    return AuditList(
        items=[audit_read(record, organisation, site) for record, organisation, site in rows],
        total=int(total or 0),
        page=page,
        page_size=page_size,
    )


class AuditService:
    """Reads an organisation's audit log for its admins and owners.

    Attributes:
        session: Database session.
        actor: Signed-in user.
    """

    def __init__(self, session: AsyncSession, actor: UserContext):
        """Bind the service to a request.

        Args:
            session: Database session.
            actor: Signed-in user.
        """
        self.session = session
        self.actor = actor

    async def list(
        self,
        organisation_uuid: UUID,
        action: str | None,
        since: datetime | None,
        until: datetime | None,
        page: int,
        page_size: int,
    ) -> AuditList:
        """List an organisation's audit records; admins and owners only.

        Args:
            organisation_uuid: Public id of the organisation.
            action: Only this action, if given.
            since: Only records from this time on.
            until: Only records before this time.
            page: Page from 1.
            page_size: Records per page.

        Returns:
            The page.
        """
        access = await resolve_organisation_access(self.session, self.actor, organisation_uuid, Role.ADMIN)
        return await audit_query(self.session, access.organisation.id, action, since, until, page, page_size)


class AuditPruner:
    """Deletes audit records older than their retention, the only deletion the log allows.

    Attributes:
        task: The running loop, if any.
    """

    def __init__(self):
        """Create the pruner, not yet running."""
        self.task: asyncio.Task | None = None

    async def start(self) -> None:
        """Start the loop."""
        if self.task is None or self.task.done():
            self.task = asyncio.create_task(self.run(), name="audit-pruner")

    async def stop(self) -> None:
        """Stop the loop."""
        if self.task is not None:
            self.task.cancel()
            await asyncio.gather(self.task, return_exceptions=True)
            self.task = None

    async def prune(self) -> int:
        """Delete the records past their retention.

        Returns:
            The number deleted.
        """
        cutoff = datetime.now(UTC) - timedelta(days=settings.audit_retention_days)
        async with async_session_maker() as session:
            result = await session.execute(delete(AuditRecord).where(AuditRecord.created_at < cutoff))
            await session.commit()
            return result.rowcount or 0

    async def run(self) -> None:
        """Prune every few hours until cancelled, surviving failures."""
        while True:
            try:
                deleted = await self.prune()
                if deleted:
                    logger.info("Deleted %s audit records past their retention", deleted)
            except Exception:
                logger.exception("Pruning the audit log failed")
            await asyncio.sleep(PRUNE_SECONDS)


audit_pruner = AuditPruner()
