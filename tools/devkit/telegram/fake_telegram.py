"""Fake Telegram Bot API server for the development kit and tests.

The server answers the Bot API methods the alert channel uses, records every sent message, and lets a developer
simulate a user opening the bot deep link through the /fake control routes.

Attributes:
    BOT_ID: Numeric id reported by getMe.
    MAX_POLL_SECONDS: Longest real wait performed by getUpdates.
"""

from __future__ import annotations

import json
import os
import signal
import sys
import threading
import time
import urllib.error
import urllib.request
from email.parser import BytesParser
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from typing import Any
from urllib.parse import parse_qsl, urlsplit

BOT_ID = 7000000001
MAX_POLL_SECONDS = 2.0
WEBHOOK_TIMEOUT_SECONDS = 5.0
BLOCKED_DESCRIPTION = "Forbidden: bot was blocked by the user"
CONFLICT_DESCRIPTION = (
    "Conflict: can't use getUpdates method while webhook is active; use deleteWebhook to delete the webhook first"
)


class ApiError(Exception):
    """Error that is answered with the Bot API error shape.

    Attributes:
        code: HTTP status and Bot API error code.
        description: Human readable error description.
    """

    def __init__(self, code: int, description: str) -> None:
        """Builds the error.

        Args:
            code: HTTP status and Bot API error code.
            description: Human readable error description.
        """
        super().__init__(description)
        self.code = code
        self.description = description


class FakeState:
    """Thread-safe state of the fake bot.

    Attributes:
        token: The only bot token that is accepted.
        username: Username of the fake bot.
        lock: Lock guarding every field.
        cond: Condition notified when an update is queued.
        sent: Recorded sent messages and photos in order.
        updates: Updates queued for getUpdates.
        blocked: Chat ids that answer 403 on send methods.
        webhook: Current webhook settings, or None when no webhook is set.
        next_update_id: Id assigned to the next update.
        next_message_id: Id assigned to the next sent message.
    """

    def __init__(self, token: str, username: str) -> None:
        """Creates an empty state.

        Args:
            token: The only bot token that is accepted.
            username: Username of the fake bot.
        """
        self.token = token
        self.username = username
        self.lock = threading.Lock()
        self.cond = threading.Condition(self.lock)
        self.sent: list[dict[str, Any]] = []
        self.updates: list[dict[str, Any]] = []
        self.blocked: set[int] = set()
        self.webhook: dict[str, Any] | None = None
        self.next_update_id = 1
        self.next_message_id = 1

    def new_message_id(self) -> int:
        """Allocates a message id.

        Returns:
            The next message id.
        """
        with self.lock:
            message_id = self.next_message_id
            self.next_message_id += 1
        return message_id

    def is_blocked(self, chat_id: Any) -> bool:
        """Tells whether a chat is marked blocked.

        Args:
            chat_id: Chat id as received.

        Returns:
            True when sending to the chat must answer 403.
        """
        with self.lock:
            return chat_id in self.blocked

    def record_sent(self, entry: dict[str, Any]) -> None:
        """Appends a sent message to the log.

        Args:
            entry: The log entry.
        """
        with self.lock:
            self.sent.append(entry)

    def deliver(self, update: dict[str, Any]) -> dict[str, Any]:
        """Assigns an update id and delivers the update by webhook or queue.

        Args:
            update: Raw update without an update_id.

        Returns:
            The delivery answer with update_id, delivered and webhook_status.
        """
        with self.lock:
            update_id = self.next_update_id
            self.next_update_id += 1
            body = {"update_id": update_id, **{k: v for k, v in update.items() if k != "update_id"}}
            webhook = dict(self.webhook) if self.webhook else None
            if webhook is None:
                self.updates.append(body)
                self.cond.notify_all()
        if webhook is None:
            return {"update_id": update_id, "delivered": "queued", "webhook_status": None}
        return {"update_id": update_id, "delivered": "webhook", "webhook_status": post_webhook(webhook, body)}


