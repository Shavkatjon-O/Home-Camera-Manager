"""Database models of Telegram alert chats and the single-use links that connect them."""

from datetime import datetime

from sqlalchemy import BigInteger, Boolean, DateTime, ForeignKey, String, UniqueConstraint, true
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel
from app.models.ownership import OrganisationOwned

__all__ = ["TelegramChat", "TelegramLink"]


class TelegramChat(OrganisationOwned, BaseModel):
    """A Telegram chat or group that receives an organisation's alerts.

    Attributes:
        chat_id: Telegram's id of the chat; negative for groups.
        chat_type: private, group, supergroup or channel.
        title: Title of the group, or the name of the person of a private chat.
        linked_by_id: Member who opened the link that connected it.
        enabled: Whether alerts are sent to it.
        blocked_at: When Telegram reported that the bot was blocked or removed, after which nothing is sent.
    """

    __tablename__ = "telegram_chats"
    __table_args__ = (UniqueConstraint("organisation_id", "chat_id", name="uq_telegram_chat"),)

    chat_id: Mapped[int] = mapped_column(BigInteger, nullable=False, index=True)
    chat_type: Mapped[str] = mapped_column(String(20), nullable=False)
    title: Mapped[str | None] = mapped_column(String(255), nullable=True)
    linked_by_id: Mapped[int | None] = mapped_column(
        BigInteger, ForeignKey("users.id", ondelete="SET NULL"), nullable=True
    )
    enabled: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True, server_default=true())
    blocked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)


class TelegramLink(OrganisationOwned, BaseModel):
    """A single-use token a bot deep link carries, connecting the chat that opens it to an organisation.

    Attributes:
        token_hash: SHA-256 of the token; the token itself is only in the link.
        created_by_id: Member who created the link.
        expires_at: When the link stops working.
        used_at: When a chat used it.
    """

    __tablename__ = "telegram_links"

    token_hash: Mapped[str] = mapped_column(String(64), unique=True, nullable=False)
    created_by_id: Mapped[int | None] = mapped_column(
        BigInteger, ForeignKey("users.id", ondelete="SET NULL"), nullable=True
    )
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    used_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
