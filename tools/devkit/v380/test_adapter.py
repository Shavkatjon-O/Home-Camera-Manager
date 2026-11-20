import asyncio
import json
import os
import stat

import httpx
import pytest
from camera_adapters.base import AdapterError, Target
from camera_adapters.v380 import records
from camera_adapters.v380.adapter import V380Adapter
from camera_adapters.v380.client import Camera, Timeouts
from camera_adapters.v380.control import ControlServer, socket_path
from camera_adapters.v380.relay import Relay, RelayConfig, go2rtc_config, handle
from camera_adapters.v380.router import ROUTERS, CommandRouter
from camera_adapters.v380.streamer import Streamer
from simulator import Config, Simulator

FAST = Timeouts(connect=2.0, first_byte=2.0, gap=0.2, silence=3.0)


def run(coroutine):
    return asyncio.run(asyncio.wait_for(coroutine, 60))


@pytest.fixture(autouse=True)
def control_dir(tmp_path, monkeypatch):
    directory = tmp_path / "c"
    monkeypatch.setenv("SSS_V380_CONTROL_DIR", str(directory))
    ROUTERS.clear()
    return directory


async def started(**options):
    simulator = Simulator(Config(host="127.0.0.1", port=0, discovery_port=0, seed=3, audio="none", **options))
    port = await simulator.start()
    return simulator, port


def controls(simulator):
    return [event["hex"] for event in simulator.events if event["event"] == "control"]


def test_a_camera_is_identified_over_its_protocol():
    async def scenario():
        simulator, port = await started()
        try:
            target = Target(host="127.0.0.1", port=port, device_id="12345678", password="secret123")
            return await V380Adapter(FAST).identify(target), simulator.events
        finally:
            await simulator.stop()

    identity, events = run(scenario())
    channel = identity.channels[0]
    assert (channel.width, channel.height, channel.encoding) == (2304, 2592, "h265")
    assert (channel.main_path, channel.sub_path) == ("/main", "/sub")
    assert identity.serial == "12345678" and identity.firmware == "device version 32"
    assert identity.manifest.media.sub and not identity.manifest.control.presets
    logins = [event["stream"] for event in events if event["event"] == "stream_login"]
    assert logins == [0, 1]


def test_a_wrong_password_is_unauthorized():
    async def scenario():
        simulator, port = await started()
        try:
            await V380Adapter(FAST).identify(Target(host="127.0.0.1", port=port, device_id="12345678", password="x"))
        finally:
            await simulator.stop()

    with pytest.raises(AdapterError) as caught:
        run(scenario())
    assert caught.value.code == "unauthorized"


def test_moves_use_a_short_session_of_their_own_without_a_stream_process():
    async def scenario():
        simulator, port = await started()
        target = Target(host="127.0.0.1", port=port, device_id="12345678", password="secret123")
        adapter = V380Adapter(FAST)
        try:
            await adapter.move(target, 1, -0.4, 0.1, 0)
            await adapter.stop(target, 1)
            await adapter.set_light(target, 1, "on")
            await adapter.flip(target, 1)
            with pytest.raises(AdapterError):
                await adapter.set_picture(target, 1, "sepia")
            logins = sum(1 for event in simulator.events if event["event"] == "stream_login")
            for router in ROUTERS.values():
                await router.close()
            await asyncio.sleep(0.1)
            return controls(simulator), logins
        finally:
            await simulator.stop()

    hexes, logins = run(scenario())
    assert hexes == [
        records.ptz_record("left").hex(),
        records.ptz_record("stop").hex(),
        records.light_record("on").hex(),
        records.flip_record().hex(),
    ]
    assert logins == 1


def test_closing_the_short_session_stops_a_running_move():
    async def scenario():
        simulator, port = await started()
        target = Target(host="127.0.0.1", port=port, device_id="12345678", password="secret123")
        try:
            await V380Adapter(FAST).move(target, 1, 0, -1, 0)
            for router in ROUTERS.values():
                await router.close()
            await asyncio.sleep(0.1)
            return controls(simulator)
        finally:
            await simulator.stop()

    assert run(scenario()) == [records.ptz_record("down").hex(), records.ptz_record("stop").hex()]


def test_moves_go_through_the_stream_process_that_holds_the_session(control_dir):
    async def scenario():
        simulator, port = await started()
        camera = Camera("127.0.0.1", 12345678, "secret123", port=port)

        async def sink(frame):
            return None

        streamer = Streamer(camera, sink, stream=records.Stream.MAIN, timeouts=FAST, discover=False)
        server = ControlServer(socket_path(str(control_dir), 12345678, "main"), streamer.command)
        await server.start()
        task = asyncio.create_task(streamer.run())
        try:
            for _ in range(50):
                if streamer.session is not None:
                    break
                await asyncio.sleep(0.05)
            target = Target(host="127.0.0.1", port=port, device_id="12345678", password="secret123")
            await V380Adapter(FAST).move(target, 1, 0, 0.7, 0)
            await V380Adapter(FAST).stop(target, 1)
            await V380Adapter(FAST).set_siren(target, 1, False)
            await asyncio.sleep(0.1)
            streamer.stop()
            await asyncio.wait_for(task, 5)
            logins = [event["stream"] for event in simulator.events if event["event"] == "stream_login"]
            return controls(simulator), logins
        finally:
            await server.stop()
            await simulator.stop()

    hexes, logins = run(scenario())
    assert hexes == [
        records.ptz_record("up").hex(),
        records.ptz_record("stop").hex(),
        records.siren_record(False).hex(),
    ]
    assert logins == [1]


