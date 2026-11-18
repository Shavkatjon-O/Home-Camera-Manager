from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field

__all__ = ["LoginRequest", "SessionUser"]


class LoginRequest(BaseModel):
    username: str = Field(min_length=1, max_length=100)
    password: str = Field(min_length=1, max_length=256)


class SessionUser(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    uuid: UUID
    username: str
