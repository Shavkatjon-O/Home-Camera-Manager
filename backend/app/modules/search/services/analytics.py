"""Filters and facets over the fields the analytics service records on its events.

Until the events table has columns of its own for them, the view, object label, zone, line and alert flag are
read from the event's details under the keys view, label, zone, line and alert. Only this module knows where
those fields are stored.
"""

from collections.abc import Sequence

from sqlalchemy import ColumnElement, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import Event

__all__ = ["analytics_filters", "label_facets"]

LABELS_MAX = 200


def analytics_filters(
    views: Sequence[str],
    labels: Sequence[str],
    zones: Sequence[str],
    lines: Sequence[str],
    alert: bool,
) -> list[ColumnElement[bool]]:
    """Build the conditions of the analytics-specific search filters.

    Args:
        views: Camera views to keep, any of them; empty keeps all.
        labels: Object labels to keep, any of them; empty keeps all.
        zones: Zones to keep, any of them; empty keeps all.
        lines: Lines to keep, any of them; empty keeps all.
        alert: Whether to keep alerting events only.

    Returns:
        Conditions over the events table, one per filter that is set.
    """
    conditions = []
    for key, values in (("view", views), ("label", labels), ("zone", zones), ("line", lines)):
        if values:
            conditions.append(Event.details[key].astext.in_(list(values)))
    if alert:
        conditions.append(Event.details.contains({"alert": True}))
    return conditions


async def label_facets(session: AsyncSession) -> list[str]:
    """List the object labels that live events carry.

    Args:
        session: Database session.

    Returns:
        The distinct labels in alphabetical order.
    """
    label = Event.details["label"].astext
    rows = await session.scalars(
        select(label)
        .where(Event.deleted_at.is_(None), label.is_not(None), label != "")
        .distinct()
        .order_by(label)
        .limit(LABELS_MAX)
    )
    return [value for value in rows if value]
