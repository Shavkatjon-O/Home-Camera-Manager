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