def post_webhook(webhook: dict[str, Any], body: dict[str, Any]) -> int | None:
    """Posts an update to the webhook URL.

    Args:
        webhook: Stored webhook settings with url and secret_token.
        body: The update to send.

    Returns:
        The HTTP status of the answer, or None when the webhook was unreachable.
    """
    headers = {"Content-Type": "application/json"}
    if webhook.get("secret_token"):
        headers["X-Telegram-Bot-Api-Secret-Token"] = webhook["secret_token"]
    request = urllib.request.Request(webhook["url"], data=json.dumps(body).encode(), headers=headers, method="POST")
    try:
        with urllib.request.urlopen(request, timeout=WEBHOOK_TIMEOUT_SECONDS) as response:
            return response.status
    except urllib.error.HTTPError as exc:
        return exc.code
    except (urllib.error.URLError, OSError):
        return None


def parse_multipart(content_type: str, body: bytes) -> dict[str, Any]:
    """Parses a multipart/form-data body.

    File parts are reduced to their size and content type; the bytes are dropped.

    Args:
        content_type: Value of the Content-Type header.
        body: Raw request body.

    Returns:
        Mapping of field name to text, or to a dict with size and content_type for file parts.
    """
    raw = b"MIME-Version: 1.0\r\nContent-Type: " + content_type.encode() + b"\r\n\r\n" + body
    message = BytesParser().parsebytes(raw)
    fields: dict[str, Any] = {}
    if not message.is_multipart():
        return fields
    for part in message.get_payload():
        name = part.get_param("name", header="content-disposition")
        if not name:
            continue
        payload = part.get_payload(decode=True) or b""
        if part.get_filename() is not None:
            fields[str(name)] = {
                "size": len(payload),
                "content_type": part.get_content_type(),
                "filename": part.get_filename(),
            }
        else:
            fields[str(name)] = payload.decode("utf-8", errors="replace")
    return fields


def parse_params(content_type: str, body: bytes, query: str) -> dict[str, Any]:
    """Merges query, form, multipart and JSON parameters of a request.

    Args:
        content_type: Value of the Content-Type header.
        body: Raw request body.
        query: Raw query string.

    Returns:
        The merged parameters, body values winning over query values.

    Raises:
        ApiError: When a JSON body is not valid or not an object.
    """
    params: dict[str, Any] = dict(parse_qsl(query))
    kind = content_type.split(";")[0].strip().lower()
    if not body:
        return params
    if kind == "application/json":
        try:
            data = json.loads(body)
        except ValueError as exc:
            raise ApiError(400, "Bad Request: can't parse JSON body") from exc
        if not isinstance(data, dict):
            raise ApiError(400, "Bad Request: JSON body must be an object")
        params.update(data)
    elif kind == "application/x-www-form-urlencoded":
        params.update(parse_qsl(body.decode("utf-8", errors="replace")))
    elif kind == "multipart/form-data":
        params.update(parse_multipart(content_type, body))
    return params


def normalize_chat_id(value: Any) -> Any:
    """Converts a chat id to an integer when it looks like one.

    Args:
        value: Chat id as received.

    Returns:
        The integer id, or the original value when it is not numeric.
    """
    if isinstance(value, bool):
        return value
    if isinstance(value, int):
        return value
    if isinstance(value, str) and value.lstrip("-").isdigit():
        return int(value)
    return value


def chat_object(chat_id: Any) -> dict[str, Any]:
    """Builds a minimal chat object.

    Args:
        chat_id: The chat id.

    Returns:
        A chat dict whose type is group for negative ids and private otherwise.
    """
    group = isinstance(chat_id, int) and chat_id < 0
    return {"id": chat_id, "type": "group" if group else "private"}


