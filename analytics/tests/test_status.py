import json
import socket
import urllib.error
import urllib.request

from app.status import StatusServer


def free_port():
    with socket.socket() as probe:
        probe.bind(("127.0.0.1", 0))
        return probe.getsockname()[1]


def fetch(port, path, token=None):
    request = urllib.request.Request(f"http://127.0.0.1:{port}{path}")
    if token:
        request.add_header("Authorization", f"Bearer {token}")
    try:
        with urllib.request.urlopen(request, timeout=5) as response:
            return response.status, response.read(), dict(response.headers)
    except urllib.error.HTTPError as exc:
        return exc.code, exc.read(), dict(exc.headers)


def test_routes_need_the_token_except_health():
    port = free_port()
    server = StatusServer(
        port,
        "secret",
        lambda: {"ok": True},
        lambda view: {"view": view} if view == "a" else None,
        lambda view, reference: (b"\xff\xd8jpeg", "analytics/references/a/1.jpg" if reference else None),
    )
    server.start()
    try:
        assert fetch(port, "/health")[0] == 200
        assert fetch(port, "/status")[0] == 401
        assert fetch(port, "/status", "wrong")[0] == 401
        status, body, _ = fetch(port, "/status", "secret")
        assert status == 200 and json.loads(body) == {"ok": True}
        assert fetch(port, "/views/a/objects", "secret")[0] == 200
        assert fetch(port, "/views/b/objects", "secret")[0] == 404
        status, body, headers = fetch(port, "/views/a/snapshot.jpg?reference=1", "secret")
        assert status == 200 and body.startswith(b"\xff\xd8")
        assert headers.get("X-Reference") == "analytics/references/a/1.jpg"
    finally:
        server.stop()


def post(port, path, data, token=None):
    request = urllib.request.Request(f"http://127.0.0.1:{port}{path}", data=data, method="POST")
    if token:
        request.add_header("Authorization", f"Bearer {token}")
    request.add_header("Content-Type", "image/jpeg")
    try:
        with urllib.request.urlopen(request, timeout=5) as response:
            return response.status, json.loads(response.read())
    except urllib.error.HTTPError as exc:
        return exc.code, json.loads(exc.read())


def test_photos_are_embedded_only_with_the_token():
    port = free_port()
    seen = []

    def embed(data):
        seen.append(data)
        return 200, {"faces": [], "width": 1, "height": 1}

    server = StatusServer(port, "secret", dict, lambda view: None, lambda view, reference: None, embed)
    server.start()
    try:
        assert post(port, "/identity/embed", b"photo")[0] == 401
        status, body = post(port, "/identity/embed", b"photo", "secret")
        assert status == 200 and body["faces"] == []
        assert seen == [b"photo"]
        assert post(port, "/identity/other", b"photo", "secret")[0] == 404
    finally:
        server.stop()
