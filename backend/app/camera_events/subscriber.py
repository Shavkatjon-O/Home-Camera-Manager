import asyncio
import logging
import time
from collections.abc import Awaitable, Callable
from dataclasses import dataclass, field, replace
from datetime import UTC, datetime
from urllib.parse import urlsplit
from uuid import UUID

from app.camera_events.notifications import Notification, Subscription, parse_notifications, parse_subscription
from app.camera_events.notifications import parse_topics as parse_topic_set
from app.camera_events.topics import supported
from app.modules.events.enums import EventKind, SourceMode, SourceState
from app.onvif.client import OnvifClient
from app.onvif.endpoints import OnvifEndpoint
from app.onvif.soap import OnvifError, OnvifFault, OnvifRefused

logger = logging.getLogger(__name__)

EVENTS_WSDL = "http://www.onvif.org/ver10/events/wsdl"
CREATE_ACTION = f"{EVENTS_WSDL}/EventPortType/CreatePullPointSubscriptionRequest"
PROPERTIES_ACTION = f"{EVENTS_WSDL}/EventPortType/GetEventPropertiesRequest"
PULL_ACTION = f"{EVENTS_WSDL}/PullPointSubscription/PullMessagesRequest"
RENEW_ACTION = "http://docs.oasis-open.org/wsn/bw-2/SubscriptionManager/RenewRequest"
UNSUBSCRIBE_ACTION = "http://docs.oasis-open.org/wsn/bw-2/SubscriptionManager/UnsubscribeRequest"

SUBSCRIPTION_SECONDS = 120
PULL_WAIT_SECONDS = 20
PULL_LIMIT = 50
POLL_WAIT_SECONDS = 1

REQUEST_TIMEOUT_SECONDS = 8.0
PULL_TIMEOUT_SECONDS = PULL_WAIT_SECONDS + 10.0
UNSUBSCRIBE_TIMEOUT_SECONDS = 3.0

MIN_PULL_SECONDS = 1.0
MIN_RENEW_SECONDS = 10.0
DEFAULT_RENEW_SECONDS = 30.0
POLL_INTERVAL_SECONDS = 5.0

BACKOFF_FIRST_SECONDS = 2.0
BACKOFF_MAX_SECONDS = 60.0
UNSUPPORTED_RETRY_SECONDS = 600.0

CREATE_BODY = (
    "<tev:CreatePullPointSubscription>"
    f"<tev:InitialTerminationTime>PT{SUBSCRIPTION_SECONDS}S</tev:InitialTerminationTime>"
    "</tev:CreatePullPointSubscription>"
)
RENEW_BODY = f"<wsnt:Renew><wsnt:TerminationTime>PT{SUBSCRIPTION_SECONDS}S</wsnt:TerminationTime></wsnt:Renew>"
UNSUBSCRIBE_BODY = "<wsnt:Unsubscribe/>"


def pull_body(wait_seconds: int) -> str:
    return (
        f"<tev:PullMessages><tev:Timeout>PT{wait_seconds}S</tev:Timeout>"
        f"<tev:MessageLimit>{PULL_LIMIT}</tev:MessageLimit></tev:PullMessages>"
    )


class Unsupported(Exception):
    pass


@dataclass
class SourceStatus:
    camera_uuid: UUID
    camera_name: str
    position: int = 0
    state: SourceState = SourceState.CONNECTING
    mode: SourceMode = SourceMode.NONE
    endpoint: str | None = None
    topics: list[str] = field(default_factory=list)
    kinds: list[EventKind] = field(default_factory=list)
    conditions: dict[str, bool] = field(default_factory=dict)
    connected_at: datetime | None = None
    last_message_at: datetime | None = None
    error: str | None = None


Messages = Callable[[UUID, list[Notification], datetime | None, bool], Awaitable[None]]
StatusChanged = Callable[[SourceStatus], None]
Alive = Callable[[], Awaitable[bool]]


def renew_seconds(subscription_current: datetime | None, termination: datetime | None) -> float:
    if subscription_current is None or termination is None:
        return DEFAULT_RENEW_SECONDS
    remaining = (termination - subscription_current).total_seconds()
    if remaining <= 0:
        return MIN_RENEW_SECONDS
    return max(MIN_RENEW_SECONDS, remaining / 2)


