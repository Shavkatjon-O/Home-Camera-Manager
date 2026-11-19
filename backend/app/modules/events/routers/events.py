import asyncio
import json
from datetime import datetime
from uuid import UUID

from fastapi import APIRouter, Depends, Query, Request
from fastapi.responses import FileResponse, StreamingResponse

from app.auth.context import UserContext
from app.auth.dependencies import get_stream_user
from app.camera_events.engine import camera_events
from app.modules.events.deps import get_event_service
from app.modules.events.enums import EventKind
from app.modules.events.schemas import EventList, EventRead, EventSourceList
from app.modules.events.services import EventService, stream_hello

router = APIRouter()

PAGE_SIZE_DEFAULT = 50
PAGE_SIZE_MAX = 200

HEARTBEAT_SECONDS = 15.0
RETRY_MILLISECONDS = 5000

IMAGE_HEADERS = {"Cache-Control": "private, max-age=86400"}


def sse(kind: str, payload: dict) -> str:
    return f"event: {kind}\ndata: {json.dumps(payload, separators=(',', ':'))}\n\n"


@router.get("", response_model=EventList)
async def list_events(
    page: int = Query(1, ge=1),
    page_size: int = Query(PAGE_SIZE_DEFAULT, ge=1, le=PAGE_SIZE_MAX),
    camera_uuid: UUID | None = Query(None),
    kind: EventKind | None = Query(None),
    start: datetime | None = Query(None, alias="from"),
    end: datetime | None = Query(None, alias="to"),
    service: EventService = Depends(get_event_service),
) -> EventList:
    return await service.list_page(page, page_size, camera_uuid, kind, start, end)


@router.get("/sources", response_model=EventSourceList)
async def list_sources(service: EventService = Depends(get_event_service)) -> EventSourceList:
    return service.sources()


@router.get("/stream")
async def stream_events(request: Request, user: UserContext = Depends(get_stream_user)) -> StreamingResponse:
    async def body():
        with camera_events.broker.subscribe() as queue:
            yield f"retry: {RETRY_MILLISECONDS}\n\n"
            yield sse("hello", await stream_hello())
            while True:
                try:
                    message = await asyncio.wait_for(queue.get(), HEARTBEAT_SECONDS)
                except TimeoutError:
                    if await request.is_disconnected():
                        return
                    yield ": ping\n\n"
                    continue
                yield sse(message["type"], message["data"])

    return StreamingResponse(
        body(),
        media_type="text/event-stream",
        headers={"Cache-Control": "no-cache", "X-Accel-Buffering": "no"},
    )


@router.get("/{uuid}", response_model=EventRead)
async def get_event(uuid: UUID, service: EventService = Depends(get_event_service)) -> EventRead:
    return await service.detail(uuid)


@router.get("/{uuid}/snapshot")
async def get_snapshot(uuid: UUID, service: EventService = Depends(get_event_service)) -> FileResponse:
    return FileResponse(await service.image(uuid, thumbnail=False), media_type="image/jpeg", headers=IMAGE_HEADERS)


@router.get("/{uuid}/thumbnail")
async def get_thumbnail(uuid: UUID, service: EventService = Depends(get_event_service)) -> FileResponse:
    return FileResponse(await service.image(uuid, thumbnail=True), media_type="image/jpeg", headers=IMAGE_HEADERS)
