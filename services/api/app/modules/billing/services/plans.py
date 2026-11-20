"""Plans, entitlements and usage as the apps read them."""

from datetime import UTC, datetime, timedelta
from uuid import UUID

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.core.database import UNSCOPED_OPTION
from app.models import Plan, UsageRollup
from app.modules.billing.schemas.plans import EntitlementsRead, PlanList, PlanRead, UsagePoint, UsageRead, UsageTotal
from app.modules.billing.services.entitlements import Entitlements, current_usage, entitlements_for
from app.modules.tenancy.enums import Role
from app.modules.tenancy.services.access import resolve_organisation_access

__all__ = ["PlanService", "entitlements_read", "usage_of"]

BUCKETS = {"hour": "hour", "day": "day"}


def entitlements_read(granted: Entitlements, usage: dict[str, int]) -> EntitlementsRead:
    """Build the API view of entitlements.

    Args:
        granted: The entitlements.
        usage: Amounts in use.

    Returns:
        The view.
    """
    return EntitlementsRead(
        plan=PlanRead(
            key=granted.plan, name=granted.plan_name, limits=granted.limits, features=sorted(granted.features)
        ),
        usage=usage,
        suspended=granted.suspended,
    )


class PlanService:
    """Reads plans, an organisation's entitlements and its usage.

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

    async def plans(self) -> PlanList:
        """List the plans offered to customers.

        Returns:
            The plans.
        """
        rows = await self.session.scalars(select(Plan).where(Plan.public.is_(True)).order_by(Plan.position, Plan.id))
        return PlanList(
            items=[
                PlanRead(key=plan.key, name=plan.name, limits=plan.limits, features=list(plan.features))
                for plan in rows
            ]
        )

    async def entitlements(self, organisation_uuid: UUID) -> EntitlementsRead:
        """Return a member's organisation's plan, limits, features and usage.

        Args:
            organisation_uuid: Public id of the organisation.

        Returns:
            The entitlements.
        """
        access = await resolve_organisation_access(self.session, self.actor, organisation_uuid)
        organisation_id = access.organisation.id
        granted = await entitlements_for(self.session, organisation_id)
        return entitlements_read(granted, await current_usage(self.session, organisation_id))

    async def usage(self, organisation_uuid: UUID, days: int, bucket: str) -> UsageRead:
        """Sum an organisation's metered usage over the last days; admins and owners only.

        Args:
            organisation_uuid: Public id of the organisation.
            days: Length of the period.
            bucket: hour or day.

        Returns:
            Totals and the series per bucket.
        """
        access = await resolve_organisation_access(self.session, self.actor, organisation_uuid, Role.ADMIN)
        return await usage_of(self.session, access.organisation.id, days, bucket)


async def usage_of(session: AsyncSession, organisation_id: int, days: int, bucket: str) -> UsageRead:
    """Sum an organisation's metered usage over the last days.

    Args:
        session: Database session.
        organisation_id: The organisation.
        days: Length of the period.
        bucket: hour or day.

    Returns:
        Totals and the series per bucket.
    """
    since = datetime.now(UTC).replace(minute=0, second=0, microsecond=0) - timedelta(days=days)
    at = func.date_trunc(BUCKETS.get(bucket, "day"), UsageRollup.hour).label("at")
    rows = (
        await session.execute(
            select(at, UsageRollup.metric, func.sum(UsageRollup.value))
            .where(UsageRollup.organisation_id == organisation_id, UsageRollup.hour >= since)
            .group_by(at, UsageRollup.metric)
            .order_by(at, UsageRollup.metric)
            .execution_options(**{UNSCOPED_OPTION: True})
        )
    ).all()
    totals: dict[str, float] = {}
    series = []
    for when, metric, value in rows:
        totals[metric] = totals.get(metric, 0.0) + float(value or 0)
        series.append(UsagePoint(at=when, metric=metric, value=float(value or 0)))
    return UsageRead(
        since=since,
        bucket=BUCKETS.get(bucket, "day"),
        totals=[UsageTotal(metric=metric, value=value) for metric, value in sorted(totals.items())],
        series=series,
    )
