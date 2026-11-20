"""Schemas of organisations."""

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field, field_validator

from app.modules.organisations.enums import Role
from app.modules.organisations.schemas.sites import SiteCreate, SiteRead

__all__ = [
    "FacesConsent",
    "OrganisationCreate",
    "OrganisationList",
    "OrganisationRead",
    "OrganisationUpdate",
    "OwnershipTransfer",
]


class OrganisationCreate(BaseModel):
    """Request to create an organisation, of which the caller becomes the owner.

    Attributes:
        name: Display name.
        site: First site, created with the organisation when given.
    """

    name: str = Field(min_length=1, max_length=100)
    site: SiteCreate | None = None

    @field_validator("name")
    @classmethod
    def strip_name(cls, value: str) -> str:
        """Trim the name and refuse a blank one.

        Args:
            value: Raw name.

        Returns:
            The trimmed name.

        Raises:
            ValueError: The name is blank.
        """
        value = value.strip()
        if not value:
            raise ValueError("must not be blank")
        return value


class OrganisationUpdate(BaseModel):
    """Request to change an organisation; only the fields sent change.

    Attributes:
        name: Display name.
        faces_enabled: Turns face recognition on or off for every site.
        faces_consent: Must be true, together with consent_version, to turn face recognition on.
        consent_version: Version of the consent text the member was shown.
    """

    name: str | None = Field(default=None, min_length=1, max_length=100)
    faces_enabled: bool | None = None
    faces_consent: bool | None = None
    consent_version: str | None = Field(default=None, max_length=20)


class OrganisationRead(BaseModel):
    """An organisation the member belongs to.

    Attributes:
        uuid: Public id.
        name: Display name.
        role: The member's role.
        faces_enabled: Whether face recognition is on.
        faces_consent_at: When the consent text was last accepted.
        site_count: Sites the member may reach.
        member_count: Members of the organisation.
        sites: Sites the member may reach.
        created_at: When the organisation was created.
    """

    uuid: UUID
    name: str
    role: Role
    faces_enabled: bool
    faces_consent_at: datetime | None
    site_count: int
    member_count: int
    sites: list[SiteRead]
    created_at: datetime


class OrganisationList(BaseModel):
    """Organisations the member belongs to.

    Attributes:
        items: The organisations, oldest membership first.
    """

    items: list[OrganisationRead]


class FacesConsent(BaseModel):
    """The text a member accepts to turn face recognition on.

    Attributes:
        version: Version to send back as consent_version.
        text: The consent text.
    """

    version: str
    text: str


class OwnershipTransfer(BaseModel):
    """Request to make another member the owner.

    Attributes:
        member: Public id of the membership that becomes the owner; the current owner becomes an admin.
    """

    member: UUID
