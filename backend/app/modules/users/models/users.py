"""Database model of a user."""

from sqlalchemy import String
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel

__all__ = ["User"]


class User(BaseModel):
    """Account that can sign in to the wall.

    Attributes:
        username: Unique sign-in name.
        password_hash: Hash of the password, never the password itself.
    """

    __tablename__ = "users"

    username: Mapped[str] = mapped_column(String(100), unique=True, nullable=False)
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)
