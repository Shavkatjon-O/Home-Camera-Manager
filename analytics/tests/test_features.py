from datetime import UTC

import numpy as np

from app.config import parse_config
from app.features import FeatureHub
from app.plates.reader import READ, PlateRead
from app.plates.text import parse
from app.rules.engine import Event, Update
from app.rules.model import ArmMode, Box, Detection, EventKind

START = 1_700_000_000.0
SQUARE = [[0.1, 0.1], [0.9, 0.1], [0.9, 0.9], [0.1, 0.9]]


def config(view_extra=None, zone_extra=None):
    zone = {"id": "z", "name": "Parking", "polygon": SQUARE, **(zone_extra or {})}
    view = {"id": "v", "name": "Camera B", "lens": 0, "profile": "perimeter", "zones": [zone], **(view_extra or {})}
    return parse_config({"arm_mode": "away", "cameras": [{"id": "c", "stream": "c_main", "views": [view]}]})


class Recorder:
    def __init__(self):
        self.handled = []
        self.sent = []
        self.attached = []

    def handle(self, view, updates):
        self.handled += updates

    def send(self, path, body, droppable):
        self.sent.append((path, body, droppable))

    def attach(self, event, details):
        self.attached.append((event, details))


class Reader:
    def __init__(self):
        self.settings = None
        self.pictures = 0

    def read(self, pixels):
        self.pictures += 1
        return PlateRead(READ, parse("01A123BC"), 0.9, "01A123BC")


def hub(recorder, reader=None, backend=None, tmp_path=None):
    return FeatureHub(
        UTC,
        lambda: ArmMode.AWAY,
        recorder.handle,
        recorder.send,
        recorder.attach,
        lambda: reader,
        lambda view, job: np.zeros((40, 80, 3), np.uint8),
        state_dir=tmp_path,
        backend=backend,
    )


def bag(track, at):
    return Detection(track, "backpack", 0.9, Box(0.4, 0.5, 0.45, 0.6))


def test_apply_builds_only_what_views_ask_for():
    recorder = Recorder()
    features = hub(recorder)
    features.apply(config(), START)
    assert features.views["v"].objects is None
    assert features.views["v"].falls is None
    features.apply(config({"falls": {"enabled": True}}, {"left_seconds": 30, "background": True}), START)
    view = features.views["v"]
    assert view.objects is not None and view.background is not None and view.falls is not None
    assert view.follow is None
    features.apply(config({"follow": {"enabled": True}}), START)
    assert features.views["v"].follow is None
    features.apply(parse_config({"cameras": []}), START)
    assert features.views == {}


def test_left_object_events_go_through_handle():
    recorder = Recorder()
    features = hub(recorder)
    features.apply(config(zone_extra={"left_seconds": 30}), START)
    view = features.views["v"].config
    for second in range(0, 120, 2):
        features.on_frame(view, START + second, (), None)
    for second in range(120, 200):
        features.on_frame(view, START + second, (bag(7, second),), None)
    kinds = [update.event.kind for update in recorder.handled]
    assert "object_left" in kinds


def test_plates_are_read_for_vehicle_events_and_attached():
    recorder = Recorder()
    reader = Reader()
    features = hub(recorder, reader)
    features.apply(config({"plates": {"enabled": True, "delay": 2, "max_reads": 2}}), START)
    view = features.views["v"].config
    event = Event("e1", "v", EventKind.VEHICLE, "car", START, objects=[5])
    features.on_update(Update("open", event))
    car = Detection(5, "car", 0.9, Box(0.2, 0.2, 0.6, 0.6))
    for step in range(6):
        features.on_frame(view, START + step, (car,), None)
    features.read_plates(START + 10)
    assert reader.pictures == 2
    assert recorder.attached[-1][0] == "e1"
    assert recorder.attached[-1][1]["plates"][0]["display"] == "01 A 123 BC"
    assert recorder.attached[-1][1]["plate_status"] == "read"


def test_tick_reports_counts_and_keeps_the_mean(tmp_path):
    recorder = Recorder()
    features = hub(recorder, tmp_path=tmp_path)
    features.apply(config(), START)
    features.crossing("v", "gate", "in", "person", START)
    features.tick(START + 10)
    paths = [path for path, _, _ in recorder.sent]
    assert paths == ["/internal/analytics/counts"]
    assert recorder.sent[0][1]["buckets"][0]["count"] == 1
    assert recorder.sent[0][2] is False
    features.tick(START + 11)
    assert len(recorder.sent) == 1
    features.save_mean()
    assert features.status()["counts"]["boot"] == features.ledger.boot


def test_person_batches_feed_journeys_and_falls():
    recorder = Recorder()
    features = hub(recorder)
    features.apply(config({"falls": {"enabled": True}}), START)
    view = features.views["v"].config
    vector = np.zeros(512, np.float32)
    vector[0] = 1.0
    keypoints = np.zeros((17, 3), np.float32)
    features.on_persons(
        {0: view},
        [(0, 3, START, (0.1, 0.1, 0.2, 0.5), 200.0, vector)],
        [(0, 3, START, (0.1, 0.1, 0.2, 0.5), keypoints)],
    )
    features.on_persons({}, [(1, 3, START, (0.1, 0.1, 0.2, 0.5), 200.0, vector)], [])
    assert features.linker.status()
