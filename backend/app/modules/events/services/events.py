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
from app.modules.events.enums import EventKind
from app.modules.events.schemas import EventList, EventRead, EventSourceList, event_read

__all__ = ["EventService", "stream_hello"]


async def camera_names(session: AsyncSession) -> dict[UUID, str]:
    rows = await session.execute(select(Camera.uuid, Camera.name))
    return {camera_uuid: name for camera_uuid, name in rows.all()}


async def stream_hello(engine: CameraEventsEngine = camera_events) -> dict:
    async with async_session_maker() as session:
        rows = list(
            await session.scalars(
                select(Event)
                .where(Event.deleted_at.is_(None), Event.ended_at.is_(None))
                .order_by(Event.started_at.desc())
                .limit(100)
            )
        )
        names = await camera_names(session) if rows else {}
    now = datetime.now(UTC)
    return {
        "sources": [source.model_dump(mode="json") for source in engine.sources()],
        "open": [event_read(row, names.get(row.camera_uuid), now).model_dump(mode="json") for row in rows],
    }


class EventService(BaseModelService[Event]):
    model = Event
    not_found_code = "event_not_found"

    def __init__(
        self,
        session: AsyncSession,
        actor: UserContext | None = None,
        engine: CameraEventsEngine = camera_events,
    ):
        super().__init__(session, actor)
        self.engine = engine

    async def list_page(
        self,
        page: int,
        page_size: int,
        camera_uuid: UUID | None = None,
        kind: EventKind | None = None,
        start: datetime | None = None,
        end: datetime | None = None,
    ) -> EventList:
        if start is not None and end is not None and end <= start:
            raise Unprocessable("invalid_range", "The end of the range must come after its start")
        filters = [Event.deleted_at.is_(None)]
        if camera_uuid is not None:
            filters.append(Event.camera_uuid == camera_uuid)
        if kind is not None:
            filters.append(Event.kind == kind.value)
        if start is not None:
            filters.append(Event.started_at >= start)
        if end is not None:
            filters.append(Event.started_at < end)
        total = await self.session.scalar(select(func.count()).select_from(Event).where(*filters))
        rows = list(
            await self.session.scalars(
                select(Event)
                .where(*filters)
                .order_by(Event.started_at.desc(), Event.id.desc())
                .offset((page - 1) * page_size)
                .limit(page_size)
            )
        )
        names = await camera_names(self.session) if rows else {}
        now = datetime.now(UTC)
        return EventList(
            items=[event_read(row, names.get(row.camera_uuid), now) for row in rows],
            total=total or 0,
            page=page,
            page_size=page_size,
        )

    async def detail(self, uuid: UUID) -> EventRead:
        row = await self.get(uuid)
        names = await camera_names(self.session)
        return event_read(row, names.get(row.camera_uuid), datetime.now(UTC))

    async def image(self, uuid: UUID, thumbnail: bool) -> Path:
        row = await self.get(uuid)
        relative = row.thumbnail_path if thumbnail else row.snapshot_path
        path = self.engine.store.resolve(relative)
        if path is None or not path.is_file():
            raise NotFound("snapshot_not_found", "This event has no snapshot")
        return path

    def sources(self) -> EventSourceList:
        return EventSourceList(items=self.engine.sources())
