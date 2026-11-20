"""Identities that authenticated requests carry into services."""

from dataclasses import dataclass
from uuid import UUID


@dataclass(frozen=True)
class UserContext:
    """Signed-in user behind a request.

    Attributes:
        id: Database id of the user.
        uuid: Public id of the user.
        username: Name the user signs in with.
        session_id: Database id of the device session of a bearer token, or None for a web session.
        session_uuid: Public id of that device session.
    """

    id: int
    uuid: UUID
    username: str
    session_id: int | None = None
    session_uuid: UUID | None = None


@dataclass(frozen=True)
class TvDeviceContext:
    """Paired TV device behind a request.

    Attributes:
        id: Database id of the device.
        uuid: Public id of the device.
        name: Name the device was paired under.
        site_id: Site the device was paired to, if any.
        organisation_id: Organisation of that site.
    """

    id: int
    uuid: UUID
    name: str
    site_id: int | None = None
    organisation_id: int | None = None
