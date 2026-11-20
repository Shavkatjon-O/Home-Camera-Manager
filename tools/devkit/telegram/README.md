# Fake Telegram Bot API

A standard-library Python server that stands in for https://api.telegram.org in the development kit and in tests. The API alert channel calls it through SSS_TELEGRAM_API_URL=http://telegram:8081, with FAKE_TELEGRAM_TOKEN as the bot token. It records every message and photo the API sends and lets a developer or a test simulate a user opening the bot deep link. It never contacts the real Telegram service and holds no photo bytes.

## Routes

Bot API routes answer POST or GET /bot<token>/<method> with JSON, form or multipart bodies. A wrong token answers 401. Control routes live under /fake and need no token.

| Route | Purpose |
|---|---|
| getMe | Bot user with the configured username |
| sendMessage | Records the message; answers a Message object; 400 without chat_id or text; 403 for a blocked chat |
| sendPhoto | Records the photo size and caption from the multipart file part named photo; answers a Message object with a photo array |
| setWebhook | Stores url and secret_token; optional drop_pending_updates clears the queue |
| deleteWebhook | Removes the webhook |
| getWebhookInfo | Answers url and pending_update_count |
| getUpdates | Returns queued updates from offset, confirming earlier ones; waits up to 2 seconds; 409 while a webhook is set |
| leaveChat | Answers true |
| getChat | Answers id, type and title |
| any other method | Answers 404 |
| GET /fake/sent | Lists recorded sends in order with method, chat_id, text or caption, photo_size, parse_mode and at |
| DELETE /fake/sent | Clears the record |
| POST /fake/start | Builds the update of a start deep link and delivers it |
| POST /fake/update | Delivers any raw update JSON with an assigned update_id |
| POST /fake/block | Makes send methods answer 403 for chat_id |
| POST /fake/unblock | Reverses block |
| GET /fake/health | Answers ok |

Delivery posts the update to the webhook URL with the header X-Telegram-Bot-Api-Secret-Token set to the stored secret, or queues it for getUpdates when no webhook is set. The answer carries update_id, delivered (webhook or queued) and webhook_status.

## Environment

| Variable | Default | Meaning |
|---|---|---|
| FAKE_TELEGRAM_PORT | 8081 | Listening port |
| FAKE_TELEGRAM_TOKEN | devkit-fake-token | The only accepted bot token |
| FAKE_TELEGRAM_USERNAME | sss_devkit_bot | Bot username used in getMe and group start text |

## Simulate a user linking a chat

A private chat opening https://t.me/sss_devkit_bot?start=TOKEN:

```
curl -s -X POST http://127.0.0.1:8081/fake/start -H 'Content-Type: application/json' \
  -d '{"chat_id": 4242, "token": "TOKEN", "chat_type": "private"}'
```

Adding the bot to a group with ?startgroup=TOKEN sends the text /start@sss_devkit_bot TOKEN from a chat with a negative id:

```
curl -s -X POST http://127.0.0.1:8081/fake/start -H 'Content-Type: application/json' \
  -d '{"chat_id": 900, "token": "TOKEN", "chat_type": "group", "title": "Home"}'
```

Read what the API sent afterwards:

```
curl -s http://127.0.0.1:8081/fake/sent
```

## Run and test

The image builds from the Dockerfile in this folder and runs as the non-root user 10001. Locally:

```
FAKE_TELEGRAM_TOKEN=devkit-fake-token python fake_telegram.py
```

The tests need pytest and no network beyond 127.0.0.1:

```
python -m pytest -q
```
