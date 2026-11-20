from datetime import UTC, datetime

import pytest
from sqlalchemy.dialects import postgresql

from app.core.exceptions import Forbidden
from app.modules.billing.enums import Feature, Limit, UsageMetric
from app.modules.billing.services import entitlements as module
from app.modules.billing.services.catalog import DEFAULT_PLAN, INTERNAL_PLAN, PLAN_CATALOG
from app.modules.billing.services.entitlements import merge_entitlements, require_capacity
from app.modules.billing.services.metering import hour_start, rollup_statement
from tests.fakes import entitlements

FREE = next(spec for spec in PLAN_CATALOG if spec.key == DEFAULT_PLAN)


def test_the_free_plan_is_generous_and_the_internal_plan_is_unlimited():
    internal = next(spec for spec in PLAN_CATALOG if spec.key == INTERNAL_PLAN)
    assert FREE.public and set(FREE.features) == {feature.value for feature in Feature}
    assert FREE.limits[Limit.CAMERAS.value] >= 16 and FREE.limits[Limit.SITES.value] >= 3
    assert not internal.public and internal.limits == {}


def test_overrides_change_limits_and_features_of_one_organisation():
    granted = merge_entitlements(
        7,
        "free",
        "Free",
        FREE.limits,
        list(FREE.features),
        {"limits": {"cameras": 40, "sites": None, "bogus": 3}, "features": {"faces": False, "unknown": True}},
        False,
    )
    assert granted.limit(Limit.CAMERAS) == 40 and granted.limit(Limit.SITES) is None
    assert granted.limit(Limit.MEMBERS) == FREE.limits["members"]
    assert not granted.allows(Feature.FACES) and granted.allows(Feature.PLATES)
    assert "bogus" not in granted.limits and "unknown" not in granted.features
    with pytest.raises(Forbidden) as caught:
        granted.require(Feature.FACES)
    assert caught.value.code == "feature_not_in_plan"


async def test_capacity_refuses_going_over_the_limit(monkeypatch):
    async def granted(session, organisation_id):
        return entitlements(limits={"cameras": 4})

    async def usage(session, organisation_id):
        return {"sites": 1, "cameras": 3, "members": 2}

    monkeypatch.setattr(module, "entitlements_for", granted)
    monkeypatch.setattr(module, "current_usage", usage)
    await require_capacity(None, 1, Limit.CAMERAS)
    with pytest.raises(Forbidden) as caught:
        await require_capacity(None, 1, Limit.CAMERAS, adding=2)
    assert caught.value.code == "plan_limit_reached"
    await require_capacity(None, 1, Limit.SITES, adding=50)


async def test_a_suspended_organisation_adds_nothing(monkeypatch):
    async def granted(session, organisation_id):
        return entitlements(suspended=True)

    monkeypatch.setattr(module, "entitlements_for", granted)
    with pytest.raises(Forbidden) as caught:
        await require_capacity(None, 1, Limit.SITES)
    assert caught.value.code == "organisation_suspended"


def test_usage_rolls_up_by_hour_and_counted_metrics_add_up():
    assert hour_start(datetime(2026, 11, 20, 9, 47, 12, tzinfo=UTC)) == datetime(2026, 11, 20, 9, tzinfo=UTC)
    row = {"organisation_id": 1, "site_id": None, "hour": datetime(2026, 11, 20, 9, tzinfo=UTC), "value": 2.0}
    added = str(
        rollup_statement([{**row, "metric": UsageMetric.NOTIFICATIONS.value}], add=True).compile(
            dialect=postgresql.dialect()
        )
    )
    replaced = str(
        rollup_statement([{**row, "metric": UsageMetric.EVENTS.value}], add=False).compile(dialect=postgresql.dialect())
    )
    assert "ON CONFLICT ON CONSTRAINT uq_usage_rollup" in added
    assert "usage_rollups.value + excluded.value" in added
    assert "usage_rollups.value +" not in replaced