class Bot:
    """Implements the Bot API methods on top of a FakeState.

    Attributes:
        state: The shared fake state.
    """

    def __init__(self, state: FakeState) -> None:
        """Creates the bot.

        Args:
            state: The shared fake state.
        """
        self.state = state

    def call(self, method: str, params: dict[str, Any]) -> Any:
        """Runs one Bot API method.

        Args:
            method: Method name as in the URL.
            params: Merged request parameters.

        Returns:
            The value of the result field.

        Raises:
            ApiError: On an unknown method or a rejected request.
        """
        handler = getattr(self, "api_" + method, None) if method.isalnum() else None
        if handler is None:
            raise ApiError(404, "Not Found: method not found")
        return handler(params)

    def checked_chat(self, params: dict[str, Any]) -> Any:
        """Validates the chat id of a send request.

        Args:
            params: Request parameters.

        Returns:
            The normalized chat id.

        Raises:
            ApiError: When chat_id is missing or the chat is blocked.
        """
        chat_id = normalize_chat_id(params.get("chat_id"))
        if chat_id in (None, ""):
            raise ApiError(400, "Bad Request: chat_id is empty")
        if self.state.is_blocked(chat_id):
            raise ApiError(403, BLOCKED_DESCRIPTION)
        return chat_id

    def api_getMe(self, params: dict[str, Any]) -> dict[str, Any]:  # noqa: N802
        """Answers getMe.

        Args:
            params: Request parameters, unused.

        Returns:
            The bot user object.
        """
        return {"id": BOT_ID, "is_bot": True, "first_name": "Smart Surveillance", "username": self.state.username}

    def api_sendMessage(self, params: dict[str, Any]) -> dict[str, Any]:  # noqa: N802
        """Answers sendMessage and records the message.

        Args:
            params: Request parameters.

        Returns:
            The sent Message object.

        Raises:
            ApiError: On a missing chat_id or text, or a blocked chat.
        """
        chat_id = self.checked_chat(params)
        text = params.get("text")
        if not text:
            raise ApiError(400, "Bad Request: message text is empty")
        now = int(time.time())
        self.state.record_sent(
            {
                "method": "sendMessage",
                "chat_id": chat_id,
                "text": text,
                "parse_mode": params.get("parse_mode"),
                "at": now,
            }
        )
        return {
            "message_id": self.state.new_message_id(),
            "date": now,
            "chat": chat_object(chat_id),
            "text": text,
        }

    def api_sendPhoto(self, params: dict[str, Any]) -> dict[str, Any]:  # noqa: N802
        """Answers sendPhoto and records the photo size.

        Args:
            params: Request parameters, with the photo as a file part or a string.

        Returns:
            The sent Message object with a photo array.

        Raises:
            ApiError: On a missing chat_id or photo, or a blocked chat.
        """
        chat_id = self.checked_chat(params)
        photo = params.get("photo")
        if not photo:
            raise ApiError(400, "Bad Request: there is no photo in the request")
        size = photo["size"] if isinstance(photo, dict) else 0
        content_type = photo["content_type"] if isinstance(photo, dict) else None
        now = int(time.time())
        caption = params.get("caption")
        self.state.record_sent(
            {
                "method": "sendPhoto",
                "chat_id": chat_id,
                "caption": caption,
                "photo_size": size,
                "photo_content_type": content_type,
                "parse_mode": params.get("parse_mode"),
                "at": now,
            }
        )
        message_id = self.state.new_message_id()
        message: dict[str, Any] = {
            "message_id": message_id,
            "date": now,
            "chat": chat_object(chat_id),
            "photo": [
                {
                    "file_id": f"photo-{message_id}",
                    "file_unique_id": f"u{message_id}",
                    "width": 0,
                    "height": 0,
                    "file_size": size,
                }
            ],
        }
        if caption:
            message["caption"] = caption
        return message

    def api_setWebhook(self, params: dict[str, Any]) -> bool:  # noqa: N802
        """Stores the webhook settings.

        Args:
            params: Request parameters with url, secret_token, allowed_updates and drop_pending_updates.

        Returns:
            True.

        Raises:
            ApiError: When url is missing.
        """
        url = params.get("url")
        if not url:
            raise ApiError(400, "Bad Request: bad webhook: URL is empty")
        drop = str(params.get("drop_pending_updates", "")).lower() in ("true", "1")
        with self.state.lock:
            self.state.webhook = {
                "url": url,
                "secret_token": params.get("secret_token"),
                "allowed_updates": params.get("allowed_updates"),
            }
            if drop:
                self.state.updates.clear()
        return True

    def api_deleteWebhook(self, params: dict[str, Any]) -> bool:  # noqa: N802
        """Removes the webhook.

        Args:
            params: Request parameters with the optional drop_pending_updates.

        Returns:
            True.
        """
        drop = str(params.get("drop_pending_updates", "")).lower() in ("true", "1")
        with self.state.lock:
            self.state.webhook = None
            if drop:
                self.state.updates.clear()
        return True

    def api_getWebhookInfo(self, params: dict[str, Any]) -> dict[str, Any]:  # noqa: N802
        """Answers getWebhookInfo.

        Args:
            params: Request parameters, unused.

        Returns:
            The webhook info with url and pending_update_count.
        """
        with self.state.lock:
            url = self.state.webhook["url"] if self.state.webhook else ""
            return {"url": url, "has_custom_certificate": False, "pending_update_count": len(self.state.updates)}

    def api_getUpdates(self, params: dict[str, Any]) -> list[dict[str, Any]]:  # noqa: N802
        """Answers getUpdates with offset confirmation and a short long poll.

        Args:
            params: Request parameters with offset, timeout and limit.

        Returns:
            Queued updates with update_id at or above the offset.

        Raises:
            ApiError: With 409 while a webhook is set.
        """
        offset = to_int(params.get("offset"), 0)
        timeout = min(max(to_int(params.get("timeout"), 0), 0), MAX_POLL_SECONDS)
        limit = min(max(to_int(params.get("limit"), 100), 1), 100)
        deadline = time.monotonic() + timeout
        with self.state.cond:
            while True:
                if self.state.webhook is not None:
                    raise ApiError(409, CONFLICT_DESCRIPTION)
                if offset:
                    self.state.updates = [u for u in self.state.updates if u["update_id"] >= offset]
                ready = [u for u in self.state.updates if u["update_id"] >= offset]
                remaining = deadline - time.monotonic()
                if ready or remaining <= 0:
                    return ready[:limit]
                self.state.cond.wait(remaining)

    def api_leaveChat(self, params: dict[str, Any]) -> bool:  # noqa: N802
        """Answers leaveChat.

        Args:
            params: Request parameters with chat_id.

        Returns:
            True.

        Raises:
            ApiError: When chat_id is missing.
        """
        if normalize_chat_id(params.get("chat_id")) in (None, ""):
            raise ApiError(400, "Bad Request: chat_id is empty")
        return True

    def api_getChat(self, params: dict[str, Any]) -> dict[str, Any]:  # noqa: N802
        """Answers getChat.

        Args:
            params: Request parameters with chat_id.

        Returns:
            A minimal chat object with id, type and title.

        Raises:
            ApiError: When chat_id is missing.
        """
        chat_id = normalize_chat_id(params.get("chat_id"))
        if chat_id in (None, ""):
            raise ApiError(400, "Bad Request: chat_id is empty")
        chat = chat_object(chat_id)
        chat["title"] = f"Fake chat {chat_id}"
        return chat


