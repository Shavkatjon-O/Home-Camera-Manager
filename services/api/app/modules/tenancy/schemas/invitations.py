"""Schemas of invitations."""

from datetime import datetime
from enum import StrEnum
from uuid import UUID

from pydantic import BaseModel, Field, field_validator, model_validator

from app.modules.identity.schemas.auth import clean_email
from app.modules.tenancy.enums import Role

__all__ = ["InvitationCreate", "InvitationList", "InvitationPreview", "InvitationRead", "InvitationStatus"]


class InvitationStatus(StrEnum):
    """State of an invitation."""

    PENDING = "pending"
    ACCEPTED = "accepted"
    REVOKED = "revoked"
    EXPIRED = "expired"


class InvitationCreate(BaseModel):
    """Request to invite someone into the organisation.

    Attributes:
        email: Address the invitation is mailed to; only the account with this address can accept it.
        role: Role the invitee receives; owner cannot be given by invitation.
        all_sites: Whether the membership covers every site.
        sites: Sites it covers when it does not cover all.
    """

    email: str = Field(min_length=3, max_length=255)
    role: Role = Role.VIEWER
    all_sites: bool = True
    sites: list[UUID] = Field(default_factory=list, max_length=500)

    @field_validator("email")
    @classmethod
    def normalize_email(cls, value: str) -> str:
        """Lowercase the address and check its shape.

        Args:
            value: Raw address.

        Returns:
            The cleaned address.
        """
        return clean_email(value)

    @model_validator(mode="after")
    def check_scope(self):
        """Refuse an owner invitation and a site list that names no site.

        Returns:
            The validated request.

        Raises:
            ValueError: The role is owner, or the invitation covers no site.
        """
        if self.role == Role.OWNER:
            raise ValueError("owner is given by a transfer of ownership, not by invitation")
        if not self.all_sites and not self.sites:
            raise ValueError("name at least one site or cover all sites")
        return self


class InvitationRead(BaseModel):
    """An invitation as its organisation's admins see it.

    Attributes:
        uuid: Public id.
        email: Invited address.
        role: Role it gives.
        all_sites: Whether it covers every site.
        sites: Sites it covers when it does not cover all.
        status: pending, accepted, revoked or expired.
        expires_at: When it stops working.
        invited_by: Name or address of the member who sent it.
        created_at: When it was sent.
        accepted_at: When it was accepted.
    """

    uuid: UUID
    email: str
    role: Role
    all_sites: bool
    sites: list[UUID]
    status: InvitationStatus
    expires_at: datetime
    invited_by: str | None
    created_at: datetime
    accepted_at: datetime | None


class InvitationList(BaseModel):
    """Invitations of an organisation.

    Attributes:
        items: The invitations, newest first.
    """

    items: list[InvitationRead]


class InvitationPreview(BaseModel):
    """What an invitation link offers, shown before signing in to accept it.

    Attributes:
        organisation: Name of the organisation.
        role: Role it gives.
        invited_by: Name or address of the member who sent it.
        email: Invited address.
        status: pending, accepted, revoked or expired.
        expires_at: When it stops working.
    """

    organisation: str
    role: Role
    invited_by: str | None
    email: str
    status: InvitationStatus
    expires_at: datetime
