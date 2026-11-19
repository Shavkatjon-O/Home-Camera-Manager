from dataclasses import dataclass
from uuid import UUID


@dataclass(frozen=True)
class UserContext:
    id: int
    uuid: UUID
    username: str


@dataclass(frozen=True)
class TvDeviceContext:
    id: int
    uuid: UUID
    name: str
