"""Schemas of the sign-in endpoints."""

from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field

__all__ = ["LoginRequest", "SessionUser"]


class LoginRequest(BaseModel):
    """Credentials sent to sign in.

    Attributes:
        username: Sign-in name.
        password: Account password.
    """

    username: str = Field(min_length=1, max_length=100)
    password: str = Field(min_length=1, max_length=256)


class SessionUser(BaseModel):
    """Public identity of the signed-in user.

    Attributes:
        uuid: Public id of the user.
        username: Sign-in name.
    """

    model_config = ConfigDict(from_attributes=True)

    uuid: UUID
    username: str
