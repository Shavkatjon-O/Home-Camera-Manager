"""WebRTC signalling endpoints."""

from uuid import UUID

from fastapi import APIRouter, Depends

from app.auth.context import UserContext
from app.auth.dependencies import get_current_user
from app.modules.media.deps import get_live_service
from app.modules.media.schemas import IceServerList, WebrtcAnswer, WebrtcOffer
from app.modules.media.services import LiveService, ice_servers

router = APIRouter()


@router.post("/cameras/{uuid}/webrtc", response_model=WebrtcAnswer)
async def create_webrtc_session(
    uuid: UUID, payload: WebrtcOffer, service: LiveService = Depends(get_live_service)
) -> WebrtcAnswer:
    """Watch a camera of the site over WebRTC: send the app's SDP offer and receive go2rtc's answer.

    Args:
        uuid: Public id of the camera.
        payload: The offer and the stream to watch.
        service: Live service.

    Returns:
        The answer.
    """
    return await service.offer(uuid, payload)


@router.get("/live/ice-servers", response_model=IceServerList)
async def get_ice_servers(user: UserContext = Depends(get_current_user)) -> IceServerList:
    """Return the STUN and TURN servers the app's peer connection may use.

    Args:
        user: Signed-in user.

    Returns:
        The servers.
    """
    return ice_servers()
