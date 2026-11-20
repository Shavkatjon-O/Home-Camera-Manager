"""Schemas of members."""

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field

from app.modules.organisations.enums import Role

__all__ = ["MemberList", "MemberRead", "MemberUpdate"]


class MemberRead(BaseModel):
    """A member of an organisation.

    Attributes:
        uuid: Public id of the membership.
        user: Public id of the user.
        email: Email address of the user.
        name: Display name of the user.
        role: Role in the organisation.
        all_sites: Whether the membership covers every site.
        sites: Sites it covers when it does not cover all.
        joined_at: When the membership began.
        you: Whether this is the caller's own membership.
    """

    uuid: UUID
    user: UUID
    email: str | None
    name: str | None
    role: Role
    all_sites: bool
    sites: list[UUID]
    joined_at: datetime
    you: bool


class MemberList(BaseModel):
    """Members of an organisation.

    Attributes:
        items: The members, oldest first.
    """

    items: list[MemberRead]


class MemberUpdate(BaseModel):
    """Request to change a member's role or sites; only the fields sent change.

    Attributes:
        role: New role; owner is given only by a transfer of ownership.
        all_sites: Whether the membership covers every site.
        sites: Sites it covers when it does not cover all.
    """

    role: Role | None = None
    all_sites: bool | None = None
    sites: list[UUID] | None = Field(default=None, max_length=500)
