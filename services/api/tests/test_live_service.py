from uuid import uuid4

import pytest

from app.core.config import settings
from app.core.exceptions import BadGateway, Conflict, NotFound
from app.models import Camera
from app.modules.analytics.enums import ViewStream
from app.modules.media.schemas import WebrtcOffer
from app.modules.media.services.webrtc import LiveService, ice_servers
from app.streaming.go2rtc import Go2rtcError
from app.streaming.names import MAIN, SUB, stream_name

SDP = "v=0\r\no=- 1 1 IN IP4 0.0.0.0\r\n"


class FakeSession:
    def __init__(self, camera):
        self.camera = camera

    async def scalar(self, statement):
        return self.camera


class FakeGo2rtc:
    def __init__(self, answer="v=0 answer", error=None):
        self.names = []
        self.answer = answer
        self.error = error

    async def webrtc(self, name, offer):
        self.names.append(name)
        if self.error:
            raise self.error
        return self.answer


def camera(**fields):
    base = {"uuid": uuid4(), "name": "Door", "enabled": True, "sub_path": "/sub"}
    base.update(fields)
    return Camera(**base)


def offer(stream=ViewStream.SUB):
    return WebrtcOffer(sdp=SDP, stream=stream)


async def test_sub_stream_is_used_when_the_camera_has_one():
    found, go2rtc = camera(), FakeGo2rtc()
    answer = await LiveService(FakeSession(found), go2rtc).offer(found.uuid, offer())
    assert go2rtc.names == [stream_name(found.uuid, SUB)]
    assert answer.stream == ViewStream.SUB
    assert answer.sdp == "v=0 answer"


async def test_sub_falls_back_to_main_without_a_sub_path():
    found, go2rtc = camera(sub_path=None), FakeGo2rtc()
    answer = await LiveService(FakeSession(found), go2rtc).offer(found.uuid, offer())
    assert go2rtc.names == [stream_name(found.uuid, MAIN)]
    assert answer.stream == ViewStream.MAIN


async def test_main_stream_is_kept_when_asked_for():
    found, go2rtc = camera(), FakeGo2rtc()
    await LiveService(FakeSession(found), go2rtc).offer(found.uuid, offer(ViewStream.MAIN))
    assert go2rtc.names == [stream_name(found.uuid, MAIN)]


async def test_disabled_camera_conflicts():
    found = camera(enabled=False)
    with pytest.raises(Conflict) as caught:
        await LiveService(FakeSession(found), FakeGo2rtc()).offer(found.uuid, offer())
    assert caught.value.code == "camera_disabled"


async def test_missing_camera_is_not_found():
    with pytest.raises(NotFound):
        await LiveService(FakeSession(None), FakeGo2rtc()).offer(uuid4(), offer())


async def test_go2rtc_error_becomes_bad_gateway():
    found = camera()
    with pytest.raises(BadGateway) as caught:
        await LiveService(FakeSession(found), FakeGo2rtc(error=Go2rtcError("down"))).offer(found.uuid, offer())
    assert caught.value.code == "webrtc_failed"


async def test_empty_answer_becomes_bad_gateway():
    found = camera()
    with pytest.raises(BadGateway):
        await LiveService(FakeSession(found), FakeGo2rtc(answer="  ")).offer(found.uuid, offer())


def test_ice_servers_list_stun_and_turn(monkeypatch):
    monkeypatch.setattr(settings, "webrtc_stun_urls", "stun:a.example.org:3478, stun:b.example.org:3478,")
    monkeypatch.setattr(settings, "webrtc_turn_url", "turn:t.example.org:3478")
    monkeypatch.setattr(settings, "webrtc_turn_username", "user")
    monkeypatch.setattr(settings, "webrtc_turn_password", "pass")
    stun, turn = ice_servers().ice_servers
    assert stun.urls == ["stun:a.example.org:3478", "stun:b.example.org:3478"]
    assert stun.username is None
    assert turn.urls == ["turn:t.example.org:3478"]
    assert (turn.username, turn.credential) == ("user", "pass")


def test_ice_servers_are_empty_when_nothing_is_configured(monkeypatch):
    monkeypatch.setattr(settings, "webrtc_stun_urls", "")
    monkeypatch.setattr(settings, "webrtc_turn_url", "")
    assert ice_servers().ice_servers == []


def test_turn_without_credentials_leaves_them_unset(monkeypatch):
    monkeypatch.setattr(settings, "webrtc_stun_urls", "")
    monkeypatch.setattr(settings, "webrtc_turn_url", "turn:t.example.org:3478")
    monkeypatch.setattr(settings, "webrtc_turn_username", "")
    monkeypatch.setattr(settings, "webrtc_turn_password", "")
    server = ice_servers().ice_servers[0]
    assert server.username is None
    assert server.credential is None
