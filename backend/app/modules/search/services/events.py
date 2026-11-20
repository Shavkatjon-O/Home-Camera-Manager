"""Service for the filtered event search."""

from datetime import UTC, datetime

from sqlalchemy import ColumnElement, func, select

from app.core.base_service import BaseModelService
from app.core.exceptions import Unprocessable
from app.models import Event
from app.modules.events.enums import EventKind
from app.modules.events.schemas import event_read
from app.modules.events.services.events import camera_names
from app.modules.people.models import FaceSample, Person, UnknownCluster
from app.modules.people.services import face_summaries
from app.modules.search.schemas import EventFilters, ResultPage, SearchResult

from .analytics import analytics_filters

__all__ = ["EventSearchService", "event_filters", "result_fields"]

EVENT_KINDS = frozenset(kind.value for kind in EventKind)


def result_fields(event: Event, camera_name: str | None, until: datetime) -> dict:
    """Convert an event row to the fields of the events list, for any stored kind.

    Kinds the events module knows go through its own conversion; face and other new kinds get the same fields
    built here, with the kind kept as stored text.

    Args:
        event: Event row.
        camera_name: Name of the event's camera, if it still exists.
        until: Time an ongoing event counts its duration to.

    Returns:
        The event fields of a search result.
    """
    if event.kind in EVENT_KINDS:
        fields = event_read(event, camera_name, until).model_dump()
        fields["kind"] = str(event.kind)
        return fields
    end = event.ended_at or until
    return {
        "uuid": event.uuid,
        "camera_uuid": event.camera_uuid,
        "camera_name": camera_name,
        "kind": str(event.kind),
        "source_topic": event.source_topic,
        "started_at": event.started_at,
        "ended_at": event.ended_at,
        "ongoing": event.ended_at is None,
        "duration_seconds": max(0.0, (end - event.started_at).total_seconds()),
        "camera_time": event.camera_time,
        "has_snapshot": bool(event.snapshot_path),
        "has_thumbnail": bool(event.thumbnail_path),
        "details": event.details or {},
        "created_at": event.created_at,
        "updated_at": event.updated_at,
    }


def event_filters(filters: EventFilters) -> list[ColumnElement[bool]]:
    """Build the conditions of an event search.

    Camera, kind and time filter on the event columns, a person or cluster through the face samples of the
    events, and the analytics fields through analytics_filters.

    Args:
        filters: Filters of the search.

    Returns:
        Conditions over the events table that must all hold.

    Raises:
        Unprocessable: When the end of the time range does not come after its start.
    """
    if filters.start is not None and filters.end is not None and filters.end <= filters.start:
        raise Unprocessable("invalid_range", "The end of the range must come after its start")
    conditions = [Event.deleted_at.is_(None)]
    if filters.start is not None:
        conditions.append(Event.started_at >= filters.start)
    if filters.end is not None:
        conditions.append(Event.started_at < filters.end)
    if filters.cameras:
        conditions.append(Event.camera_uuid.in_(filters.cameras))
    if filters.kinds:
        conditions.append(Event.kind.in_(filters.kinds))
    if filters.person is not None:
        conditions.append(
            Event.uuid.in_(
                select(FaceSample.event_uuid)
                .join(Person, Person.id == FaceSample.person_id)
                .where(Person.uuid == filters.person, FaceSample.deleted_at.is_(None))
            )
        )
    if filters.cluster is not None:
        conditions.append(
            Event.uuid.in_(
                select(FaceSample.event_uuid)
                .join(UnknownCluster, UnknownCluster.id == FaceSample.cluster_id)
                .where(UnknownCluster.uuid == filters.cluster, FaceSample.deleted_at.is_(None))
            )
        )
    conditions.extend(analytics_filters(filters.views, filters.labels, filters.zones, filters.lines, filters.alert))
    return conditions


class EventSearchService(BaseModelService[Event]):
    """Search events by camera, time, kind, analytics fields, person and cluster."""

    model = Event
    not_found_code = "event_not_found"

    async def search(self, filters: EventFilters, page: int, page_size: int) -> ResultPage:
        """List one page of events that match the filters, newest first.

        Args:
            filters: Filters of the search.
            page: One-based page number.
            page_size: Number of results per page.

        Returns:
            Results on the page, each with the face it shows, and the total count.
        """
        conditions = event_filters(filters)
        total = await self.session.scalar(select(func.count()).select_from(Event).where(*conditions))
        rows = list(
            await self.session.scalars(
                select(Event)
                .where(*conditions)
                .order_by(Event.started_at.desc(), Event.id.desc())
                .offset((page - 1) * page_size)
                .limit(page_size)
            )
        )
        names = await camera_names(self.session) if rows else {}
        faces = await face_summaries(self.session, rows)
        now = datetime.now(UTC)
        return ResultPage(
            items=[
                SearchResult(**result_fields(row, names.get(row.camera_uuid), now), face=faces.get(row.uuid))
                for row in rows
            ],
            total=total or 0,
            page=page,
            page_size=page_size,
        )
