"""The plan catalog: the plans the code defines, kept in step with the plans table at every start."""

import logging
from dataclasses import dataclass, field

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import async_session_maker
from app.models import Plan
from app.modules.billing.enums import Feature, Limit

__all__ = ["DEFAULT_PLAN", "INTERNAL_PLAN", "PLAN_CATALOG", "PlanSpec", "ensure_plans", "sync_plans"]

logger = logging.getLogger(__name__)

DEFAULT_PLAN = "free"
INTERNAL_PLAN = "internal"
EVERY_FEATURE = tuple(feature.value for feature in Feature)


@dataclass(frozen=True)
class PlanSpec:
    """A plan as the code defines it.

    Attributes:
        key: Stable key.
        name: Name shown to people.
        limits: Limit name to value; a missing limit is unlimited.
        features: Features it turns on.
        public: Whether customers may be on it without a platform admin.
        position: Place in the plan list.
    """

    key: str
    name: str
    limits: dict[str, int] = field(default_factory=dict)
    features: tuple[str, ...] = EVERY_FEATURE
    public: bool = True
    position: int = 0


PLAN_CATALOG = (
    PlanSpec(
        key=DEFAULT_PLAN,
        name="Free",
        limits={
            Limit.SITES.value: 3,
            Limit.CAMERAS.value: 16,
            Limit.MEMBERS.value: 10,
            Limit.EVENT_RETENTION_DAYS.value: 30,
            Limit.CLIP_RETENTION_DAYS.value: 14,
        },
        position=0,
    ),
    PlanSpec(key=INTERNAL_PLAN, name="Internal", limits={}, public=False, position=100),
)


async def ensure_plans(session: AsyncSession) -> dict[str, Plan]:
    """Create or update the catalog's plans so the table matches the code.

    Plans that are no longer in the catalog stay, so organisations on them keep working.

    Args:
        session: Database session without a scope.

    Returns:
        The catalog's plans by key.
    """
    rows = {plan.key: plan for plan in await session.scalars(select(Plan))}
    for spec in PLAN_CATALOG:
        plan = rows.get(spec.key)
        if plan is None:
            plan = Plan(key=spec.key)
            session.add(plan)
            rows[spec.key] = plan
            logger.info("Created the %s plan", spec.key)
        plan.name = spec.name
        plan.limits = dict(spec.limits)
        plan.features = list(spec.features)
        plan.public = spec.public
        plan.position = spec.position
    await session.flush()
    return {spec.key: rows[spec.key] for spec in PLAN_CATALOG}


async def sync_plans() -> None:
    """Bring the plans table in line with the catalog in a session of its own."""
    async with async_session_maker() as session:
        await ensure_plans(session)
        await session.commit()
