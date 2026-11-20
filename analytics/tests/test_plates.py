import numpy as np
import pytest

from app.plates.ctc import greedy, load_characters
from app.plates.detect import BOX_NORM, STRIDE, decode
from app.plates.frames import box_filter, parse_ppm
from app.plates.reader import INFRARED, NO_PLATE, READ, PlateRead, PlateReader, PlateSettings, PlateVotes
from app.plates.text import parse
from app.plates.watch import PlateJob, PlateWatch
from app.rules.model import Box

CHARACTERS = ["", *"0123456789", *"ABCDEFGHIJKLMNOPQRSTUVWXYZ", " "]


def scores_for(text, columns=40):
    probabilities = np.full((columns, len(CHARACTERS)), 0.001, np.float32)
    probabilities[:, 0] = 0.9
    for index, character in enumerate(text):
        column = index * 2 + 1
        probabilities[column, :] = 0.001
        probabilities[column, CHARACTERS.index(character)] = 0.95
    return probabilities


def test_load_characters(tmp_path):
    path = tmp_path / "dict.txt"
    path.write_text("0\n1\nA\n")
    assert load_characters(path) == ["", "0", "1", "A", " "]


def test_greedy_merges_repeats_and_drops_blanks():
    probabilities = np.zeros((6, len(CHARACTERS)), np.float32)
    for column, index in enumerate([1, 1, 0, 1, 11, 0]):
        probabilities[column, index] = 0.8 + column * 0.01
    decoded = greedy(probabilities, CHARACTERS)
    assert decoded.text == "00A"
    assert len(decoded.scores) == 3
    assert decoded.confidence == pytest.approx(0.81)


def test_parse_private_and_organisation_plates():
    plate = parse("01 A 123 BC")
    assert plate.text == "01A123BC"
    assert plate.display == "01 A 123 BC"
    assert plate.format == "private"
    assert plate.swaps == 0
    organisation = parse("10 123 ABC")
    assert organisation.format == "organisation"
    assert organisation.display == "10 123 ABC"


def test_parse_swaps_look_alikes_only_where_the_format_needs_them():
    assert parse("O1A12E8C").format is None
    fixed = parse("0lA1Z3BC")
    assert fixed.text == "01A123BC"
    assert fixed.swaps == 2
    assert fixed.score == pytest.approx(0.8)


def test_parse_drops_the_country_mark_and_keeps_foreign_plates():
    assert parse("01A123BCUZ").text == "01A123BC"
    foreign = parse("AB1234")
    assert foreign.format is None
    assert foreign.score == 0.5
    assert parse("A1") is None
    assert parse("") is None


def test_decode_detectnet_grid():
    coverage = np.zeros((1, 30, 40), np.float32)
    boxes = np.zeros((4, 30, 40), np.float32)
    row, column = 10, 20
    coverage[0, row, column] = 0.9
    coverage[0, row, column + 1] = 0.6
    centre_x = (column * STRIDE + 0.5) / BOX_NORM
    centre_y = (row * STRIDE + 0.5) / BOX_NORM
    boxes[:, row, column] = [
        centre_x - 300 / BOX_NORM,
        centre_y - 150 / BOX_NORM,
        380 / BOX_NORM - centre_x,
        175 / BOX_NORM - centre_y,
    ]
    neighbour = column + 1
    centre_n = (neighbour * STRIDE + 0.5) / BOX_NORM
    boxes[:, row, neighbour] = [
        centre_n - 302 / BOX_NORM,
        centre_y - 151 / BOX_NORM,
        381 / BOX_NORM - centre_n,
        176 / BOX_NORM - centre_y,
    ]
    found = decode(coverage, boxes, 0.3)
    assert len(found) == 1
    assert found[0].left == pytest.approx(300, abs=0.01)
    assert found[0].bottom == pytest.approx(175, abs=0.01)
    assert found[0].score == pytest.approx(0.9)


class Runner:
    def __init__(self, inputs, outputs, make):
        self.inputs = inputs
        self.outputs = outputs
        self.max_batch = 8
        self.make = make
        self.calls = 0

    def run(self, feeds):
        self.calls += 1
        return self.make(next(iter(feeds.values())))


