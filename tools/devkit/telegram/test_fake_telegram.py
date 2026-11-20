import json
import threading
import urllib.error
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

import fake_telegram
import pytest

TOKEN = "123:test-token"
USERNAME = "test_bot"


def call(base, method, path, body=None, headers=None, raw=None):
    data = raw if raw is not None else (json.dumps(body).encode() if body is not None else None)
    hdrs = dict(headers or {})
    if raw is None and body is not None:
        hdrs["Content-Type"] = "application/json"
    request = urllib.request.Request(base + path, data=data, headers=hdrs, method=method)
    try:
        with urllib.request.urlopen(request, timeout=10) as response:
            return response.status, json.loads(response.read())
    except urllib.error.HTTPError as exc:
        return exc.code, json.loads(exc.read())


@pytest.fixture
def base():
    server = fake_telegram.make_server("127.0.0.1", 0, TOKEN, USERNAME)
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    yield f"http://127.0.0.1:{server.server_address[1]}"
    server.shutdown()
    server.server_close()


@pytest.fixture
def hook():
    received = []

    class Recorder(BaseHTTPRequestHandler):
        def do_POST(self):
            length = int(self.headers.get("Content-Length", 0))
            received.append(
                {
                    "secret": self.headers.get("X-Telegram-Bot-Api-Secret-Token"),
                    "body": json.loads(self.rfile.read(length)),
                }
            )
            self.send_response(200)
            self.send_header("Content-Length", "0")
            self.end_headers()

        def log_message(self, *args):
            pass

    server = ThreadingHTTPServer(("127.0.0.1", 0), Recorder)
    threading.Thread(target=server.serve_forever, daemon=True).start()
    yield f"http://127.0.0.1:{server.server_address[1]}/hook", received
    server.shutdown()
    server.server_close()


def bot(base, method, body=None):
    return call(base, "POST", f"/bot{TOKEN}/{method}", body or {})


def multipart(fields, file_name, file_bytes, content_type):
    boundary = "xBOUNDARYx"
    out = b""
    for key, value in fields.items():
        out += f'--{boundary}\r\nContent-Disposition: form-data; name="{key}"\r\n\r\n{value}\r\n'.encode()
    out += (
        (
            f'--{boundary}\r\nContent-Disposition: form-data; name="photo"; filename="{file_name}"\r\n'
            f"Content-Type: {content_type}\r\n\r\n"
        ).encode()
        + file_bytes
        + b"\r\n"
    )
    out += f"--{boundary}--\r\n".encode()
    return out, {"Content-Type": f"multipart/form-data; boundary={boundary}"}


def test_get_me_and_token_check(base):
    status, body = bot(base, "getMe")
    assert status == 200 and body["ok"] is True
    assert body["result"]["username"] == USERNAME and body["result"]["id"] == 7000000001
    status, body = call(base, "GET", "/botwrong/getMe")
    assert status == 401
    assert body == {"ok": False, "error_code": 401, "description": "Unauthorized"}


def test_send_message_recorded(base):
    status, body = bot(base, "sendMessage", {"chat_id": 42, "text": "hello", "parse_mode": "HTML"})
    assert status == 200
    assert body["result"]["chat"] == {"id": 42, "type": "private"}
    assert body["result"]["text"] == "hello"
    status, sent = call(base, "GET", "/fake/sent")
    assert sent[0]["method"] == "sendMessage" and sent[0]["text"] == "hello"
    assert sent[0]["chat_id"] == 42 and sent[0]["parse_mode"] == "HTML"
    status, _ = call(base, "DELETE", "/fake/sent")
    assert call(base, "GET", "/fake/sent")[1] == []


