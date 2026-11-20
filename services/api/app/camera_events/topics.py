"""Classification of ONVIF event topics and message data into event kinds."""

import re
from dataclasses import dataclass

from app.modules.events.enums import EventKind
from camera_adapters.onvif.notifications import Notification, TopicInfo

TRUE_VALUES = {"true", "1", "on", "yes"}
FALSE_VALUES = {"false", "0", "off", "no"}

STATE_ITEMS = ("IsMotion", "State", "IsTamper", "IsPeople", "IsHuman", "IsVehicle", "Failed", "IsInside", "Active")
CLASS_ITEMS = ("ObjectType", "ClassTypes", "Class", "Type", "Object", "Classification", "TargetType", "Label")

PERSON_WORDS = ("human", "people", "person", "pedestrian", "facedetect", "humanoid")
VEHICLE_WORDS = ("vehicle", "licenseplate")

PERSON_CLASSES = re.compile(r"\b(human|humanoid|person|people|pedestrian|face)\b")
VEHICLE_CLASSES = re.compile(r"\b(vehicle|car|truck|bus|bicycle|motorcycle|bike|licenseplate)\b")
TAMPER_WORDS = (
    "tamper",
    "imagetooblurry",
    "imagetoodark",
    "imagetoobright",
    "globalscenechange",
    "signalloss",
    "defocus",
    "scenechange",
)
STORAGE_WORDS = ("storagefailure", "harddiskerror", "harddiskfull", "storage/full", "recordingfailure")
REBOOT_TOPIC = "monitoring/operatingtime/lastreboot"

CONDITION_WORDS = ("imagetoodark", "imagetoobright", "imagetooblurry", "signalloss")


@dataclass(frozen=True)
class Signal:
    """Meaning of one notification for event tracking.

    Attributes:
        kind: Kind of event the notification belongs to.
        active: Whether the state is on, or None when the notification carries no on or off state.
        reboot: Whether the notification reports a camera reboot.
    """

    kind: EventKind
    active: bool | None
    reboot: bool = False


def flat(topic: str) -> str:
    """Normalise a topic for matching.

    Args:
        topic: ONVIF topic path.

    Returns:
        The topic in lower case without underscores.
    """
    return topic.replace("_", "").lower()


def has_word(value: str, words: tuple[str, ...]) -> bool:
    """Check whether a value contains any of the words.

    Args:
        value: Text to search.
        words: Substrings to look for.

    Returns:
        True when at least one word occurs in the value.
    """
    return any(word in value for word in words)


def boolean(value: str | None) -> bool | None:
    """Read a true or false word as a boolean.

    Args:
        value: Text such as on, off, true or 0, or None.

    Returns:
        The boolean, or None when the value is missing or is not a known word.
    """
    if value is None:
        return None
    value = value.strip().lower()
    if value in TRUE_VALUES:
        return True
    if value in FALSE_VALUES:
        return False
    return None


def state_of(data: dict[str, str]) -> bool | None:
    """Read the on or off state from the data items of a notification.

    Known state items are tried first in their listed order, then any other item with a boolean value.

    Args:
        data: Data items of the notification.

    Returns:
        The state, or None when no item holds one.
    """
    for name in STATE_ITEMS:
        if name in data:
            value = boolean(data[name])
            if value is not None:
                return value
    for value in data.values():
        state = boolean(value)
        if state is not None:
            return state
    return None


def class_of(notification: Notification) -> EventKind | None:
    """Find a person or vehicle class in a notification.

    Args:
        notification: Notification to inspect.

    Returns:
        The kind named by a class item or class element, or None when none names a person or a vehicle.
    """
    for section in (notification.data, notification.source, notification.key):
        for name in CLASS_ITEMS:
            value = section.get(name)
            if not value:
                continue
            found = class_kind(value)
            if found is not None:
                return found
    for raw in notification.elements.values():
        lowered = raw.lower()
        if "class" in lowered or "type" in lowered:
            found = class_kind(lowered)
            if found is not None:
                return found
    return None


def class_kind(value: str) -> EventKind | None:
    """Map a class name to an event kind.

    Args:
        value: Class name reported by the camera.

    Returns:
        The person or vehicle kind, or None when the value names neither.
    """
    lowered = value.lower()
    if PERSON_CLASSES.search(lowered):
        return EventKind.PERSON
    if VEHICLE_CLASSES.search(lowered):
        return EventKind.VEHICLE
    return None


def topic_kind(topic: str) -> EventKind | None:
    """Map an ONVIF topic to an event kind.

    Args:
        topic: ONVIF topic path.

    Returns:
        The event kind, or None when the topic is not one the system records.
    """
    value = flat(topic)
    if value == REBOOT_TOPIC:
        return EventKind.REBOOT
    if has_word(value, STORAGE_WORDS):
        return EventKind.STORAGE
    if has_word(value, TAMPER_WORDS):
        return EventKind.TAMPER
    if value.startswith(("monitoring/", "configuration/", "media/", "recordingconfig/", "device/")):
        return None
    if has_word(value, PERSON_WORDS):
        return EventKind.PERSON
    if has_word(value, VEHICLE_WORDS):
        return EventKind.VEHICLE
    if "motion" in value or "objectsinside" in value or "linedetector" in value or "fielddetector" in value:
        return EventKind.MOTION
    return None


def classify(notification: Notification) -> Signal | None:
    """Interpret a notification as an event signal.

    A motion topic that also names a person or vehicle class is reported as that class.

    Args:
        notification: Notification to classify.

    Returns:
        The signal, or None when the topic is not recorded.
    """
    kind = topic_kind(notification.topic)
    if kind is None:
        return None
    if kind == EventKind.REBOOT:
        return Signal(kind=kind, active=None, reboot=True)
    state = state_of(notification.data)
    if kind == EventKind.MOTION:
        detected = class_of(notification)
        if detected is not None:
            kind = detected
    return Signal(kind=kind, active=state)


def is_condition(topic: str) -> bool:
    """Check whether a topic reports a camera condition such as signal loss or a dark image.

    Args:
        topic: ONVIF topic path.

    Returns:
        True when the topic is a condition topic.
    """
    return has_word(flat(topic), CONDITION_WORDS)


def condition_name(topic: str) -> str:
    """Return the name under which a condition topic is shown.

    Args:
        topic: ONVIF topic path.

    Returns:
        The topic segment that names the condition, or the last segment when none does.
    """
    parts = [part for part in topic.split("/") if part]
    for part in parts:
        if has_word(flat(part), CONDITION_WORDS):
            return part
    return parts[-1] if parts else topic


def supported(topics: list[TopicInfo]) -> tuple[list[str], list[EventKind]]:
    """List the topics the system records and the event kinds they cover.

    Args:
        topics: Topics the camera advertises.

    Returns:
        The paths of the recorded topics, and the event kinds they cover in enum order.
    """
    names = []
    kinds: list[EventKind] = []
    for topic in topics:
        kind = topic_kind(topic.path)
        if kind is None:
            continue
        names.append(topic.path)
        if kind not in kinds:
            kinds.append(kind)
    order = list(EventKind)
    return names, sorted(kinds, key=order.index)