class CameraSubscriber:
    def __init__(
        self,
        status: SourceStatus,
        endpoint: OnvifEndpoint,
        on_messages: Messages,
        on_status: StatusChanged,
        alive: Alive | None = None,
    ):
        self.status = status
        self.endpoint = endpoint
        self.on_messages = on_messages
        self.on_status = on_status
        self.alive = alive
        self.connected = False

        self.task: asyncio.Task | None = None
        self.client: OnvifClient | None = None
        self.subscription: str | None = None

    @property
    def camera_uuid(self) -> UUID:
        return self.status.camera_uuid

    def start(self) -> None:
        if self.task is None or self.task.done():
            self.task = asyncio.create_task(self.run(), name=f"camera-events-{self.camera_uuid.hex[:8]}")

    async def stop(self) -> None:
        if self.task is not None:
            self.task.cancel()
            await asyncio.gather(self.task, return_exceptions=True)
            self.task = None
        await self.unsubscribe()

    def update(self, **changes) -> None:
        updated = replace(self.status, **changes)
        if updated == self.status:
            return
        self.status = updated
        self.on_status(updated)

    async def run(self) -> None:
        backoff = BACKOFF_FIRST_SECONDS
        self.update(endpoint=self.endpoint.label)
        while True:
            try:
                await self.session()
                backoff = BACKOFF_FIRST_SECONDS
            except asyncio.CancelledError:
                raise
            except (OnvifRefused, Unsupported) as exc:
                await self.unsubscribe()
                self.update(state=SourceState.UNSUPPORTED, mode=SourceMode.NONE, error=str(exc), connected_at=None)
                await asyncio.sleep(UNSUPPORTED_RETRY_SECONDS)
            except OnvifError as exc:
                await self.unsubscribe()
                if not self.connected and self.alive is not None and await self.alive():
                    self.update(
                        state=SourceState.UNSUPPORTED,
                        mode=SourceMode.NONE,
                        error=f"The camera is online but has no ONVIF service at {self.endpoint.label}",
                        connected_at=None,
                    )
                    await asyncio.sleep(UNSUPPORTED_RETRY_SECONDS)
                    continue
                self.update(state=SourceState.RECONNECTING, error=str(exc), connected_at=None)
                await asyncio.sleep(backoff)
                backoff = min(backoff * 2, BACKOFF_MAX_SECONDS)
            except Exception as exc:
                logger.exception("The event subscriber of camera %s failed", self.camera_uuid)
                await self.unsubscribe()
                self.update(state=SourceState.RECONNECTING, error=type(exc).__name__, connected_at=None)
                await asyncio.sleep(backoff)
                backoff = min(backoff * 2, BACKOFF_MAX_SECONDS)

    async def session(self) -> None:
        client = self.endpoint.client(timeout=REQUEST_TIMEOUT_SECONDS)
        self.client = client
        services = await client.services()
        self.connected = True
        address = services.get("events")
        if not address:
            raise Unsupported("The camera offers no ONVIF events service")
        await self.load_topics(client, address)
        try:
            subscription = await self.create(client, address)
        except OnvifFault as exc:
            raise Unsupported(f"The camera refused a PullPoint subscription: {exc}")
        if await self.pull(client, subscription):
            return
        await self.unsubscribe()
        await self.poll(client, address)

    async def load_topics(self, client: OnvifClient, address: str) -> None:
        try:
            body = await client.call(address, "<tev:GetEventProperties/>", action=PROPERTIES_ACTION)
        except OnvifFault:
            return
        topics, kinds = supported(parse_topic_set(body))
        self.update(topics=topics, kinds=kinds)

    async def create(self, client: OnvifClient, address: str) -> Subscription:
        body = await client.call(address, CREATE_BODY, action=CREATE_ACTION)
        subscription = parse_subscription(body)
        if subscription is None:
            raise OnvifError("The camera answered the subscription without an address")
        self.subscription = rebase(client, subscription.address)
        return subscription

    async def pull(self, client: OnvifClient, subscription: Subscription) -> bool:
        address = self.subscription
        renew_at = time.monotonic() + renew_seconds(subscription.current_time, subscription.termination_time)
        pulled = False
        while True:
            if time.monotonic() >= renew_at:
                try:
                    body = await client.call(address, RENEW_BODY, action=RENEW_ACTION)
                except OnvifFault:
                    return True
                result = parse_notifications(body)
                renew_at = time.monotonic() + renew_seconds(result.current_time, result.termination_time)
            started = time.monotonic()
            try:
                body = await client.call(
                    address, pull_body(PULL_WAIT_SECONDS), action=PULL_ACTION, timeout=PULL_TIMEOUT_SECONDS
                )
            except OnvifFault as exc:
                if not pulled:
                    logger.info("Camera %s refused PullMessages: %s", self.camera_uuid, exc)
                    return False
                return True
            if not pulled:
                pulled = True
                self.update(
                    state=SourceState.LIVE,
                    mode=SourceMode.PULLPOINT,
                    error=None,
                    connected_at=datetime.now(UTC),
                )
            result = parse_notifications(body)
            if result.messages:
                self.update(last_message_at=datetime.now(UTC))
                await self.on_messages(self.camera_uuid, result.messages, result.current_time, False)
            elif time.monotonic() - started < MIN_PULL_SECONDS:
                await asyncio.sleep(MIN_PULL_SECONDS)

    async def poll(self, client: OnvifClient, address: str) -> None:
        while True:
            try:
                subscription = await self.create(client, address)
            except OnvifFault as exc:
                raise Unsupported(f"The camera refused a PullPoint subscription: {exc}")
            try:
                body = await client.call(
                    self.subscription, pull_body(POLL_WAIT_SECONDS), action=PULL_ACTION, timeout=PULL_TIMEOUT_SECONDS
                )
            except OnvifFault as exc:
                raise Unsupported(f"The camera refused to deliver events: {exc}")
            finally:
                await self.unsubscribe()
            if self.status.state != SourceState.LIVE or self.status.mode != SourceMode.POLLING:
                self.update(
                    state=SourceState.LIVE,
                    mode=SourceMode.POLLING,
                    error=None,
                    connected_at=datetime.now(UTC),
                )
            result = parse_notifications(body)
            if result.messages:
                self.update(last_message_at=datetime.now(UTC))
                camera_now = result.current_time or subscription.current_time
                await self.on_messages(self.camera_uuid, result.messages, camera_now, True)
            await asyncio.sleep(POLL_INTERVAL_SECONDS)

    async def unsubscribe(self) -> None:
        address = self.subscription
        client = self.client
        self.subscription = None
        if not address or client is None:
            return
        try:
            await asyncio.wait_for(
                client.call(address, UNSUBSCRIBE_BODY, action=UNSUBSCRIBE_ACTION, timeout=UNSUBSCRIBE_TIMEOUT_SECONDS),
                UNSUBSCRIBE_TIMEOUT_SECONDS + 1,
            )
        except (OnvifError, TimeoutError):
            pass


def rebase(client: OnvifClient, address: str) -> str:
    parts = urlsplit(address)
    path = parts.path or "/"
    if parts.query:
        path = f"{path}?{parts.query}"
    return f"{client.base_url}{path}"
