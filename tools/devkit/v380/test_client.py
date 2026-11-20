import asyncio
import hashlib
import os
import signal
import subprocess
import sys
from pathlib import Path

import pytest
from camera_adapters.v380 import records
from camera_adapters.v380.audio import AudioFormat, adpcm_decode, pcm_bytes
from camera_adapters.v380.client import AudioFrame, Camera, Session, Timeouts, VideoFrame, first_key_frame
from camera_adapters.v380.control import ControlServer, send
from camera_adapters.v380.discovery import discover
from camera_adapters.v380.errors import LoginRefused, SessionLost, StreamRefused
from camera_adapters.v380.streamer import Streamer
from media import h264_access_units, h265_access_units
from simulator import Config, Simulator, transcript_media

FAST = Timeouts(connect=2.0, first_byte=2.0, gap=0.2, silence=3.0)


def run(coroutine):
    return asyncio.run(asyncio.wait_for(coroutine, 60))


async def started(**options):
    simulator = Simulator(Config(host="127.0.0.1", port=0, discovery_port=0, seed=1, **options))
    port = await simulator.start()
    return simulator, Camera(host="127.0.0.1", device_id=12345678, password="secret123", port=port)


async def collect(session, count, kinds=(VideoFrame, AudioFrame)):
    out = []
    async for frame in session.frames():
        if isinstance(frame, kinds):
            out.append(frame)
        if len(out) >= count:
            return out
    return out


def source(stream, fps=15, codec="h265"):
    gop = fps * 2
    if codec == "h264":
        units = h264_access_units(gop, 12000, 1500)
    else:
        units = h265_access_units(stream, gop, 30000 if stream == "main" else 12000, 3000 if stream == "main" else 1200)
    return {next(units).data for _ in range(gop * 2)}


def test_the_transcript_matches_the_specification():
    assert len(transcript_media()) == 1408
    assert hashlib.sha256(transcript_media()).hexdigest() == (
        "62c3176aabc395eda85c9930b48bf1d64c5f76c3f53b14f6bdf134264bad17c0"
    )

    async def scenario():
        simulator, camera = await started(transcript=True)
        try:
            session = Session(camera, records.Stream.SUB, sound=True, timeouts=FAST)
            await session.open()
            frames = await collect(session, 5)
            await session.ptz(records.PtzMove.LEFT)
            await session.ptz(records.PtzMove.STOP)
            await asyncio.sleep(0.2)
            await session.close()
            await asyncio.sleep(0.1)
            return frames, session.facts, simulator.events
        finally:
            await simulator.stop()

    frames, facts, events = run(scenario())
    kinds = [frame.format.value if isinstance(frame, AudioFrame) else "video" for frame in frames]
    assert kinds == ["pcm_s16le", "video", "video", "aac_adts", "alaw"]
    video = b"".join(frame.data for frame in frames if isinstance(frame, VideoFrame))
    assert len(video) == 531
    assert hashlib.sha256(video).hexdigest() == "846d743ee62dd231e9c34c22d36635a85c07df298a15d42702050dc63b442387"
    block = bytes.fromhex("e8030a00") + bytes(range(252))
    assert frames[0].data == pcm_bytes(adpcm_decode(block))
    assert hashlib.sha256(frames[0].data).hexdigest() == (
        "5afe464b1e3fe4ebc142904fb62c596a00a70445e1d66541a9835c83878d2232"
    )
    assert frames[3].data == bytes.fromhex("fff96c4020fffc") + bytes(range(256))
    assert frames[4].data == bytes(range(160))
    assert (facts.codec, facts.width, facts.height) == ("h265", 640, 720)
    assert (facts.device_version, facts.comm_version, facts.encrypted) == (32, 20, True)
    assert facts.audio_config == "1588"
    login = next(event for event in events if event["event"] == "login")
    assert login["result"] == 1001 and login["random_key_ok"]
    stream = next(event for event in events if event["event"] == "stream_login")
    assert stream["ticket"] == 0x0BADF00D and stream["sound"] and stream["valid"]
    controls = [event["hex"] for event in events if event["event"] == "control"]
    assert controls == [records.ptz_record("left").hex(), records.ptz_record("stop").hex()]


