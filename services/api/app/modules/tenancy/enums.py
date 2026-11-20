"""Enumerations of the organisations module."""

from enum import StrEnum

__all__ = ["Role", "SiteKind", "role_rank"]


class Role(StrEnum):
    """Role of a member in an organisation, from the least to the most powerful."""

    VIEWER = "viewer"
    OPERATOR = "operator"
    ADMIN = "admin"
    OWNER = "owner"


ROLE_ORDER = (Role.VIEWER, Role.OPERATOR, Role.ADMIN, Role.OWNER)


def role_rank(role: Role | str) -> int:
    """Return how powerful a role is.

    Args:
        role: Role or its value.

    Returns:
        0 for viewer up to 3 for owner.
    """
    return ROLE_ORDER.index(Role(role))


class SiteKind(StrEnum):
    """Kind of place a site is."""

    HOME = "home"
    STORE = "store"
    OFFICE = "office"
    WAREHOUSE = "warehouse"
    OTHER = "other"