def to_int(value: Any, default: int) -> int:
    """Converts a parameter to an integer.

    Args:
        value: Parameter value as received.
        default: Value used when conversion fails.

    Returns:
        The integer value or the default.
    """
    try:
        return int(value)
    except (TypeError, ValueError):
        return default


def build_start_update(state: FakeState, spec: dict[str, Any]) -> dict[str, Any]:
    """Builds the update a client sends when a user opens a start deep link.

    Args:
        state: The shared fake state, used for the bot username and message ids.
        spec: Request with chat_id, token, chat_type, title and user.

    Returns:
        A raw update without an update_id.

    Raises:
        ApiError: When chat_id or token is missing or invalid.
    """
    chat_id = normalize_chat_id(spec.get("chat_id"))
    token = spec.get("token")
    if not isinstance(chat_id, int) or isinstance(chat_id, bool) or not token:
        raise ApiError(400, "Bad Request: chat_id (integer) and token are required")
    chat_type = spec.get("chat_type") or ("private" if chat_id > 0 else "group")
    if chat_type not in ("private", "group", "supergroup"):
        raise ApiError(400, "Bad Request: chat_type must be private, group or supergroup")
    user = spec.get("user") or {}
    sender = {
        "id": user.get("id", abs(chat_id)),
        "is_bot": False,
        "first_name": user.get("first_name", "Dev"),
        "username": user.get("username", "dev_user"),
    }
    chat: dict[str, Any] = {"id": chat_id, "type": chat_type}
    if chat_type == "private":
        chat["first_name"] = sender["first_name"]
        chat["username"] = sender["username"]
        text = f"/start {token}"
        command_length = len("/start")
    else:
        chat["id"] = -abs(chat_id)
        chat["title"] = spec.get("title") or f"Fake group {abs(chat_id)}"
        text = f"/start@{state.username} {token}"
        command_length = len(f"/start@{state.username}")
    message = {
        "message_id": state.new_message_id(),
        "from": sender,
        "chat": chat,
        "date": int(time.time()),
        "text": text,
        "entities": [{"offset": 0, "length": command_length, "type": "bot_command"}],
    }
    return {"message": message}


