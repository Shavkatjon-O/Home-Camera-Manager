import httpx

from connector_agent.cameras import CameraManager, rtsp_source, stream_names
from connector_agent.go2rtc import Go2rtc, go2rtc_config
from connector_agent.state import Store

UUID_ONE = "6f1c2c1e-1111-4a5b-9c1d-000000000001"
UUID_TWO = "6f1c2c1e-1111-4a5b-9c1d-000000000002"


class Recorder:
    def __init__(self, current=None):
        self.current = current or {}
        self.calls = []

    def __call__(self, request):
        if request.method == "GET":
            return httpx.Response(200, json=self.current)
        self.calls.append((request.method, request.url.params.multi_items()))
        return httpx.Response(200)


def manager(tmp_path, recorder):
    go2rtc = Go2rtc("go2rtc", "127.0.0.1:1984", transport=httpx.MockTransport(recorder))
    return CameraManager(Store(str(tmp_path)), go2rtc)


def config(**changes):
    return {
        "name": "Gate",
        "brand": "onvif",
        "host": "192.168.1.20",
        "rtsp_port": 554,
        "main_path": "/main",
        "sub_path": "/sub",
        "username": "admin",
        "password": "p@ss:word",
        "channel": 2,
        **changes,
    }


def test_sources_quote_the_credentials_and_names_match_central():
    assert stream_names(UUID_ONE) == ("6f1c2c1e11114a5b9c1d000000000001_main", "6f1c2c1e11114a5b9c1d000000000001_sub")


async def test_a_camera_is_streamed_and_keeps_its_password_when_central_sends_none(tmp_path):
    recorder = Recorder()
    cameras = manager(tmp_path, recorder)
    camera = await cameras.put(UUID_ONE, config())
    assert rtsp_source(camera, "/main") == "rtsp://admin:p%40ss%3Aword@192.168.1.20:554/main"
    assert camera.channel == 2
    puts = [params for method, params in recorder.calls if method == "PUT"]
    assert len(puts) == 2 and ("src", "rtsp://admin:p%40ss%3Aword@192.168.1.20:554/sub") in puts[1]
    again = await cameras.put(UUID_ONE, config(password=None, name="Gate two"))
    assert again.credentials.password == "p@ss:word" and again.name == "Gate two"
    removed = await cameras.put(UUID_ONE, config(password=""))
    assert removed.credentials.password is None


async def test_reconcile_follows_central_and_keeps_local_credentials(tmp_path):
    main, _ = stream_names(UUID_TWO)
    recorder = Recorder({main: {"producers": [{"url": "rtsp://old"}]}, "stray": {"producers": []}})
    cameras = manager(tmp_path, recorder)
    await cameras.put(UUID_ONE, config())
    listing = {
        "cameras": [
            {**config(), "uuid": UUID_ONE, "password": None, "username": None, "enabled": True},
            {**config(sub_path=None), "uuid": UUID_TWO, "enabled": False},
        ]
    }
    await cameras.reconcile(listing)
    assert cameras.cameras[UUID_ONE].credentials.password == "p@ss:word"
    assert set(cameras.desired()) == set(stream_names(UUID_ONE))
    deleted = [dict(params)["src"] for method, params in recorder.calls if method == "DELETE"]
    assert set(deleted) == {main, "stray"}
    await cameras.reconcile({"cameras": []})
    assert cameras.cameras == {} and Store(str(tmp_path)).cameras() == {}


def test_go2rtc_runs_without_webrtc_and_with_the_central_login():
    text = go2rtc_config("127.0.0.1:1984", 8554, "central", "secret")
    assert '"webrtc": {"listen": ""}' in text and '"username": "central"' in text and '"listen": ":8554"' in text


async def test_a_v380_camera_with_its_device_id_streams_through_the_client(tmp_path, monkeypatch):
    monkeypatch.setenv("SSS_V380_CONTROL_DIR", str(tmp_path / "v380"))
    recorder = Recorder()
    cameras = manager(tmp_path, recorder)
    v380 = config(brand="v380", rtsp_port=8554, password="cam secret", device_id="12345678")
    await cameras.put(UUID_ONE, v380)
    main, sub = stream_names(UUID_ONE)
    sources = cameras.desired()
    assert sources[main][0].startswith("exec:") and "--stream main" in sources[main][0]
    assert sources[sub][0].startswith("exec:") and "--stream sub" in sources[sub][0]
    assert "cam secret" not in sources[main][0]
    assert (tmp_path / "v380" / "12345678.password").read_text() == "cam secret"
    await cameras.put(UUID_TWO, config(brand="v380", host="v380-relay", rtsp_port=8554))
    relay_main, _ = stream_names(UUID_TWO)
    assert cameras.desired()[relay_main] == ["rtsp://admin:p%40ss%3Aword@v380-relay:8554/main"]
