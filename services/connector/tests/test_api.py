from types import SimpleNamespace

import pytest
from camera_adapters.base import AdapterError
from fastapi.testclient import TestClient

from connector_agent.api import create_app
from connector_agent.state import Pairing, Store

PAIRING = Pairing("c", "s", "o", "token", "agent-key", "central", "stream", 30)


class Cameras:
    def __init__(self):
        self.moves = []

    async def identify(self, request):
        if request.get("password") == "wrong":
            raise AdapterError("unauthorized", "The device refused the login")
        return {"adapter": "onvif", "kind": "nvr", "channels": []}

    def control(self, uuid):
        if uuid == "fixed":
            raise AdapterError("unsupported", "The camera cannot be moved")
        cameras = self

        class Adapter:
            async def move(self, target, channel, pan, tilt, zoom):
                cameras.moves.append((channel, pan, tilt, zoom))

            async def stop(self, target, channel):
                cameras.moves.append((channel, "stop"))

        return Adapter(), SimpleNamespace(), 3


@pytest.fixture
def agent(tmp_path):
    store = Store(str(tmp_path))
    return SimpleNamespace(
        store=store,
        cameras=Cameras(),
        pending={"user_code": "BCDF-GHJK", "verification_uri_complete": "https://app.example/pair?code=BCDF-GHJK"},
        pairing_qr_svg=lambda: "<svg/>",
        request_discovery=lambda: True,
    )


def test_the_api_refuses_calls_until_paired_and_without_the_key(agent):
    http = TestClient(create_app(agent))
    assert http.post("/api/discovery").status_code == 503
    assert http.get("/pairing").json()["user_code"] == "BCDF-GHJK"
    assert http.get("/pairing.svg").status_code == 200
    agent.store.save_pairing(PAIRING)
    assert http.post("/api/discovery").status_code == 401
    assert http.post("/api/discovery", headers={"Authorization": "Bearer nope"}).status_code == 401
    assert http.post("/api/discovery", headers={"Authorization": "Bearer agent-key"}).json() == {"started": True}
    assert http.get("/pairing").json() == {"paired": True}
    assert http.get("/pairing.svg").status_code == 404
    assert http.get("/health").json() == {"status": "ok", "paired": True}


def test_identify_returns_adapter_errors_with_their_code_and_ptz_uses_the_channel(agent):
    agent.store.save_pairing(PAIRING)
    http = TestClient(create_app(agent), headers={"Authorization": "Bearer agent-key"})
    assert http.post("/api/identify", json={"host": "192.168.1.20"}).json()["kind"] == "nvr"
    refused = http.post("/api/identify", json={"host": "192.168.1.20", "password": "wrong"}).json()
    assert refused == {"error": {"code": "unauthorized", "message": "The device refused the login"}}
    assert http.post("/api/cameras/cam/ptz/move", json={"pan": 0.5}).status_code == 204
    assert http.post("/api/cameras/cam/ptz/stop").status_code == 204
    assert agent.cameras.moves == [(3, 0.5, 0, 0), (3, "stop")]
    assert http.post("/api/cameras/fixed/ptz/stop").status_code == 422
