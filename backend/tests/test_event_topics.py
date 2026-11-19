from app.camera_events.notifications import Notification, TopicInfo
from app.camera_events.topics import classify, condition_name, is_condition, supported
from app.modules.events.enums import EventKind


def note(topic: str, data: dict | None = None, operation: str | None = "Changed", **extra) -> Notification:
    return Notification(topic=topic, operation=operation, data=data or {}, **extra)


def test_motion_topics_map_to_motion_with_state():
    signal = classify(note("RuleEngine/CellMotionDetector/Motion", {"IsMotion": "true"}))
    assert (signal.kind, signal.active) == (EventKind.MOTION, True)
    signal = classify(note("VideoSource/MotionAlarm", {"State": "false"}))
    assert (signal.kind, signal.active) == (EventKind.MOTION, False)


def test_classified_objects_become_person_or_vehicle():
    assert classify(note("RuleEngine/MyRuleDetector/PeopleDetect", {"State": "true"})).kind == EventKind.PERSON
    assert classify(note("RuleEngine/MyRuleDetector/VehicleDetect", {"State": "true"})).kind == EventKind.VEHICLE
    signal = classify(note("RuleEngine/FieldDetector/ObjectsInside", {"IsInside": "true", "ObjectType": "Human"}))
    assert (signal.kind, signal.active) == (EventKind.PERSON, True)
    element = '<tt:Object><tt:Class><tt:Type Likelihood="0.9">Vehicle</tt:Type></tt:Class></tt:Object>'
    signal = classify(note("RuleEngine/CellMotionDetector/Motion", {"IsMotion": "true"}, elements={"Object": element}))
    assert signal.kind == EventKind.VEHICLE


def test_tamper_storage_and_reboot():
    assert classify(note("VideoSource/ImageTooBlurry/ImagingService", {"State": "true"})).kind == EventKind.TAMPER
    storage = classify(note("Device/HardwareFailure/StorageFailure", {"Failed": "true"}))
    assert (storage.kind, storage.active) == (EventKind.STORAGE, True)
    full = classify(note("Device/HardwareFailure/HardDiskFull", operation=None))
    assert (full.kind, full.active) == (EventKind.STORAGE, None)
    reboot = classify(note("Monitoring/OperatingTime/LastReboot", {"Status": "2026-11-19T19:15:17Z"}))
    assert reboot.reboot and reboot.kind == EventKind.REBOOT


def test_unrelated_topics_are_ignored():
    for topic in (
        "Monitoring/ProcessorUsage",
        "Monitoring/OperatingTime/LastReset",
        "Configuration/Profile",
        "RecordingConfig/JobState",
        "Media/ProfileChanged",
        "Device/Network/InterfaceChanged",
    ):
        assert classify(note(topic, {"State": "true"})) is None


def test_conditions_are_named_by_their_topic_part():
    assert is_condition("VideoSource/ImageTooDark/ImagingService")
    assert condition_name("VideoSource/ImageTooDark/ImagingService") == "ImageTooDark"
    assert not is_condition("VideoSource/MotionAlarm")


def test_supported_topics_and_kinds_in_enum_order():
    topics = [
        TopicInfo("Monitoring/ProcessorUsage", True, ("Value",)),
        TopicInfo("Device/HardwareFailure/StorageFailure", True, ("Failed",)),
        TopicInfo("VideoSource/MotionAlarm", True, ("State",)),
        TopicInfo("RuleEngine/CellMotionDetector/Motion", True, ("IsMotion",)),
    ]
    names, kinds = supported(topics)
    assert names == [
        "Device/HardwareFailure/StorageFailure",
        "VideoSource/MotionAlarm",
        "RuleEngine/CellMotionDetector/Motion",
    ]
    assert kinds == [EventKind.MOTION, EventKind.STORAGE]
