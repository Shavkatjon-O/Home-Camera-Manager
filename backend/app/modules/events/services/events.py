"""Reading events, their pictures and clips, and the state of the camera event sources."""

from datetime import UTC, datetime
from pathlib import Path
from uuid import UUID

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.camera_events.engine import CameraEventsEngine, camera_events
from app.core.base_service import BaseModelService
from app.core.database import async_session_maker
from app.core.exceptions import NotFound, Unprocessable
from app.models import Camera, Event
from app.modules.events.enums import EventKind, EventSource
from app.modules.events.schemas import EventCounts, EventList, EventRead, EventSourceList, event_read
from app.modules.people.services.faces import face_summaries
from app.tenancy.scope import Scope, install_scope

__all__ = ["EventFilters", "EventService", "camera_names", "stream_hello"]


async def camera_names(session: AsyncSession) -> dict[UUID, str]:
    """Return every camera's name by id, including deleted cameras.

    Args:
        session: Database session.

    Returns:
        Camera id to name.
    """
    rows = await session.execute(select(Camera.uuid, Camera.name))
    return {camera_uuid: name for camera_uuid, name in rows.all()}


async def stream_hello(scope: Scope | None = None, engine: CameraEventsEngine = camera_events) -> dict:
    """Build the first message of the event stream: the sources and the open events.

    Args:
        scope: Row scope of the listener, limiting both to its site; None for every site.
        engine: The camera events engine.

    Returns:
        The hello payload.
    """
    async with async_session_maker() as session:
        if scope is not None:
            install_scope(session, scope)
        rows = list(
            await session.scalars(
                select(Event)
                .where(Event.deleted_at.is_(None), Event.ended_at.is_(None))
                .order_by(Event.started_at.desc())
                .limit(100)
            )
        )
        names = await camera_names(session)
    now = datetime.now(UTC)
    return {
        "sources": [source.model_dump(mode="json") for source in engine.sources() if source.camera_uuid in names],
        "open": [event_read(row, names.get(row.camera_uuid), now).model_dump(mode="json") for row in rows],
    }


class EventFilters:
    """Filters of the event list and counts.

    Attributes:
        camera_uuid: Only this camera.
        kind: Only this kind.
        label: Only this label.
        source: Only this source.
        start: Only events that started at or after this time.
        end: Only events that started before this time.
        plate: Only vehicle events whose number plate candidates contain this text.
    """

    def __init__(
        self,
        camera_uuid: UUID | None = None,
        kind: EventKind | None = None,
        label: str | None = None,
        source: EventSource | None = None,
        start: datetime | None = None,
        end: datetime | None = None,
        plate: str | None = None,
    ):
        """Collect the filters.

        Args:
            camera_uuid: Only this camera.
            kind: Only this kind.
            label: Only this label.
            source: Only this source.
            start: Only events that started at or after this time.
            end: Only events that started before this time.
            plate: Only vehicle events whose number plate candidates contain this text.

        Raises:
            Unprocessable: The end of the range is not after its start.
        """
        if start is not None and end is not None and end <= start:
            raise Unprocessable("invalid_range", "The end of the range must come after its start")
        self.camera_uuid = camera_uuid
        self.kind = kind
        self.label = label
        self.source = source
        self.start = start
        self.end = end
        self.plate = "".join(character for character in (plate or "").upper() if character.isalnum())

    def clauses(self) -> list:
        """Return the SQL conditions of the filters.

        Returns:
            Conditions to combine with AND.
        """
        clauses = [Event.deleted_at.is_(None)]
        if self.camera_uuid is not None:
            clauses.append(Event.camera_uuid == self.camera_uuid)
        if self.kind is not None:
            clauses.append(Event.kind == self.kind.value)
        if self.label:
            clauses.append(Event.label == self.label)
        if self.source is not None:
            clauses.append(Event.source == self.source.value)
        if self.start is not None:
            clauses.append(Event.started_at >= self.start)
        if self.end is not None:
            clauses.append(Event.started_at < self.end)
        if self.plate:
            clauses.append(Event.details["plates"].astext.contains(self.plate))
        return clauses


