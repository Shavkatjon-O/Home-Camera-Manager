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
    """

    id: int
    uuid: UUID
    username: str


@dataclass(frozen=True)
class TvDeviceContext:
    """Paired TV device behind a request.

    Attributes:
        id: Database id of the device.
        uuid: Public id of the device.
        name: Name the device was paired under.
    """

    id: int
    uuid: UUID
    name: str
