import re
from dataclasses import dataclass

from app.camera_events.notifications import Notification, TopicInfo
from app.modules.events.enums import EventKind

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

EVENT_KINDS = (EventKind.MOTION, EventKind.PERSON, EventKind.VEHICLE, EventKind.TAMPER, EventKind.STORAGE)


@dataclass(frozen=True)
class Signal:
    kind: EventKind
    active: bool | None
    reboot: bool = False


def flat(topic: str) -> str:
    return topic.replace("_", "").lower()


def has_word(value: str, words: tuple[str, ...]) -> bool:
    return any(word in value for word in words)


def boolean(value: str | None) -> bool | None:
    if value is None:
        return None
    value = value.strip().lower()
    if value in TRUE_VALUES:
        return True
    if value in FALSE_VALUES:
        return False
    return None


def state_of(data: dict[str, str]) -> bool | None:
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
    lowered = value.lower()
    if PERSON_CLASSES.search(lowered):
        return EventKind.PERSON
    if VEHICLE_CLASSES.search(lowered):
        return EventKind.VEHICLE
    return None


def topic_kind(topic: str) -> EventKind | None:
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
    return has_word(flat(topic), CONDITION_WORDS)


def condition_name(topic: str) -> str:
    parts = [part for part in topic.split("/") if part]
    for part in parts:
        if has_word(flat(part), CONDITION_WORDS):
            return part
    return parts[-1] if parts else topic


def supported(topics: list[TopicInfo]) -> tuple[list[str], list[EventKind]]:
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
