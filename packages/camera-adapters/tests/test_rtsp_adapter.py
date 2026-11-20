import asyncio
import hashlib

import pytest

from camera_adapters.base import AdapterError, Target
from camera_adapters.rtsp.adapter import RtspAdapter
from camera_adapters.rtsp.describe import describe, parse_challenge, parse_sdp, parse_url

SDP = "v=0\r\nm=video 0 RTP/AVP 96\r\na=rtpmap:96 H265/90000\r\nm=audio 0 RTP/AVP 8\r\na=rtpmap:8 PCMA/8000\r\n"
REALM = "camera"
NONCE = "abc123"


def expected(username, password, url):
    first = hashlib.md5(f"{username}:{REALM}:{password}".encode()).hexdigest()
    second = hashlib.md5(f"DESCRIBE:{url}".encode()).hexdigest()
    return hashlib.md5(f"{first}:{NONCE}:{second}".encode()).hexdigest()


async def fake_camera(password: str):
    async def handle(reader, writer):
        while True:
            try:
                head = await reader.readuntil(b"\r\n\r\n")
            except asyncio.IncompleteReadError:
                break
            text = head.decode()
            url = text.split(" ")[1]
            sequence = [line for line in text.split("\r\n") if line.startswith("CSeq")][0].split(":")[1].strip()
            if "Authorization" in text and expected("admin", password, url) in text:
                writer.write(f"RTSP/1.0 200 OK\r\nCSeq: {sequence}\r\nContent-Length: {len(SDP)}\r\n\r\n{SDP}".encode())
            else:
                challenge = f'Digest realm="{REALM}", nonce="{NONCE}"'
                writer.write(
                    f"RTSP/1.0 401 Unauthorized\r\nCSeq: {sequence}\r\nWWW-Authenticate: {challenge}\r\n\r\n".encode()
                )
            await writer.drain()
        writer.close()

    server = await asyncio.start_server(handle, "127.0.0.1", 0)
    return server, server.sockets[0].getsockname()[1]


async def test_describe_answers_a_digest_challenge():
    server, port = await fake_camera("secret")
    async with server:
        info = await describe(f"rtsp://admin:secret@127.0.0.1:{port}/main")
    assert info.codec == "h265" and info.audio


async def test_a_wrong_password_is_unauthorized():
    server, port = await fake_camera("secret")
    async with server:
        with pytest.raises(AdapterError) as caught:
            await describe(f"rtsp://127.0.0.1:{port}/main", "admin", "wrong")
    assert caught.value.code == "unauthorized"


async def test_nothing_listening_is_unreachable():
    with pytest.raises(AdapterError) as caught:
        await describe("rtsp://127.0.0.1:1/main", timeout=1)
    assert caught.value.code == "unreachable"


async def test_the_rtsp_adapter_identifies_a_stream():
    server, port = await fake_camera("secret")
    async with server:
        identity = await RtspAdapter().identify(
            Target(host="127.0.0.1", url=f"rtsp://127.0.0.1:{port}/live?channel=1", username="admin", password="secret")
        )
    assert identity.channels[0].main_path == "/live?channel=1" and identity.channels[0].encoding == "h265"
    assert identity.manifest.media.audio and not identity.manifest.control.ptz


def test_addresses_and_descriptions_parse():
    assert parse_url("rtsp://user:p%40ss@192.168.1.20/stream1")[1:] == (
        554,
        "rtsp://192.168.1.20:554/stream1",
        "user",
        "p@ss",
    )
    with pytest.raises(AdapterError):
        parse_url("http://192.168.1.20/")
    assert parse_challenge('Digest realm="r", nonce="n"') == ("digest", {"realm": "r", "nonce": "n"})
    assert parse_sdp("m=video 0 RTP/AVP 96\na=rtpmap:96 H264/90000\n").codec == "h264"


def test_an_rtsp_label_is_confirmed():
    label = RtspAdapter().parse_label("rtsp://192.168.1.20:8554/live")
    assert label.confirmed and label.url == "rtsp://192.168.1.20:8554/live"
    assert RtspAdapter().parse_label("hello") is None