class Handler(BaseHTTPRequestHandler):
    """HTTP handler for the Bot API and control routes.

    Attributes:
        server_version: Server header value.
        protocol_version: HTTP protocol version spoken.
    """

    server_version = "FakeTelegram/1.0"
    protocol_version = "HTTP/1.1"

    @property
    def state(self) -> FakeState:
        """Gives the shared state.

        Returns:
            The state stored on the server object.
        """
        return self.server.state  # type: ignore[attr-defined]

    def log_message(self, format: str, *args: Any) -> None:  # noqa: A002
        """Logs one line per request without the query, tokens or bodies.

        Args:
            format: Unused standard log format.
            *args: Unused standard log arguments.
        """
        path = urlsplit(self.path).path
        if path.startswith("/bot"):
            parts = path.split("/")
            path = "/bot<token>/" + (parts[2] if len(parts) > 2 else "")
        sys.stderr.write(f"{self.command} {path} -> {getattr(self, 'last_status', '-')}\n")

    def reply(self, status: int, payload: Any) -> None:
        """Writes a JSON answer.

        Args:
            status: HTTP status.
            payload: JSON-serializable body.
        """
        data = json.dumps(payload).encode()
        self.last_status = status
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def read_body(self) -> bytes:
        """Reads the request body.

        Returns:
            The raw body, empty when there is none.
        """
        length = to_int(self.headers.get("Content-Length"), 0)
        return self.rfile.read(length) if length > 0 else b""

    def dispatch(self) -> None:
        """Routes the request and converts errors to the Bot API error shape."""
        try:
            body = self.read_body()
            split = urlsplit(self.path)
            if split.path.startswith("/fake/"):
                status, payload = self.fake(split.path, body)
                self.reply(status, payload)
            elif split.path.startswith("/bot") and self.command in ("GET", "POST"):
                self.bot_route(split, body)
            else:
                raise ApiError(404, "Not Found")
        except ApiError as exc:
            self.reply(exc.code, {"ok": False, "error_code": exc.code, "description": exc.description})

    def bot_route(self, split: Any, body: bytes) -> None:
        """Serves /bot<token>/<method>.

        Args:
            split: The parsed request URL.
            body: Raw request body.

        Raises:
            ApiError: On a bad token, an unknown method or a rejected request.
        """
        parts = split.path[len("/bot") :].split("/")
        if len(parts) != 2 or parts[0] != self.state.token:
            raise ApiError(401, "Unauthorized")
        params = parse_params(self.headers.get("Content-Type", ""), body, split.query)
        result = Bot(self.state).call(parts[1], params)
        self.reply(200, {"ok": True, "result": result})

    def fake(self, path: str, body: bytes) -> tuple[int, Any]:
        """Serves the /fake control routes.

        Args:
            path: Request path.
            body: Raw request body.

        Returns:
            The HTTP status and JSON payload.

        Raises:
            ApiError: On an unknown route or an invalid body.
        """
        route = (self.command, path.rstrip("/"))
        state = self.state
        if route == ("GET", "/fake/health"):
            return 200, {"ok": True}
        if route == ("GET", "/fake/sent"):
            with state.lock:
                return 200, list(state.sent)
        if route == ("DELETE", "/fake/sent"):
            with state.lock:
                state.sent.clear()
            return 200, {"ok": True}
        if self.command != "POST":
            raise ApiError(404, "Not Found")
        data = parse_params("application/json", body, "") if body else {}
        if path.rstrip("/") == "/fake/start":
            return 200, state.deliver(build_start_update(state, data))
        if path.rstrip("/") == "/fake/update":
            if not data:
                raise ApiError(400, "Bad Request: update body is empty")
            return 200, state.deliver(data)
        if path.rstrip("/") in ("/fake/block", "/fake/unblock"):
            chat_id = normalize_chat_id(data.get("chat_id"))
            if not isinstance(chat_id, int):
                raise ApiError(400, "Bad Request: chat_id (integer) is required")
            with state.lock:
                if path.rstrip("/") == "/fake/block":
                    state.blocked.add(chat_id)
                else:
                    state.blocked.discard(chat_id)
            return 200, {"ok": True}
        raise ApiError(404, "Not Found")

    def do_GET(self) -> None:  # noqa: N802
        """Handles GET requests."""
        self.dispatch()

    def do_POST(self) -> None:  # noqa: N802
        """Handles POST requests."""
        self.dispatch()

    def do_DELETE(self) -> None:  # noqa: N802
        """Handles DELETE requests."""
        self.dispatch()


