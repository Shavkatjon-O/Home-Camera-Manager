"""Schemas of push targets."""

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field

from app.modules.alerting.enums import PushProvider

__all__ = ["PushProviders", "PushTargetCreate", "PushTargetList", "PushTargetRead", "PushTestResult"]


class PushProviders(BaseModel):
    """Push services this backend can deliver through.

    Attributes:
        fcm: Whether FCM is set up.
        ntfy: Whether an ntfy server is set up.
        ntfy_url: Base address of that ntfy server, under which the app picks a topic.
    """

    fcm: bool
    ntfy: bool
    ntfy_url: str | None


class PushTargetCreate(BaseModel):
    """Request to receive pushes on the device of the current session.

    Attributes:
        provider: fcm or ntfy.
        token: FCM registration token, or the full ntfy topic address under the ntfy server.
    """

    provider: PushProvider
    token: str = Field(min_length=8, max_length=4096)


class PushTargetRead(BaseModel):
    """A push target of the current session.

    Attributes:
        uuid: Public id.
        provider: fcm or ntfy.
        token: The registration token or topic address.
        enabled: Whether pushes are sent to it.
        last_success_at: When a push last arrived at the provider.
        last_error: Why the last push failed, if it did.
        created_at: When it was registered.
    """

    uuid: UUID
    provider: PushProvider
    token: str
    enabled: bool
    last_success_at: datetime | None
    last_error: str | None
    created_at: datetime


class PushTargetList(BaseModel):
    """Push targets of the current session.

    Attributes:
        items: The targets.
    """

    items: list[PushTargetRead]


class PushTestResult(BaseModel):
    """Outcome of a test push to the current session's targets.

    Attributes:
        sent: Targets the provider accepted.
        failed: Targets the provider refused or that could not be reached.
    """

    sent: int
    failed: int
