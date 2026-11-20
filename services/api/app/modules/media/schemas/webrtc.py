"""Schemas of WebRTC signalling."""

from pydantic import BaseModel, Field

from app.modules.analytics.enums import ViewStream

__all__ = ["IceServer", "IceServerList", "WebrtcAnswer", "WebrtcOffer"]

SDP_MAX = 64 * 1024


class WebrtcOffer(BaseModel):
    """An app's request to watch a camera over WebRTC.

    Attributes:
        sdp: SDP offer of the app.
        stream: main or sub; sub falls back to main for a camera without a sub stream.
    """

    sdp: str = Field(min_length=10, max_length=SDP_MAX)
    stream: ViewStream = ViewStream.SUB


class WebrtcAnswer(BaseModel):
    """go2rtc's answer to an offer.

    Attributes:
        type: Always answer.
        sdp: SDP answer.
        stream: Stream that was opened.
    """

    type: str = "answer"
    sdp: str
    stream: ViewStream


class IceServer(BaseModel):
    """A STUN or TURN server the app may use.

    Attributes:
        urls: Server addresses, such as stun:stun.example.org:3478.
        username: TURN user, if any.
        credential: TURN password, if any.
    """

    urls: list[str]
    username: str | None = None
    credential: str | None = None


class IceServerList(BaseModel):
    """ICE servers for the app's peer connection.

    Attributes:
        ice_servers: The servers; empty when go2rtc is reached directly.
    """

    ice_servers: list[IceServer]
