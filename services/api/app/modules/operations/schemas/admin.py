"""Schemas of platform administration."""

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field

__all__ = [
    "AdminConnectorList",
    "AdminConnectorRead",
    "AdminOrganisationList",
    "AdminOrganisationRead",
    "AdminOrganisationUpdate",
    "AdminSuspend",
    "PlanOverrides",
]


class PlanOverrides(BaseModel):
    """Limits and features that differ from an organisation's plan.

    Attributes:
        limits: Limit name to value; null makes the limit unlimited.
        features: Feature name to whether it is on.
    """

    limits: dict[str, int | None] = Field(default_factory=dict)
    features: dict[str, bool] = Field(default_factory=dict)


class AdminOrganisationRead(BaseModel):
    """An organisation as platform admins see it.

    Attributes:
        uuid: Public id.
        name: Name.
        owner: Email or sign-in name of its owner.
        plan: Key of its plan.
        plan_name: Name of its plan.
        limits: Its limits with the overrides applied.
        features: Its features with the overrides applied.
        overrides: Its own overrides.
        usage: Sites, cameras and members in use.
        suspended_at: When it was suspended, if it is.
        suspended_reason: Why.
        created_at: When it was created.
    """

    uuid: UUID
    name: str
    owner: str | None
    plan: str
    plan_name: str
    limits: dict[str, int | None]
    features: list[str]
    overrides: PlanOverrides
    usage: dict[str, int]
    suspended_at: datetime | None
    suspended_reason: str | None
    created_at: datetime


class AdminOrganisationList(BaseModel):
    """A page of organisations.

    Attributes:
        items: The organisations, newest first.
        total: Organisations matching the search.
        page: Page from 1.
        page_size: Organisations per page.
    """

    items: list[AdminOrganisationRead]
    total: int
    page: int
    page_size: int


class AdminOrganisationUpdate(BaseModel):
    """A change of an organisation's plan or overrides.

    Attributes:
        plan: Key of the new plan, unchanged when omitted.
        overrides: New overrides, replacing the old ones, unchanged when omitted.
    """

    plan: str | None = Field(default=None, min_length=1, max_length=30)
    overrides: PlanOverrides | None = None


class AdminSuspend(BaseModel):
    """Why an organisation is suspended.

    Attributes:
        reason: The reason, shown to platform admins.
    """

    reason: str = Field(min_length=1, max_length=200)


class AdminConnectorRead(BaseModel):
    """A connector of any organisation.

    Attributes:
        uuid: Public id.
        name: Name.
        organisation: Its organisation's public id.
        organisation_name: Its organisation's name.
        site: Its site's public id.
        site_name: Its site's name.
        version: Agent version it last reported.
        mode: direct or tunnel.
        online: Whether its last heartbeat is recent.
        last_seen_at: When its last heartbeat arrived.
        revoked_at: When it was revoked, if it was.
    """

    uuid: UUID
    name: str
    organisation: UUID | None
    organisation_name: str | None
    site: UUID | None
    site_name: str | None
    version: str | None
    mode: str
    online: bool
    last_seen_at: datetime | None
    revoked_at: datetime | None


class AdminConnectorList(BaseModel):
    """A page of connectors.

    Attributes:
        items: The connectors, most recently seen first.
        total: Connectors in all.
        page: Page from 1.
        page_size: Connectors per page.
    """

    items: list[AdminConnectorRead]
    total: int
    page: int
    page_size: int
