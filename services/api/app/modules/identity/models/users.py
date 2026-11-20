"""Database model of a user."""

from datetime import datetime

from sqlalchemy import Boolean, DateTime, String, false
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel

__all__ = ["User"]


class User(BaseModel):
    """Account that signs in to the web app and the mobile app.

    Attributes:
        username: Unique sign-in name; an account that signed up with an email address uses the address.
        password_hash: Hash of the password, never the password itself.
        email: Email address in lower case, or None for an account created from the settings without one.
        name: Name shown to other members, if given.
        email_verified_at: When the email address was confirmed, or None until it is.
        is_platform_admin: Whether the account administers the whole platform, apart from any organisation role.
    """

    __tablename__ = "users"

    username: Mapped[str] = mapped_column(String(100), unique=True, nullable=False)
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)
    email: Mapped[str | None] = mapped_column(String(255), unique=True, nullable=True)
    name: Mapped[str | None] = mapped_column(String(100), nullable=True)
    email_verified_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    is_platform_admin: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False, server_default=false())