class EventService(BaseModelService[Event]):
    """Reads events for the API.

    Attributes:
        engine: The camera events engine, for the sources and the picture store.
    """

    model = Event
    not_found_code = "event_not_found"

    def __init__(
        self,
        session: AsyncSession,
        actor: UserContext | None = None,
        engine: CameraEventsEngine = camera_events,
    ):
        """Bind the service to a session.

        Args:
            session: Database session.
            actor: User making the request.
            engine: The camera events engine.
        """
        super().__init__(session, actor)
        self.engine = engine

    async def list_page(self, page: int, page_size: int, filters: EventFilters) -> EventList:
        """Return one page of events, newest first.

        Args:
            page: Page number from 1.
            page_size: Events per page.
            filters: The filters.

        Returns:
            The page.
        """
        clauses = filters.clauses()
        total = await self.session.scalar(select(func.count()).select_from(Event).where(*clauses))
        rows = list(
            await self.session.scalars(
                select(Event)
                .where(*clauses)
                .order_by(Event.started_at.desc(), Event.id.desc())
                .offset((page - 1) * page_size)
                .limit(page_size)
            )
        )
        names = await camera_names(self.session) if rows else {}
        faces = await face_summaries(self.session, rows)
        now = datetime.now(UTC)
        return EventList(
            items=[event_read(row, names.get(row.camera_uuid), now, faces.get(row.uuid)) for row in rows],
            total=total or 0,
            page=page,
            page_size=page_size,
        )

    async def counts(self, filters: EventFilters) -> EventCounts:
        """Count events per kind and label.

        Args:
            filters: The filters.

        Returns:
            The counts.
        """
        clauses = filters.clauses()
        kinds = await self.session.execute(select(Event.kind, func.count()).where(*clauses).group_by(Event.kind))
        labels = await self.session.execute(
            select(Event.label, func.count()).where(*clauses, Event.label.is_not(None)).group_by(Event.label)
        )
        alerts = await self.session.scalar(select(func.count()).select_from(Event).where(*clauses, Event.alert))
        kind_counts = {kind: count for kind, count in kinds.all()}
        return EventCounts(
            total=sum(kind_counts.values()),
            kinds=kind_counts,
            labels={label: count for label, count in labels.all()},
            alerts=alerts or 0,
        )

    async def detail(self, uuid: UUID) -> EventRead:
        """Return one event.

        Args:
            uuid: Event id.

        Returns:
            The event.
        """
        row = await self.get(uuid)
        names = await camera_names(self.session)
        faces = await face_summaries(self.session, [row])
        return event_read(row, names.get(row.camera_uuid), datetime.now(UTC), faces.get(row.uuid))

    async def image(self, uuid: UUID, thumbnail: bool) -> Path:
        """Return the snapshot or thumbnail file of an event.

        Args:
            uuid: Event id.
            thumbnail: True for the thumbnail.

        Returns:
            The file path.

        Raises:
            NotFound: The event has no such picture.
        """
        row = await self.get(uuid)
        relative = row.thumbnail_path if thumbnail else row.snapshot_path
        path = self.engine.store.resolve(relative)
        if path is None or not path.is_file():
            raise NotFound("snapshot_not_found", "This event has no snapshot")
        return path

    async def clip(self, uuid: UUID) -> Path:
        """Return the clip file of an event.

        Args:
            uuid: Event id.

        Returns:
            The file path.

        Raises:
            NotFound: The event has no clip.
        """
        row = await self.get(uuid)
        path = self.engine.store.resolve(row.clip_path)
        if path is None or not path.is_file():
            raise NotFound("clip_not_found", "This event has no clip")
        return path

    async def sources(self) -> EventSourceList:
        """Return the state of the event subscription of every camera of the request's site.

        Returns:
            The sources.
        """
        cameras = set(await camera_names(self.session))
        return EventSourceList(items=[source for source in self.engine.sources() if source.camera_uuid in cameras])

    async def acknowledge(self, uuid: UUID) -> EventRead:
        """Mark an event's alert as seen by the acting member.

        Args:
            uuid: Event id.

        Returns:
            The event.
        """
        row = await self.get(uuid)
        if row.acknowledged_at is None:
            row.acknowledged_at = datetime.now(UTC)
            row.acknowledged_by_id = self.actor.id if self.actor is not None else None
            await self.commit()
            await self.session.refresh(row)
        return await self.detail(uuid)
