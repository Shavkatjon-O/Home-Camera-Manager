"""Entitlements: the one check every route and the analytics configuration use for limits and features."""

from dataclasses import dataclass, field

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import Forbidden, NotFound
from app.models import Camera, Invitation, Membership, Organisation, Plan, Site
from app.modules.billing.enums import Feature, Limit
from app.modules.billing.services.catalog import DEFAULT_PLAN, PLAN_CATALOG
from app.modules.tenancy.services.scope import UNSCOPED_OPTION

__all__ = ["Entitlements", "current_usage", "entitlements_for", "merge_entitlements", "require_capacity"]

UNSCOPED = {UNSCOPED_OPTION: True}


@dataclass(frozen=True)
class Entitlements:
    """What an organisation may use.

    Attributes:
        organisation_id: The organisation.
        plan: Key of its plan.
        plan_name: Name of its plan.
        limits: Limit name to value; None is unlimited.
        features: Features it may use.
        suspended: Whether a platform admin suspended it.
    """

    organisation_id: int
    plan: str
    plan_name: str
    limits: dict[str, int | None] = field(default_factory=dict)
    features: frozenset[str] = frozenset()
    suspended: bool = False

    def allows(self, feature: Feature | str) -> bool:
        """Tell whether a feature is on.

        Args:
            feature: The feature.

        Returns:
            True when the organisation may use it.
        """
        return str(feature) in self.features

    def limit(self, name: Limit | str) -> int | None:
        """Return a limit.

        Args:
            name: The limit.

        Returns:
            Its value, None for unlimited.
        """
        return self.limits.get(str(name))

    def require(self, feature: Feature | str) -> None:
        """Refuse a feature that is off.

        Args:
            feature: The feature.

        Raises:
            Forbidden: The organisation's plan does not include it.
        """
        if not self.allows(feature):
            raise Forbidden("feature_not_in_plan", f"The {feature} feature is not part of this organisation's plan")


def merge_entitlements(
    organisation_id: int, plan_key: str, plan_name: str, limits: dict, features: list, overrides: dict, suspended: bool
) -> Entitlements:
    """Combine a plan with an organisation's overrides.

    Args:
        organisation_id: The organisation.
        plan_key: Key of the plan.
        plan_name: Name of the plan.
        limits: The plan's limits.
        features: The plan's features.
        overrides: The organisation's overrides, {"limits": {...}, "features": {"name": bool}}.
        suspended: Whether the organisation is suspended.

    Returns:
        The entitlements; an override limit of null makes that limit unlimited.
    """
    merged_limits: dict[str, int | None] = {item.value: None for item in Limit}
    merged_limits.update({key: value for key, value in (limits or {}).items() if key in merged_limits})
    merged_limits.update(
        {key: value for key, value in ((overrides or {}).get("limits") or {}).items() if key in merged_limits}
    )
    known = {item.value for item in Feature}
    merged_features = {feature for feature in features or [] if feature in known}
    for feature, enabled in ((overrides or {}).get("features") or {}).items():
        if feature not in known:
            continue
        if enabled:
            merged_features.add(feature)
        else:
            merged_features.discard(feature)
    return Entitlements(
        organisation_id=organisation_id,
        plan=plan_key,
        plan_name=plan_name,
        limits=merged_limits,
        features=frozenset(merged_features),
        suspended=suspended,
    )


async def entitlements_for(session: AsyncSession, organisation_id: int) -> Entitlements:
    """Load an organisation's entitlements, ignoring the session's scope.

    Args:
        session: Database session.
        organisation_id: The organisation.

    Returns:
        The entitlements; an organisation without a plan is on the default plan.

    Raises:
        NotFound: The organisation does not exist.
    """
    row = (
        await session.execute(
            select(
                Organisation.plan_overrides, Organisation.suspended_at, Plan.key, Plan.name, Plan.limits, Plan.features
            )
            .outerjoin(Plan, Plan.id == Organisation.plan_id)
            .where(Organisation.id == organisation_id)
            .execution_options(**UNSCOPED)
        )
    ).first()
    if row is None:
        raise NotFound("organisation_not_found", "The organisation does not exist")
    overrides, suspended_at, key, name, limits, features = row
    if key is None:
        default = await session.scalar(select(Plan).where(Plan.key == DEFAULT_PLAN).execution_options(**UNSCOPED))
        if default is not None:
            key, name, limits, features = default.key, default.name, default.limits, default.features
        else:
            spec = PLAN_CATALOG[0]
            key, name, limits, features = spec.key, spec.name, spec.limits, list(spec.features)
    return merge_entitlements(organisation_id, key, name, limits, features, overrides, suspended_at is not None)


async def current_usage(session: AsyncSession, organisation_id: int) -> dict[str, int]:
    """Count what an organisation uses of its capped quantities.

    Members count accepted members and pending invitations, so an invitation cannot exceed the limit later.

    Args:
        session: Database session.
        organisation_id: The organisation.

    Returns:
        Limit name to the amount in use.
    """
    sites = await session.scalar(
        select(func.count())
        .select_from(Site)
        .where(Site.organisation_id == organisation_id, Site.deleted_at.is_(None))
        .execution_options(**UNSCOPED)
    )
    cameras = await session.scalar(
        select(func.count())
        .select_from(Camera)
        .where(Camera.organisation_id == organisation_id, Camera.deleted_at.is_(None))
        .execution_options(**UNSCOPED)
    )
    members = await session.scalar(
        select(func.count())
        .select_from(Membership)
        .where(Membership.organisation_id == organisation_id)
        .execution_options(**UNSCOPED)
    )
    invited = await session.scalar(
        select(func.count())
        .select_from(Invitation)
        .where(
            Invitation.organisation_id == organisation_id,
            Invitation.accepted_at.is_(None),
            Invitation.revoked_at.is_(None),
            Invitation.expires_at > func.now(),
        )
        .execution_options(**UNSCOPED)
    )
    return {
        Limit.SITES.value: int(sites or 0),
        Limit.CAMERAS.value: int(cameras or 0),
        Limit.MEMBERS.value: int(members or 0) + int(invited or 0),
    }


async def require_capacity(session: AsyncSession, organisation_id: int, limit: Limit, adding: int = 1) -> None:
    """Refuse to add more of a capped quantity than the organisation's plan allows.

    Args:
        session: Database session.
        organisation_id: The organisation.
        limit: The capped quantity: sites, cameras or members.
        adding: How many are being added.

    Raises:
        Forbidden: The addition would go over the limit, or the organisation is suspended.
    """
    granted = await entitlements_for(session, organisation_id)
    if granted.suspended:
        raise Forbidden("organisation_suspended", "The organisation is suspended")
    cap = granted.limit(limit)
    if cap is None:
        return
    used = (await current_usage(session, organisation_id))[limit.value]
    if used + adding > cap:
        raise Forbidden(
            "plan_limit_reached",
            f"The {granted.plan_name} plan allows {cap} {limit.value}; {used} are in use",
        )
