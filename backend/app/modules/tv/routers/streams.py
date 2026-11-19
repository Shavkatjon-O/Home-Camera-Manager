from fastapi import APIRouter, Depends, Query, Response, status
from fastapi.responses import PlainTextResponse

from app.modules.tv.deps import get_tv_stream_service
from app.modules.tv.services import TvConfigService

router = APIRouter()


@router.get("/streams/{name}", response_class=PlainTextResponse)
async def stream_command(
    name: str,
    poll: bool = Query(False),
    service: TvConfigService = Depends(get_tv_stream_service),
) -> str:
    return await service.stream_args(name, poll)


@router.post("/streams/{name}/failed", status_code=status.HTTP_204_NO_CONTENT)
async def stream_failed(
    name: str,
    source: str = Query(min_length=1, max_length=100),
    service: TvConfigService = Depends(get_tv_stream_service),
) -> Response:
    service.report_failure(name, source)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
