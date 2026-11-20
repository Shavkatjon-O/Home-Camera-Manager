"""Parsing of ONVIF event notifications, subscriptions and topic descriptions."""

from dataclasses import dataclass, field
from datetime import UTC, datetime
from xml.etree import ElementTree
from xml.etree.ElementTree import Element

from adapters.onvif.soap import child, descendant, descendants, local_name, text

ELEMENT_TEXT_LIMIT = 2000


@dataclass(frozen=True)
class Notification:
    """One ONVIF notification message.

    Attributes:
        topic: Topic path without its namespace prefix.
        operation: Property operation such as Initialized, Changed or Deleted, if given.
        utc_time: Time the camera stamped on the message, if given.
        source: Simple items of the message source.
        key: Simple items of the message key.
        data: Simple items of the message data.
        elements: Raw XML of the element items, shortened to a size limit.
    """

    topic: str
    operation: str | None = None
    utc_time: datetime | None = None
    source: dict[str, str] = field(default_factory=dict)
    key: dict[str, str] = field(default_factory=dict)
    data: dict[str, str] = field(default_factory=dict)
    elements: dict[str, str] = field(default_factory=dict)

    def details(self) -> dict:
        """Build a JSON-friendly summary of the notification.

        Returns:
            The topic plus the operation, camera time and non-empty item groups that are present.
        """
        result: dict = {"topic": self.topic}
        if self.operation:
            result["operation"] = self.operation
        if self.utc_time:
            result["camera_time"] = self.utc_time.isoformat()
        for name in ("source", "key", "data", "elements"):
            value = getattr(self, name)
            if value:
                result[name] = dict(value)
        return result


@dataclass(frozen=True)
class Subscription:
    """PullPoint subscription created on a camera.

    Attributes:
        address: Address to pull messages from.
        current_time: Camera time when the subscription was created, if given.
        termination_time: Time the subscription expires, if given.
    """

    address: str
    current_time: datetime | None
    termination_time: datetime | None


@dataclass(frozen=True)
class PullResult:
    """Answer to a pull or renew request.

    Attributes:
        current_time: Camera time when it answered, if given.
        termination_time: Time the subscription expires, if given.
        messages: Notifications the camera delivered.
    """

    current_time: datetime | None
    termination_time: datetime | None
    messages: list[Notification]


@dataclass(frozen=True)
class TopicInfo:
    """Event topic a camera advertises.

    Attributes:
        path: Topic path with segments joined by slashes.
        is_property: Whether the topic reports a state that holds until it changes.
        data_items: Names of the data items its messages carry.
    """

    path: str
    is_property: bool
    data_items: tuple[str, ...]


def parse_time(value: str | None) -> datetime | None:
    """Parse an ISO 8601 time into UTC.

    Args:
        value: Time text, with or without a zone, or None.

    Returns:
        The time in UTC, assuming UTC when the text has no zone, or None when it is empty or invalid.
    """
    if not value:
        return None
    value = value.strip()
    if value.endswith("Z"):
        value = f"{value[:-1]}+00:00"
    try:
        moment = datetime.fromisoformat(value)
    except ValueError:
        return None
    if moment.tzinfo is None:
        moment = moment.replace(tzinfo=UTC)
    return moment.astimezone(UTC)


def clean_topic(value: str | None) -> str:
    """Remove the namespace prefix from a topic.

    Args:
        value: Topic text as sent by the camera, or None.

    Returns:
        The topic path, empty when the value is missing.
    """
    if not value:
        return ""
    value = value.strip()
    head, _, rest = value.partition(":")
    if rest and "/" not in head:
        return rest
    return value


def items(section: Element | None) -> tuple[dict[str, str], dict[str, str]]:
    """Collect the named items of a message section.

    Args:
        section: Source, key or data element of a message, or None.

    Returns:
        The simple items by name, and the element items by name as raw XML shortened to a size limit.
    """
    simple: dict[str, str] = {}
    elements: dict[str, str] = {}
    if section is None:
        return simple, elements
    for item in section.iter():
        name = item.get("Name")
        if not name:
            continue
        kind = local_name(item.tag)
        if kind == "SimpleItem":
            simple[name] = item.get("Value", "")
        elif kind == "ElementItem":
            raw = "".join(ElementTree.tostring(part, encoding="unicode") for part in item)
            elements[name] = raw[:ELEMENT_TEXT_LIMIT]
    return simple, elements


def parse_message(message: Element) -> Notification | None:
    """Parse one notification message element.

    Args:
        message: NotificationMessage element.

    Returns:
        The notification, or None when it has no topic.
    """
    topic = clean_topic(text(descendant(message, "Topic")))
    inner = None
    for element in message.iter():
        if local_name(element.tag) == "Message" and (element.get("UtcTime") or child(element, "Data") is not None):
            inner = element
            break
    if not topic:
        return None
    if inner is None:
        return Notification(topic=topic)
    source, source_elements = items(child(inner, "Source"))
    key, key_elements = items(child(inner, "Key"))
    data, data_elements = items(child(inner, "Data"))
    return Notification(
        topic=topic,
        operation=inner.get("PropertyOperation"),
        utc_time=parse_time(inner.get("UtcTime")),
        source=source,
        key=key,
        data=data,
        elements=source_elements | key_elements | data_elements,
    )


def parse_notifications(body: Element) -> PullResult:
    """Parse the body of a pull or renew answer.

    Args:
        body: Body element of the SOAP response.

    Returns:
        The camera times and the notifications found.
    """
    messages = []
    for element in descendants(body, "NotificationMessage"):
        notification = parse_message(element)
        if notification is not None:
            messages.append(notification)
    return PullResult(
        current_time=parse_time(text(descendant(body, "CurrentTime"))),
        termination_time=parse_time(text(descendant(body, "TerminationTime"))),
        messages=messages,
    )


def parse_subscription(body: Element) -> Subscription | None:
    """Parse the body of a subscription creation answer.

    Args:
        body: Body element of the SOAP response.

    Returns:
        The subscription, or None when the answer has no address.
    """
    reference = descendant(body, "SubscriptionReference")
    address = text(descendant(reference, "Address"))
    if not address:
        return None
    return Subscription(
        address=address,
        current_time=parse_time(text(descendant(body, "CurrentTime"))),
        termination_time=parse_time(text(descendant(body, "TerminationTime"))),
    )


def walk_topics(element: Element, path: list[str], found: list[TopicInfo]) -> None:
    """Collect the topics below a topic set element.

    Args:
        element: Element whose children are topic names or message descriptions.
        path: Topic segments leading to the element.
        found: List the discovered topics are appended to.
    """
    for item in element:
        name = local_name(item.tag)
        if name == "MessageDescription":
            data = child(item, "Data")
            names = tuple(
                entry.get("Name", "")
                for entry in (data.iter() if data is not None else [])
                if local_name(entry.tag) in ("SimpleItemDescription", "ElementItemDescription") and entry.get("Name")
            )
            found.append(TopicInfo(path="/".join(path), is_property=item.get("IsProperty") == "true", data_items=names))
            continue
        walk_topics(item, [*path, name], found)


def parse_topics(body: Element) -> list[TopicInfo]:
    """Parse the body of an event properties answer.

    Args:
        body: Body element of the SOAP response.

    Returns:
        The topics the camera advertises.
    """
    topic_set = descendant(body, "TopicSet")
    found: list[TopicInfo] = []
    if topic_set is not None:
        walk_topics(topic_set, [], found)
    return found
