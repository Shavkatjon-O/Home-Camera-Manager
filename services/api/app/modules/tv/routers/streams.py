"""Routes that the TV stream sources call to get their ffmpeg arguments and to report failures."""

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
    """Return the ffmpeg arguments that produce a TV stream, one per line.

    Args:
        name: Name of the TV stream, the wall or a tile.
        poll: Whether the caller is a repeated poll, which also checks that the camera streams issued
            earlier are still read.
        service: Config service without a device.

    Returns:
        Plain text with one ffmpeg argument per line.
    """
    return await service.stream_args(name, poll)


@router.post("/streams/{name}/failed", status_code=status.HTTP_204_NO_CONTENT)
async def stream_failed(
    name: str,
    source: str = Query(min_length=1, max_length=100),
    service: TvConfigService = Depends(get_tv_stream_service),
) -> Response:
    """Record that a source of a TV stream failed.

    Args:
        name: Name of the TV stream.
        source: Name of the source stream that failed.
        service: Config service without a device.

    Returns:
        Empty response.
    """
    service.report_failure(name, source)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