def test_the_go2rtc_source_keeps_the_password_off_the_command_line(control_dir):
    source = V380Adapter().go2rtc_source(
        Target(host="192.0.2.10", device_id="12345678", password="not on the line"), "sub"
    )
    assert source.startswith("exec:") and source.endswith("#killsignal=15#killtimeout=5")
    assert "not on the line" not in source
    assert "--stream sub" in source and "--device-id 12345678" in source
    secret = control_dir / "12345678.password"
    assert secret.read_text() == "not on the line"
    assert stat.S_IMODE(os.stat(secret).st_mode) == 0o600


def relay_for(port, control_dir):
    camera = Camera("127.0.0.1", 12345678, "secret123", port=port)
    relay = Relay(RelayConfig(camera=camera, directory=str(control_dir)))
    relay.router = CommandRouter(camera, str(control_dir), linger=0.5, timeouts=FAST)
    return relay


def test_the_relay_api_routes_commands(control_dir):
    async def scenario():
        simulator, port = await started()
        relay = relay_for(port, control_dir)
        try:
            results = [
                await handle(relay, "GET", "/api/status"),
                await handle(relay, "POST", "/api/ptz/right"),
                await handle(relay, "POST", "/api/ptz/stop"),
                await handle(relay, "POST", "/api/light/auto"),
                await handle(relay, "POST", "/api/picture/colour"),
                await handle(relay, "POST", "/api/siren/off"),
                await handle(relay, "POST", "/api/light/sideways"),
                await handle(relay, "POST", "/api/zoom/in"),
                await handle(relay, "GET", "/api/ptz/left"),
            ]
            await relay.router.close()
            await asyncio.sleep(0.1)
            return results, controls(simulator)
        finally:
            await simulator.stop()

    results, hexes = run(scenario())
    assert results[0] == (200, {"status": "running", "streams": {}})
    assert [status for status, _ in results[1:]] == [200, 200, 200, 200, 200, 400, 404, 405]
    assert hexes == [
        records.ptz_record("right").hex(),
        records.ptz_record("stop").hex(),
        records.light_record("auto").hex(),
        records.picture_record("colour").hex(),
        records.siren_record(False).hex(),
    ]


def test_the_relay_answers_over_http_and_the_adapter_controls_through_it(control_dir):
    async def scenario():
        simulator, port = await started()
        relay = relay_for(port, control_dir)
        server = await asyncio.start_server(relay.http, "127.0.0.1", 0)
        api = server.sockets[0].getsockname()[1]
        try:
            async with httpx.AsyncClient() as http:
                status = (await http.get(f"http://127.0.0.1:{api}/api/status")).json()
                light = await http.post(f"http://127.0.0.1:{api}/api/light/on")
                siren = await http.post(f"http://127.0.0.1:{api}/api/siren/on", params={"seconds": "1"})
            await asyncio.sleep(1.8)
            await relay.router.close()
            await asyncio.sleep(0.1)
            return status, light.status_code, siren.status_code, controls(simulator)
        finally:
            server.close()
            await simulator.stop()

    status, light, siren, hexes = run(scenario())
    assert status["status"] == "running" and light == 200 and siren == 200
    assert hexes[0] == records.light_record("on").hex()
    assert hexes[-1] == records.siren_record(False).hex()
    assert hexes.count(records.siren_record(True).hex()) >= 2


def test_an_unreachable_camera_makes_the_relay_unavailable(control_dir):
    async def scenario():
        relay = relay_for(1, control_dir)
        return await handle(relay, "GET", "/api/status"), await handle(relay, "POST", "/api/ptz/left")

    status, move = run(scenario())
    assert status == (200, {"status": "unreachable", "streams": {}})
    assert move[0] == 503


def test_the_relay_gives_go2rtc_exec_sources_without_the_password(control_dir):
    config = RelayConfig(
        camera=Camera("192.0.2.10", 12345678, "hidden"),
        directory=str(control_dir),
        rtsp_username="tv",
        rtsp_password="p",
    )
    settings = json.loads(go2rtc_config(config))
    assert set(settings["streams"]) == {"main", "sub"}
    assert all(source.startswith("exec:") and "hidden" not in source for source in settings["streams"].values())
    assert settings["rtsp"] == {"listen": ":8554", "username": "tv", "password": "p"}
    env = {"SSS_V380_HOST": "192.0.2.10", "SSS_V380_DEVICE_ID": "12345678", "SSS_V380_PASSWORD": "x"}
    assert RelayConfig.from_env(env | {"SSS_V380_STREAMS": "sub"}).streams == ("sub",)
    with pytest.raises(ValueError):
        RelayConfig.from_env({"SSS_V380_HOST": "192.0.2.10"})