def test_send_photo_multipart(base):
    payload = b"\xff\xd8" + b"x" * 1000
    raw, headers = multipart({"chat_id": "-100", "caption": "motion"}, "a.jpg", payload, "image/jpeg")
    status, body = call(base, "POST", f"/bot{TOKEN}/sendPhoto", headers=headers, raw=raw)
    assert status == 200
    assert body["result"]["photo"][0]["file_size"] == len(payload)
    assert body["result"]["caption"] == "motion"
    assert body["result"]["chat"]["type"] == "group"
    sent = call(base, "GET", "/fake/sent")[1]
    assert sent[0]["method"] == "sendPhoto" and sent[0]["photo_size"] == len(payload)
    assert sent[0]["caption"] == "motion" and sent[0]["chat_id"] == -100


def test_missing_chat_id(base):
    status, body = bot(base, "sendMessage", {"text": "x"})
    assert status == 400 and body["error_code"] == 400
    assert body["description"].startswith("Bad Request")


def test_blocked_chat(base):
    call(base, "POST", "/fake/block", {"chat_id": 7})
    status, body = bot(base, "sendMessage", {"chat_id": 7, "text": "x"})
    assert status == 403
    assert body["description"] == "Forbidden: bot was blocked by the user"
    call(base, "POST", "/fake/unblock", {"chat_id": 7})
    assert bot(base, "sendMessage", {"chat_id": 7, "text": "x"})[0] == 200


def test_get_updates_offsets(base):
    ids = [call(base, "POST", "/fake/update", {"message": {"text": str(i)}})[1]["update_id"] for i in range(3)]
    assert [call(base, "POST", "/fake/update", {"x": 1})[1]["delivered"]] == ["queued"]
    status, body = bot(base, "getUpdates")
    assert [u["update_id"] for u in body["result"]][:3] == ids
    body = bot(base, "getUpdates", {"offset": ids[1]})[1]
    assert [u["update_id"] for u in body["result"]][0] == ids[1]
    body = bot(base, "getUpdates", {"offset": ids[2] + 2})[1]
    assert body["result"] == []
    body = bot(base, "getUpdates")[1]
    assert body["result"] == []


def test_get_updates_conflict_with_webhook(base):
    assert bot(base, "setWebhook", {"url": "http://127.0.0.1:1/x"}) == (200, {"ok": True, "result": True})
    status, body = bot(base, "getUpdates")
    assert status == 409 and body["error_code"] == 409
    assert bot(base, "getWebhookInfo")[1]["result"]["url"] == "http://127.0.0.1:1/x"
    bot(base, "deleteWebhook")
    assert bot(base, "getUpdates")[0] == 200


def test_start_private_to_webhook(base, hook):
    url, received = hook
    bot(base, "setWebhook", {"url": url, "secret_token": "s3cret"})
    status, body = call(base, "POST", "/fake/start", {"chat_id": 55, "token": "abc123"})
    assert status == 200 and body["delivered"] == "webhook" and body["webhook_status"] == 200
    assert received[0]["secret"] == "s3cret"
    message = received[0]["body"]["message"]
    assert received[0]["body"]["update_id"] == body["update_id"]
    assert message["text"] == "/start abc123"
    assert message["chat"]["id"] == 55 and message["chat"]["type"] == "private"


def test_start_group_to_webhook(base, hook):
    url, received = hook
    bot(base, "setWebhook", {"url": url, "secret_token": "s3cret"})
    spec = {"chat_id": 900, "token": "grp1", "chat_type": "supergroup", "title": "Home"}
    status, body = call(base, "POST", "/fake/start", spec)
    assert status == 200 and body["webhook_status"] == 200
    message = received[0]["body"]["message"]
    assert message["text"] == f"/start@{USERNAME} grp1"
    assert message["chat"]["id"] == -900 and message["chat"]["type"] == "supergroup"
    assert message["chat"]["title"] == "Home"


def test_start_queued_without_webhook(base):
    body = call(base, "POST", "/fake/start", {"chat_id": 5, "token": "t"})[1]
    assert body["delivered"] == "queued" and body["webhook_status"] is None
    updates = bot(base, "getUpdates")[1]["result"]
    assert updates[0]["message"]["text"] == "/start t"


def test_unknown_method(base):
    status, body = bot(base, "doesNotExist")
    assert status == 404
    assert body == {"ok": False, "error_code": 404, "description": "Not Found: method not found"}
