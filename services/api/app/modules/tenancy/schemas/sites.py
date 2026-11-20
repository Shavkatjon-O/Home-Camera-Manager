"""Schemas of sites."""

from datetime import datetime
from uuid import UUID
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError

from pydantic import BaseModel, Field, field_validator

from app.modules.tenancy.enums import Role, SiteKind

__all__ = ["SiteCreate", "SiteList", "SiteRead", "SiteUpdate", "check_timezone"]


def check_timezone(value: str) -> str:
    """Check that a time zone name is a known IANA zone.

    Args:
        value: Zone name, such as Asia/Tashkent.

    Returns:
        The trimmed name.

    Raises:
        ValueError: The zone is unknown.
    """
    value = value.strip()
    try:
        ZoneInfo(value)
    except (ZoneInfoNotFoundError, ValueError):
        raise ValueError("must be an IANA time zone such as Europe/Berlin")
    return value


class SiteCreate(BaseModel):
    """Request to add a site.

    Attributes:
        name: Display name.
        kind: Kind of place.
        timezone: IANA time zone of the site.
    """

    name: str = Field(min_length=1, max_length=100)
    kind: SiteKind = SiteKind.HOME
    timezone: str = Field(default="UTC", min_length=1, max_length=64)

    @field_validator("timezone")
    @classmethod
    def known_timezone(cls, value: str) -> str:
        """Check the time zone.

        Args:
            value: Zone name.

        Returns:
            The zone name.
        """
        return check_timezone(value)

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


class SiteUpdate(BaseModel):
    """Request to change a site; only the fields sent change.

    Attributes:
        name: Display name.
        kind: Kind of place.
        timezone: IANA time zone.
        position: Order within the organisation.
        event_retention_days: Days to keep the site's events, up to the plan's limit; 0 goes back to the longest
            the plan and the server allow.
    """

    name: str | None = Field(default=None, min_length=1, max_length=100)
    kind: SiteKind | None = None
    timezone: str | None = Field(default=None, min_length=1, max_length=64)
    position: int | None = Field(default=None, ge=0)
    event_retention_days: int | None = Field(default=None, ge=0, le=3650)

    @field_validator("timezone")
    @classmethod
    def known_timezone(cls, value: str | None) -> str | None:
        """Check the time zone.

        Args:
            value: Zone name, if sent.

        Returns:
            The zone name.
        """
        return check_timezone(value) if value is not None else None


class SiteRead(BaseModel):
    """A site the member may reach.

    Attributes:
        uuid: Public id of the site.
        organisation: Public id of its organisation.
        organisation_name: Name of its organisation.
        name: Display name.
        kind: Kind of place.
        timezone: IANA time zone.
        position: Order within the organisation.
        role: The member's role there.
        camera_count: Cameras registered at the site.
        connector_count: Connectors paired to the site.
        event_retention_days: Days the site keeps its events by its own setting, None when it has none.
        effective_event_retention_days: Days its events are actually kept: the shortest of its own setting, the
            plan's limit and the server's retention.
        created_at: When the site was added.
        updated_at: When it last changed.
    """

    uuid: UUID
    organisation: UUID
    organisation_name: str
    name: str
    kind: SiteKind
    timezone: str
    position: int
    role: Role
    camera_count: int
    connector_count: int
    event_retention_days: int | None = None
    effective_event_retention_days: int | None = None
    created_at: datetime
    updated_at: datetime


class SiteList(BaseModel):
    """Sites the member may reach.

    Attributes:
        items: The sites, by organisation and position.
    """

    items: list[SiteRead]
