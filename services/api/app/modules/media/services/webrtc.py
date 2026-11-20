"""WebRTC signalling: the backend checks access and passes the app's offer to go2rtc."""

from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.core.exceptions import BadGateway, Conflict, NotFound
from app.models import Camera
from app.modules.analytics.enums import ViewStream
from app.modules.media.schemas import IceServer, IceServerList, WebrtcAnswer, WebrtcOffer
from app.streaming.go2rtc import Go2rtcClient, Go2rtcError
from app.streaming.names import MAIN, SUB, stream_name
from app.streaming.supervisor import supervisor

__all__ = ["LiveService", "ice_servers"]


def ice_servers() -> IceServerList:
    """Build the ICE servers offered to the apps from the settings.

    Returns:
        The STUN servers and the TURN server that are configured.
    """
    servers = []
    stun = [url.strip() for url in settings.webrtc_stun_urls.split(",") if url.strip()]
    if stun:
        servers.append(IceServer(urls=stun))
    if settings.webrtc_turn_url:
        servers.append(
            IceServer(
                urls=[settings.webrtc_turn_url],
                username=settings.webrtc_turn_username or None,
                credential=settings.webrtc_turn_password or None,
            )
        )
    return IceServerList(ice_servers=servers)


class LiveService:
    """Opens WebRTC sessions on the cameras of the request's site.

    Attributes:
        session: Database session limited to the site.
        go2rtc: Client of the central go2rtc.
    """

    def __init__(self, session: AsyncSession, go2rtc: Go2rtcClient | None = None):
        """Bind the service to a scoped session.

        Args:
            session: Database session limited to the request's site.
            go2rtc: Client of go2rtc, the supervisor's when omitted.
        """
        self.session = session
        self.go2rtc = go2rtc or supervisor.go2rtc

    async def offer(self, camera_uuid: UUID, payload: WebrtcOffer) -> WebrtcAnswer:
        """Pass an offer for a camera of the site to go2rtc, without transcoding.

        Args:
            camera_uuid: Public id of the camera.
            payload: The offer and the stream.

        Returns:
            go2rtc's answer.

        Raises:
            NotFound: The camera is not a live camera of the site.
            Conflict: The camera is disabled.
            BadGateway: go2rtc refused the offer or did not answer.
        """
        camera = await self.session.scalar(
            select(Camera).where(Camera.uuid == camera_uuid, Camera.deleted_at.is_(None))
        )
        if camera is None:
            raise NotFound("camera_not_found", f"Camera {camera_uuid} does not exist")
        if not camera.enabled:
            raise Conflict("camera_disabled", "The camera is turned off")
        stream = payload.stream if payload.stream == ViewStream.MAIN or camera.sub_path else ViewStream.MAIN
        name = stream_name(camera.uuid, SUB if stream == ViewStream.SUB else MAIN)
        try:
            answer = await self.go2rtc.webrtc(name, payload.sdp)
        except Go2rtcError as exc:
            raise BadGateway("webrtc_failed", str(exc))
        if not answer.strip():
            raise BadGateway("webrtc_failed", "go2rtc answered without an SDP")
        return WebrtcAnswer(sdp=answer, stream=stream)