def test_generated_main_stream_with_audio_arrives_whole():
    async def scenario():
        simulator, camera = await started(fps=30, audio="adpcm")
        try:
            async with Session(camera, records.Stream.MAIN, sound=True, timeouts=FAST) as session:
                frames = await collect(session, 40)
                return frames, session.facts
        finally:
            await simulator.stop()

    frames, facts = run(scenario())
    video = [frame for frame in frames if isinstance(frame, VideoFrame)]
    audio = [frame for frame in frames if isinstance(frame, AudioFrame)]
    assert video[0].key
    assert {frame.data for frame in video} <= source("main", 30)
    assert all(frame.format == AudioFormat.PCM and len(frame.data) == 1010 for frame in audio)
    assert (facts.codec, facts.width, facts.height, facts.rate) == ("h265", 2304, 2592, 30)
    assert facts.audio == "pcm_s16le" and facts.dropped == 0


def test_audio_is_ignored_unless_asked_for():
    async def scenario():
        simulator, camera = await started(fps=30, audio="alaw")
        try:
            async with Session(camera, records.Stream.SUB, sound=False, timeouts=FAST) as session:
                return await collect(session, 10)
        finally:
            await simulator.stop()

    assert all(isinstance(frame, VideoFrame) for frame in run(scenario()))


@pytest.mark.parametrize("fault", ["missing-fragment", "repeated-fragment", "count-change"])
def test_damaged_frames_are_dropped_and_never_delivered(fault):
    async def scenario():
        simulator, camera = await started(fps=60, audio="none", faults={fault: ""}, fault_every=3, fragment_size=500)
        try:
            async with Session(camera, records.Stream.SUB, timeouts=FAST) as session:
                frames = await collect(session, 60)
                return frames, session.facts
        finally:
            await simulator.stop()

    frames, facts = run(scenario())
    assert {frame.data for frame in frames} <= source("sub", 60)
    assert facts.dropped > 0


@pytest.mark.parametrize("fault", ["invalid-header", "unknown-type", "leading-bytes", "interleave-audio"])
def test_framing_faults_keep_the_session(fault):
    async def scenario():
        simulator, camera = await started(fps=60, audio="alaw", faults={fault: ""}, fault_every=4, fragment_size=3000)
        try:
            async with Session(camera, records.Stream.SUB, sound=True, timeouts=FAST) as session:
                frames = await collect(session, 50)
                return frames, session.facts
        finally:
            await simulator.stop()

    frames, facts = run(scenario())
    video = [frame.data for frame in frames if isinstance(frame, VideoFrame)]
    audio = [frame for frame in frames if isinstance(frame, AudioFrame)]
    assert len(video) > 10
    assert set(video) <= source("sub", 60)
    assert all(len(frame.data) == 160 for frame in audio)
    if fault == "invalid-header":
        assert facts.resyncs > 0


@pytest.mark.parametrize(
    ("fault", "codec", "size", "encrypted"),
    [
        ("clear-media", "h265", (640, 720), False),
        ("comm21", "h265", (640, 720), True),
        ("h264", "h264", (640, 480), True),
    ],
)
def test_version_differences(fault, codec, size, encrypted):
    async def scenario():
        simulator, camera = await started(fps=60, audio="none", faults={fault: ""})
        try:
            async with Session(camera, records.Stream.SUB, timeouts=FAST) as session:
                frames = await collect(session, 10)
                return frames, session.facts
        finally:
            await simulator.stop()

    frames, facts = run(scenario())
    assert {frame.data for frame in frames} <= source("sub", 60, codec)
    assert (facts.codec, (facts.width, facts.height), facts.encrypted) == (codec, size, encrypted)
    assert facts.comm_version == (21 if fault == "comm21" else 20)


def test_a_change_of_parameter_sets_passes_through():
    async def scenario():
        simulator, camera = await started(fps=30, audio="none", faults={"parameter-change": ""})
        sizes = []
        try:
            async with Session(camera, records.Stream.SUB, timeouts=FAST) as session:
                async for frame in session.frames():
                    if frame.key:
                        sizes.append((session.facts.width, session.facts.height))
                    if len(sizes) == 3:
                        return sizes
        finally:
            await simulator.stop()

    assert run(scenario()) == [(640, 720), (2304, 2592), (640, 720)]


