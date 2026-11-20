"""Alert pushes: every new alert reaches the device sessions of the members who may see its site."""

import asyncio
import logging
from collections import OrderedDict
from uuid import UUID

from sqlalchemy import and_, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.camera_events.broker import EventBroker
from app.core.database import async_session_maker
from app.models import AuthSession, Camera, Membership, MembershipSite, PushTarget, Site
from app.modules.alerting.services.providers import providers
from app.modules.alerting.services.targets import deliver

__all__ = ["PushDispatcher", "alert_payload", "recipients"]

logger = logging.getLogger(__name__)

REMEMBERED_EVENTS = 4096


def alert_payload(event: dict, site_uuid: UUID) -> dict[str, str]:
    """Build the data of an alert push, which carries ids only.

    Args:
        event: The event message.
        site_uuid: Site of its camera.

    Returns:
        Type, event, camera and site ids as text.
    """
    return {
        "type": "alert",
        "event": str(event["uuid"]),
        "camera": str(event["camera_uuid"]),
        "site": str(site_uuid),
    }


async def recipients(session: AsyncSession, site_id: int, organisation_id: int) -> list[PushTarget]:
    """Load the enabled push targets of live sessions of the members who may see a site.

    Args:
        session: Database session without a scope.
        site_id: Database id of the site.
        organisation_id: Database id of its organisation.

    Returns:
        The targets.
    """
    covered = select(MembershipSite.id).where(
        MembershipSite.membership_id == Membership.id, MembershipSite.site_id == site_id
    )
    return list(
        await session.scalars(
            select(PushTarget)
            .join(AuthSession, AuthSession.id == PushTarget.session_id)
            .join(
                Membership,
                and_(Membership.user_id == PushTarget.user_id, Membership.organisation_id == organisation_id),
            )
            .where(
                PushTarget.enabled,
                AuthSession.revoked_at.is_(None),
                or_(Membership.all_sites, covered.exists()),
            )
        )
    )


class PushDispatcher:
    """Listens to the event broker and pushes each new alert once.

    Attributes:
        broker: Broker the camera and analytics events are published on.
        task: Task running the listener.
        notified: Recently pushed event ids, oldest first.
    """

    def __init__(self, broker: EventBroker):
        """Create the dispatcher, not yet running.

        Args:
            broker: The event broker.
        """
        self.broker = broker
        self.task: asyncio.Task | None = None
        self.notified: OrderedDict[str, None] = OrderedDict()

    async def start(self) -> None:
        """Start listening unless already running."""
        if self.task is None or self.task.done():
            self.task = asyncio.create_task(self.run(), name="push-dispatcher")

    async def stop(self) -> None:
        """Stop listening."""
        if self.task is not None:
            self.task.cancel()
            await asyncio.gather(self.task, return_exceptions=True)
        self.task = None

    def first_alert(self, message: dict) -> dict | None:
        """Return the event of a message that is an alert not pushed yet.

        Args:
            message: Broker message with type and data.

        Returns:
            The event data, or None.
        """
        if message.get("type") != "event":
            return None
        data = message.get("data") or {}
        if not data.get("alert") or not data.get("uuid"):
            return None
        key = str(data["uuid"])
        if key in self.notified:
            return None
        self.notified[key] = None
        while len(self.notified) > REMEMBERED_EVENTS:
            self.notified.popitem(last=False)
        return data

    async def run(self) -> None:
        """Push alerts until cancelled, logging and surviving failures."""
        with self.broker.subscribe() as queue:
            while True:
                message = await queue.get()
                event = self.first_alert(message)
                if event is None:
                    continue
                try:
                    await self.notify(event)
                except Exception:
                    logger.exception("Pushing the alert of event %s failed", event.get("uuid"))

    async def notify(self, event: dict) -> int:
        """Push one alert to every member who may see its site.

        Args:
            event: The event data.

        Returns:
            The number of targets the providers accepted.
        """
        available = providers()
        if not any(provider.enabled for provider in available.values()):
            return 0
        async with async_session_maker() as session:
            row = (
                await session.execute(
                    select(Camera.site_id, Camera.organisation_id, Site.uuid)
                    .join(Site, Site.id == Camera.site_id)
                    .where(Camera.uuid == UUID(str(event["camera_uuid"])))
                )
            ).first()
            if row is None:
                return 0
            site_id, organisation_id, site_uuid = row
            targets = await recipients(session, site_id, organisation_id)
            if not targets:
                return 0
            sent = await deliver(targets, alert_payload(event, site_uuid), available)
            await session.commit()
            return sent
