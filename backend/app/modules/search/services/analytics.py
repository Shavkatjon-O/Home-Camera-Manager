"""Filters and facets over the fields the analytics service records on its events.

The view, object label and alert flag are columns of the events table; zone and line ids sit in the event's details
under zone and line, as the analytics ingest stores them.
"""

from collections.abc import Sequence
from uuid import UUID

from sqlalchemy import ColumnElement, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import AnalyticsLine, AnalyticsView, AnalyticsZone, Event
from app.modules.search.schemas import LineFacet, ViewFacet, ZoneFacet

__all__ = ["analytics_filters", "label_facets", "rule_facets"]

LABELS_MAX = 200


def view_ids(values: Sequence[str]) -> list[UUID]:
    """Parse view ids, dropping any that are not valid ids.

    Args:
        values: View ids as sent.

    Returns:
        The parsed ids.
    """
    parsed = []
    for value in values:
        try:
            parsed.append(UUID(str(value)))
        except ValueError:
            continue
    return parsed


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
    if views:
        conditions.append(Event.view_uuid.in_(view_ids(views)))
    if labels:
        conditions.append(Event.label.in_(list(labels)))
    for key, values in (("zone", zones), ("line", lines)):
        if values:
            conditions.append(Event.details[key].astext.in_(list(values)))
    if alert:
        conditions.append(Event.alert.is_(True))
    return conditions


async def label_facets(session: AsyncSession) -> list[str]:
    """List the object labels that live events carry.

    Args:
        session: Database session.

    Returns:
        The distinct labels in alphabetical order.
    """
    rows = await session.scalars(
        select(Event.label)
        .where(Event.deleted_at.is_(None), Event.label.is_not(None), Event.label != "")
        .distinct()
        .order_by(Event.label)
        .limit(LABELS_MAX)
    )
    return [value for value in rows if value]


async def rule_facets(session: AsyncSession) -> tuple[list[ViewFacet], list[ZoneFacet], list[LineFacet]]:
    """List the analytics views with their zones and lines.

    Args:
        session: Database session.

    Returns:
        The live views by name, and the live zones and lines with the view each belongs to.
    """
    views = list(
        await session.scalars(
            select(AnalyticsView)
            .where(AnalyticsView.deleted_at.is_(None))
            .order_by(AnalyticsView.name, AnalyticsView.id)
        )
    )
    by_id = {view.id: str(view.uuid) for view in views}
    zones = await session.scalars(
        select(AnalyticsZone).where(AnalyticsZone.deleted_at.is_(None)).order_by(AnalyticsZone.name)
    )
    lines = await session.scalars(
        select(AnalyticsLine).where(AnalyticsLine.deleted_at.is_(None)).order_by(AnalyticsLine.name)
    )
    view_facets = [ViewFacet(id=str(view.uuid), name=view.name, camera_uuid=view.camera_uuid) for view in views]
    zone_facets = [
        ZoneFacet(id=str(zone.uuid), name=zone.name, view=by_id[zone.view_id])
        for zone in zones
        if zone.view_id in by_id
    ]
    line_facets = [
        LineFacet(id=str(line.uuid), name=line.name, view=by_id[line.view_id])
        for line in lines
        if line.view_id in by_id
    ]
    return view_facets, zone_facets, line_facets