def test_the_low_latency_rewrite_applies_to_key_frames():
    async def scenario():
        simulator, camera = await started(fps=30, audio="none")
        try:
            async with Session(camera, records.Stream.SUB, low_latency=True, timeouts=FAST) as session:
                return await first_key_frame(session, 5)
        finally:
            await simulator.stop()

    rewritten = bytes.fromhex(
        "42010101400000030090000003000003005aa0050200b459ebb91295cd404080b8400000030040000003039515ff7840fa01775f080410"
    )
    assert rewritten in run(scenario()).data


@pytest.mark.parametrize(
    ("options", "camera_change", "result"),
    [
        ({"faults": {"refuse-login": "1012"}}, {}, 1012),
        ({}, {"password": "wrong"}, 1012),
        ({}, {"device_id": 999}, 1018),
        ({}, {"username": "guest"}, 1011),
    ],
)
def test_refused_logins_report_their_reason(options, camera_change, result):
    async def scenario():
        simulator, camera = await started(**options)
        try:
            fields = {**camera.__dict__, **camera_change}
            await Session(Camera(**fields), timeouts=FAST).open()
        finally:
            await simulator.stop()

    with pytest.raises(LoginRefused) as error:
        run(scenario())
    assert error.value.result == result and error.value.code == "unauthorized"


def test_a_refused_stream_login_is_reported():
    async def scenario():
        simulator, camera = await started(faults={"refuse-stream": ""})
        try:
            await Session(camera, timeouts=FAST).open()
        finally:
            await simulator.stop()

    with pytest.raises(StreamRefused):
        run(scenario())


@pytest.mark.parametrize("fault", ["split-reply", "full-reply"])
def test_stream_login_replies_of_any_shape_are_read(fault):
    async def scenario():
        simulator, camera = await started(fps=30, audio="none", faults={fault: ""})
        try:
            async with Session(camera, timeouts=FAST) as session:
                return await first_key_frame(session, 5)
        finally:
            await simulator.stop()

    assert run(scenario()).key


def test_an_unreachable_camera_is_reported():
    async def scenario():
        await Session(Camera("127.0.0.1", 1, "x", port=1), timeouts=FAST).open()

    with pytest.raises(Exception) as error:
        run(scenario())
    assert getattr(error.value, "code", None) == "unreachable"


def test_silence_ends_the_session_and_the_streamer_reconnects():
    async def scenario():
        simulator, camera = await started(fps=30, audio="none", faults={"silence": "2"}, fault_every=10)
        received = []

        async def sink(frame):
            received.append(frame)

        streamer = Streamer(camera, sink, timeouts=Timeouts(2.0, 2.0, 0.2, 0.8), discover=False)
        streamer.backoff.next = lambda: 0.1
        try:
            await streamer.run(sessions=2)
        finally:
            await simulator.stop()
        return received, simulator.events

    received, events = run(scenario())
    assert sum(1 for event in events if event["event"] == "stream_login") == 2
    assert received[0].key


def test_a_connection_closed_mid_frame_is_a_lost_session():
    async def scenario():
        simulator, camera = await started(fps=30, audio="none", faults={"close-mid-frame": ""}, fault_every=5)
        try:
            async with Session(camera, timeouts=FAST) as session:
                frames = []
                with pytest.raises(SessionLost):
                    async for frame in session.frames():
                        frames.append(frame)
                return frames
        finally:
            await simulator.stop()

    frames = run(scenario())
    assert 0 < len(frames) < 5
    assert {frame.data for frame in frames} <= source("sub", 30)


def test_a_second_session_drops_the_first_when_the_camera_allows_one():
    async def scenario():
        simulator, camera = await started(fps=30, audio="none", faults={"single-session": ""})
        try:
            first = Session(camera, timeouts=FAST)
            await first.open()
            await first_key_frame(first, 5)
            second = Session(camera, timeouts=FAST)
            await second.open()
            with pytest.raises(SessionLost):
                await collect(first, 1000)
            await first.close()
            await second.close()
        finally:
            await simulator.stop()

    run(scenario())


def test_discovery_finds_the_simulated_camera():
    async def scenario():
        simulator = Simulator(Config(host="127.0.0.1", port=0, discovery_port=0))
        simulator.config.discovery_port = 0
        await simulator.start()
        loop = asyncio.get_running_loop()
        from simulator import Discovery

        transport, _ = await loop.create_datagram_endpoint(
            lambda: Discovery(simulator), local_addr=("127.0.0.1", 0)
        )
        port = transport.get_extra_info("sockname")[1]
        try:
            return await discover(("127.0.0.1",), port=port, listen_port=0, rounds=2, round_seconds=0.2, limited=False)
        finally:
            transport.close()
            await simulator.stop()

    found = run(scenario())
    assert [camera.device_id for camera in found] == ["12345678"]
    assert found[0].host == "127.0.0.1"