def detector_with(box):
    def make(batch):
        coverage = np.zeros((len(batch), 1, 30, 40), np.float32)
        boxes = np.zeros((len(batch), 4, 30, 40), np.float32)
        if box is not None:
            left, top, right, bottom = box
            row, column = int((top + bottom) / 2 // STRIDE), int((left + right) / 2 // STRIDE)
            centre_x = (column * STRIDE + 0.5) / BOX_NORM
            centre_y = (row * STRIDE + 0.5) / BOX_NORM
            coverage[:, 0, row, column] = 0.8
            boxes[:, :, row, column] = [
                centre_x - left / BOX_NORM,
                centre_y - top / BOX_NORM,
                right / BOX_NORM - centre_x,
                bottom / BOX_NORM - centre_y,
            ]
        return {"output_cov/Sigmoid:0": coverage, "output_bbox/BiasAdd:0": boxes}

    return Runner(["input_1:0"], ["output_cov/Sigmoid:0", "output_bbox/BiasAdd:0"], make)


def recogniser_with(text):
    return Runner(["x"], ["softmax"], lambda batch: {"softmax": np.stack([scores_for(text)] * len(batch))})


def colour_picture(width=640, height=480):
    picture = np.zeros((height, width, 3), np.uint8)
    picture[..., 0] = 180
    picture[..., 2] = 60
    return picture


def test_reader_reads_a_plate():
    reader = PlateReader(detector_with((250, 300, 390, 330)), recogniser_with("01A123BC"), CHARACTERS, PlateSettings())
    read = reader.read(colour_picture())
    assert read.status == READ
    assert read.plate.display == "01 A 123 BC"
    assert read.confidence == pytest.approx(0.95)
    left, top, right, bottom = read.box
    assert left < 250 < 390 < right
    assert top < 300 < 330 < bottom


def test_reader_refuses_infrared_and_reports_missing_plates():
    detector = detector_with((250, 300, 390, 330))
    reader = PlateReader(detector, recogniser_with("01A123BC"), CHARACTERS, PlateSettings())
    grey = np.full((480, 640, 3), 120, np.uint8)
    assert reader.read(grey).status == INFRARED
    assert detector.calls == 0
    empty = PlateReader(detector_with(None), recogniser_with("01A123BC"), CHARACTERS, PlateSettings())
    assert empty.read(colour_picture()).status == NO_PLATE


def test_reader_skips_tiny_plates_and_low_confidence():
    tiny = PlateReader(detector_with((250, 300, 390, 306)), recogniser_with("01A123BC"), CHARACTERS, PlateSettings())
    assert tiny.read(colour_picture()).status == "too_small"
    strict = PlateReader(
        detector_with((250, 300, 390, 330)), recogniser_with("01A123BC"), CHARACTERS, PlateSettings(min_confidence=0.99)
    )
    assert strict.read(colour_picture()).status == "unreadable"


def test_votes_rank_by_weight_and_report_status():
    votes = PlateVotes()
    assert votes.status == "pending"
    votes.add(PlateRead(INFRARED))
    assert votes.status == INFRARED
    for text, confidence in (("01A123BC", 0.9), ("01A128BC", 0.6), ("01A123BC", 0.8)):
        votes.add(PlateRead(READ, parse(text), confidence, text))
    candidates = votes.candidates()
    assert votes.status == READ
    assert [item["text"] for item in candidates] == ["01A123BC", "01A128BC"]
    assert candidates[0]["reads"] == 2
    assert candidates[0]["score"] == pytest.approx(0.85)


def test_watch_plans_reads_for_vehicle_events():
    watch = PlateWatch()
    watch.configure("b", {"plates": {"enabled": True, "max_reads": 2, "delay": 3}})
    watch.configure("a", {})
    event = {"id": "e1", "view": "b", "label": "car", "started_at": 100.0, "ended_at": None, "objects": [5]}
    assert watch.follow(event)
    assert not watch.follow({**event, "id": "e2", "label": "person"})
    assert not watch.follow({**event, "id": "e3", "view": "a"})
    car = Box(0.2, 0.3, 0.5, 0.6)
    watch.observe("b", 100.0, [(5, car), (6, Box(0.6, 0.3, 0.9, 0.6))])
    watch.observe("b", 100.5, [(5, car)])
    watch.observe("b", 101.2, [(5, Box(0.2, 0.3, 0.22, 0.6))])
    watch.observe("b", 101.4, [(5, car)])
    watch.observe("b", 103.0, [(5, car)])
    assert watch.due(102.0) == []
    jobs = watch.due(105.0)
    assert [(job.event, job.at) for job in jobs] == [("e1", 100.0), ("e1", 101.4)]
    details = watch.record(jobs[0], PlateRead(READ, parse("01A123BC"), 0.9, "01A123BC"))
    assert details["plate_status"] == READ
    assert details["plates"][0]["display"] == "01 A 123 BC"
    assert watch.record(PlateJob("gone", "b", 1.0, car, 2.0), PlateRead(INFRARED)) is None


def test_parse_ppm_and_box_filter():
    pixels = np.arange(2 * 3 * 3, dtype=np.uint8).reshape(2, 3, 3)
    data = b"P6\n# comment\n3 2\n255\n" + pixels.tobytes()
    assert np.array_equal(parse_ppm(data), pixels)
    assert parse_ppm(b"P5\n3 2\n255\n" + bytes(6)) is None
    assert parse_ppm(b"P6\n3 2\n255\n" + bytes(5)) is None
    assert box_filter((0.1, 0.2, 0.3, 0.4), 0.0) == "crop=iw*0.20000:ih*0.20000:iw*0.10000:ih*0.20000"
    assert box_filter((0.0, 0.0, 1.0, 1.0), 0.5) == "crop=iw*1.00000:ih*1.00000:iw*0.00000:ih*0.00000"
