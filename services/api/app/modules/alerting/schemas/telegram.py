"""Schemas of Telegram alert chats."""

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel

__all__ = ["TelegramChatList", "TelegramChatRead", "TelegramLinkRead", "TelegramWebhookAck"]


class TelegramLinkRead(BaseModel):
    """Single-use deep links that connect a chat to the organisation.

    Attributes:
        url: Link that opens a private chat with the bot.
        group_url: Link that adds the bot to a group.
        bot: Username of the bot.
        expires_at: When the links stop working.
    """

    url: str
    group_url: str
    bot: str
    expires_at: datetime


class TelegramChatRead(BaseModel):
    """A chat that receives the organisation's alerts.

    Attributes:
        uuid: Public id.
        chat_type: private, group, supergroup or channel.
        title: Group title or the person's name.
        enabled: Whether alerts are sent to it.
        blocked: Whether the bot was blocked or removed there.
        created_at: When it was first linked.
    """

    uuid: UUID
    chat_type: str
    title: str | None
    enabled: bool
    blocked: bool
    created_at: datetime


class TelegramChatList(BaseModel):
    """The organisation's Telegram chats.

    Attributes:
        items: The chats, newest first.
        available: Whether Telegram alerts are set up on this server.
    """

    items: list[TelegramChatRead]
    available: bool


class TelegramWebhookAck(BaseModel):
    """Answer to a Telegram webhook call.

    Attributes:
        ok: Always true once the update was taken.
        result: What the update did: linked, unknown_link, stopped, removed or ignored.
    """

    ok: bool
    result: str
