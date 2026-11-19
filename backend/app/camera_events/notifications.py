from dataclasses import dataclass, field
from datetime import UTC, datetime
from xml.etree import ElementTree
from xml.etree.ElementTree import Element

from app.onvif.soap import child, descendant, descendants, local_name, text

ELEMENT_TEXT_LIMIT = 2000


@dataclass(frozen=True)
class Notification:
    topic: str
    operation: str | None = None
    utc_time: datetime | None = None
    source: dict[str, str] = field(default_factory=dict)
    key: dict[str, str] = field(default_factory=dict)
    data: dict[str, str] = field(default_factory=dict)
    elements: dict[str, str] = field(default_factory=dict)

    def details(self) -> dict:
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
    address: str
    current_time: datetime | None
    termination_time: datetime | None


@dataclass(frozen=True)
class PullResult:
    current_time: datetime | None
    termination_time: datetime | None
    messages: list[Notification]


@dataclass(frozen=True)
class TopicInfo:
    path: str
    is_property: bool
    data_items: tuple[str, ...]


def parse_time(value: str | None) -> datetime | None:
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
    if not value:
        return ""
    value = value.strip()
    head, _, rest = value.partition(":")
    if rest and "/" not in head:
        return rest
    return value


def items(section: Element | None) -> tuple[dict[str, str], dict[str, str]]:
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
    topic_set = descendant(body, "TopicSet")
    found: list[TopicInfo] = []
    if topic_set is not None:
        walk_topics(topic_set, [], found)
    return found
