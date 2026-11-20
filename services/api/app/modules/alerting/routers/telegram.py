"""Telegram alert endpoints: chat links and chats for admins, and the webhook Telegram calls."""

from uuid import UUID

from fastapi import APIRouter, Body, Depends, Header, Response, status

from app.core.exceptions import Forbidden
from app.modules.alerting.deps import get_telegram_service
from app.modules.alerting.schemas.telegram import TelegramChatList, TelegramLinkRead, TelegramWebhookAck
from app.modules.alerting.services.telegram import TelegramService, telegram_bot
from app.modules.billing.deps import require_feature
from app.modules.billing.enums import Feature
from app.modules.operations.deps import audited
from app.modules.operations.enums import AuditAction

router = APIRouter()
webhook_router = APIRouter()

TELEGRAM = Depends(require_feature(Feature.TELEGRAM_ALERTS))


@router.post("/links", response_model=TelegramLinkRead, status_code=status.HTTP_201_CREATED, dependencies=[TELEGRAM])
async def create_telegram_link(service: TelegramService = Depends(get_telegram_service)) -> TelegramLinkRead:
    """Create single-use bot deep links that connect a Telegram chat or group; admins and owners only.

    Args:
        service: Telegram service.

    Returns:
        The links and when they expire.
    """
    return await service.create_link()


@router.get("/chats", response_model=TelegramChatList)
async def list_telegram_chats(service: TelegramService = Depends(get_telegram_service)) -> TelegramChatList:
    """List the Telegram chats that receive the organisation's alerts; admins and owners only.

    Args:
        service: Telegram service.

    Returns:
        The chats.
    """
    return await service.chats()


@router.delete(
    "/chats/{uuid}",
    status_code=status.HTTP_204_NO_CONTENT,
    response_class=Response,
    dependencies=[Depends(audited(AuditAction.ALERT_CHANNEL_REMOVE, "telegram_chat"))],
)
async def remove_telegram_chat(uuid: UUID, service: TelegramService = Depends(get_telegram_service)) -> Response:
    """Stop sending alerts to a chat; admins and owners only.

    Args:
        uuid: Public id of the chat.
        service: Telegram service.

    Returns:
        An empty answer.
    """
    await service.remove(uuid)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post(
    "/chats/{uuid}/test", status_code=status.HTTP_204_NO_CONTENT, response_class=Response, dependencies=[TELEGRAM]
)
async def test_telegram_chat(uuid: UUID, service: TelegramService = Depends(get_telegram_service)) -> Response:
    """Send a test message to a chat; admins and owners only.

    Args:
        uuid: Public id of the chat.
        service: Telegram service.

    Returns:
        An empty answer.
    """
    await service.test(uuid)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@webhook_router.post("/webhook", response_model=TelegramWebhookAck)
async def receive_telegram_update(
    update: dict = Body(...),
    secret: str | None = Header(None, alias="X-Telegram-Bot-Api-Secret-Token"),
) -> TelegramWebhookAck:
    """Take an update Telegram delivers; only calls with the configured secret are accepted.

    Args:
        update: The Telegram update.
        secret: The secret header Telegram sends.

    Returns:
        What the update did.

    Raises:
        Forbidden: The secret is missing or wrong.
    """
    if not telegram_bot.authentic(secret):
        raise Forbidden("bad_webhook_secret", "The webhook secret is wrong")
    return TelegramWebhookAck(ok=True, result=await telegram_bot.handle(update))
