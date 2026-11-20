"""Schemas of plans, entitlements and usage."""

from datetime import datetime

from pydantic import BaseModel

__all__ = ["EntitlementsRead", "PlanList", "PlanRead", "UsagePoint", "UsageRead", "UsageTotal"]


class PlanRead(BaseModel):
    """A plan.

    Attributes:
        key: Stable key.
        name: Name shown to people.
        limits: Limit name to value; null is unlimited.
        features: Features it turns on.
    """

    key: str
    name: str
    limits: dict[str, int | None]
    features: list[str]


class PlanList(BaseModel):
    """The plans offered to customers.

    Attributes:
        items: The plans, in list order.
    """

    items: list[PlanRead]


class EntitlementsRead(BaseModel):
    """What an organisation may use and how much it uses, so the apps can show it.

    Attributes:
        plan: The organisation's plan with its own overrides applied.
        usage: Limit name to the amount in use, for sites, cameras and members.
        suspended: Whether a platform admin suspended the organisation.
    """

    plan: PlanRead
    usage: dict[str, int]
    suspended: bool


class UsageTotal(BaseModel):
    """The total of one metric over a period.

    Attributes:
        metric: The metric.
        value: Its total.
    """

    metric: str
    value: float


class UsagePoint(BaseModel):
    """One metric in one bucket.

    Attributes:
        at: Start of the bucket.
        metric: The metric.
        value: Its amount in the bucket.
    """

    at: datetime
    metric: str
    value: float


class UsageRead(BaseModel):
    """An organisation's usage over a period.

    Attributes:
        since: Start of the period.
        bucket: hour or day.
        totals: Total per metric.
        series: Amount per metric and bucket, oldest first.
    """

    since: datetime
    bucket: str
    totals: list[UsageTotal]
    series: list[UsagePoint]