def make_server(host: str, port: int, token: str, username: str) -> ThreadingHTTPServer:
    """Creates the HTTP server with fresh state.

    Args:
        host: Address to bind.
        port: Port to bind, zero for any free port.
        token: The only accepted bot token.
        username: Username of the fake bot.

    Returns:
        The server, with its FakeState on the state attribute.
    """
    server = ThreadingHTTPServer((host, port), Handler)
    server.daemon_threads = True
    server.state = FakeState(token, username)  # type: ignore[attr-defined]
    return server


def main() -> int:
    """Runs the server until SIGTERM or SIGINT.

    Returns:
        The process exit code.
    """
    port = to_int(os.environ.get("FAKE_TELEGRAM_PORT"), 8081)
    token = os.environ.get("FAKE_TELEGRAM_TOKEN", "devkit-fake-token")
    username = os.environ.get("FAKE_TELEGRAM_USERNAME", "sss_devkit_bot")
    server = make_server("0.0.0.0", port, token, username)  # noqa: S104

    def stop(signum: int, frame: Any) -> None:
        """Stops the server from a signal.

        Args:
            signum: Signal number.
            frame: Interrupted frame, unused.
        """
        threading.Thread(target=server.shutdown, daemon=True).start()

    signal.signal(signal.SIGTERM, stop)
    signal.signal(signal.SIGINT, stop)
    sys.stderr.write(f"fake telegram listening on {port} as @{username}\n")
    server.serve_forever()
    server.server_close()
    return 0


if __name__ == "__main__":
    sys.exit(main())