def test_control_commands_reach_the_camera_through_the_socket(tmp_path):
    async def scenario():
        simulator, camera = await started(fps=30, audio="none")

        async def sink(frame):
            return None

        streamer = Streamer(camera, sink, timeouts=FAST, discover=False)
        path = tmp_path / "c" / "12345678-sub.sock"
        server = ControlServer(path, streamer.command)
        await server.start()
        task = asyncio.create_task(streamer.run())
        try:
            for _ in range(50):
                if streamer.session is not None:
                    break
                await asyncio.sleep(0.05)
            assert (await send(path, {"command": "ptz", "move": "right"}))["ok"]
            assert (await send(path, {"command": "light", "mode": "auto"}))["ok"]
            assert (await send(path, {"command": "picture", "mode": "black_and_white"}))["ok"]
            assert (await send(path, {"command": "siren", "seconds": 1.2}))["ok"]
            assert not (await send(path, {"command": "ptz", "move": "sideways"}))["ok"]
            facts = await send(path, {"command": "facts"})
            await asyncio.sleep(1.6)
            streamer.stop()
            await asyncio.wait_for(task, 5)
            await asyncio.sleep(0.2)
            return facts, [event for event in simulator.events if event["event"] == "control"]
        finally:
            await server.stop()
            await simulator.stop()

    facts, controls = run(scenario())
    assert facts["ok"] and facts["open"] and facts["facts"]["codec"] == "h265"
    hexes = [event["hex"] for event in controls]
    assert hexes[0] == records.ptz_record("right").hex()
    assert hexes[1] == records.light_record("auto").hex()
    assert hexes[2] == records.picture_record("black_and_white").hex()
    sirens = [value for value in hexes if value.startswith("b9")]
    assert sirens[-1] == records.siren_record(False).hex()
    assert 3 <= sirens.count(records.siren_record(True).hex()) <= 4
    assert hexes[-1] == records.ptz_record("stop").hex()
    assert not controls[-1]["moving"]


def test_a_forgotten_move_is_stopped():
    async def scenario():
        simulator, camera = await started(fps=30, audio="none")
        try:
            session = Session(camera, timeouts=FAST, max_move=0.3)
            await session.open()
            await session.ptz(records.PtzMove.UP)
            await asyncio.sleep(0.6)
            await session.close()
            await asyncio.sleep(0.1)
            return [event["hex"] for event in simulator.events if event["event"] == "control"]
        finally:
            await simulator.stop()

    assert run(scenario()) == [records.ptz_record("up").hex(), records.ptz_record("stop").hex()]


def test_the_stream_command_writes_annex_b_for_go2rtc(tmp_path):
    async def scenario():
        simulator, camera = await started(fps=30, audio="none")
        env = {**os.environ, "SSS_V380_PASSWORD": "secret123", "PYTHONPATH": str(Path(__file__).parent)}
        process = await asyncio.create_subprocess_exec(
            sys.executable,
            "-m",
            "camera_adapters.v380",
            "stream",
            "--host",
            "127.0.0.1",
            "--port",
            str(camera.port),
            "--device-id",
            "12345678",
            "--stream",
            "sub",
            "--control-dir",
            str(tmp_path / "c"),
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=env,
        )
        try:
            data = b""
            while len(data) < 40000:
                chunk = await asyncio.wait_for(process.stdout.read(65536), 10)
                if not chunk:
                    break
                data += chunk
            control = await send(tmp_path / "c" / "12345678-sub.sock", {"command": "ptz", "move": "left"})
            process.send_signal(signal.SIGTERM)
            code = await asyncio.wait_for(process.wait(), 10)
            await asyncio.sleep(0.2)
            hexes = [event["hex"] for event in simulator.events if event["event"] == "control"]
            return data, control, code, hexes
        finally:
            if process.returncode is None:
                process.kill()
            await simulator.stop()

    data, control, code, hexes = run(scenario())
    assert data.startswith(b"\0\0\0\1\x40\x01")
    assert control["ok"]
    assert code == 0
    assert hexes == [records.ptz_record("left").hex(), records.ptz_record("stop").hex()]
