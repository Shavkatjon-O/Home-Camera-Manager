import numpy as np
import pytest
from face_helpers import template_landmarks

from app.identity import align, frames, quality, scrfd
from app.identity.engines import output_name
from app.identity.probe import FaceGate, best_face, read_layers, region_around


def detector_outputs(size=640):
    outputs = {}
    for stride in scrfd.STRIDES:
        anchors = (size // stride) ** 2 * 2
        outputs[f"score{stride}"] = np.zeros((1, anchors, 1), dtype=np.float32)
        outputs[f"box{stride}"] = np.zeros((1, anchors, 4), dtype=np.float32)
        outputs[f"kps{stride}"] = np.zeros((1, anchors, 10), dtype=np.float32)
    return outputs


def place_face(outputs, stride, cell_x, cell_y, anchor, score, distances, offsets, size=640):
    cells = size // stride
    row = (cell_y * cells + cell_x) * 2 + anchor
    outputs[f"score{stride}"][0, row, 0] = score
    outputs[f"box{stride}"][0, row] = np.array(distances, dtype=np.float32) / stride
    outputs[f"kps{stride}"][0, row] = np.array(offsets, dtype=np.float32).reshape(-1) / stride


def test_decode_recovers_box_and_landmarks():
    outputs = detector_outputs()
    offsets = [[-10, -8], [10, -8], [0, 2], [-8, 12], [8, 12]]
    place_face(outputs, 8, 20, 30, 1, 0.9, [16, 20, 16, 24], offsets)
    faces = scrfd.decode(outputs, 640, 0.5)
    assert len(faces) == 1
    face = faces[0]
    assert face.box == pytest.approx((160 - 16, 240 - 20, 160 + 16, 240 + 24))
    assert face.landmarks[0] == pytest.approx([150, 232])
    assert face.landmarks[4] == pytest.approx([168, 252])
    assert face.score == pytest.approx(0.9)


def test_decode_suppresses_overlapping_detections_and_drops_low_scores():
    outputs = detector_outputs()
    zeros = [[0, 0]] * 5
    place_face(outputs, 8, 20, 30, 0, 0.9, [16, 16, 16, 16], zeros)
    place_face(outputs, 8, 20, 30, 1, 0.8, [17, 16, 16, 16], zeros)
    place_face(outputs, 32, 2, 2, 0, 0.3, [40, 40, 40, 40], zeros)
    faces = scrfd.decode(outputs, 640, 0.5)
    assert [round(face.score, 2) for face in faces] == [0.9]


def test_mapped_and_letterbox_scale_undo_nvinfer_scaling():
    scale = scrfd.letterbox_scale(300, 600, 640)
    assert scale == pytest.approx(640 / 600)
    face = scrfd.RawFace((64.0, 128.0, 128.0, 192.0), 0.9, np.zeros((5, 2), dtype=np.float32) + 64)
    mapped = face.mapped(scale, 100.0, 50.0)
    assert mapped.box[0] == pytest.approx(100 + 64 / scale)
    assert mapped.landmarks[0, 1] == pytest.approx(50 + 64 / scale)


def test_similarity_recovers_known_transform():
    angle = np.deg2rad(12)
    rotation = np.array([[np.cos(angle), -np.sin(angle)], [np.sin(angle), np.cos(angle)]]) * 1.7
    source = np.random.default_rng(1).uniform(0, 100, (5, 2))
    target = source @ rotation.T + np.array([5.0, -3.0])
    matrix = align.similarity(source, target)
    assert matrix[:, :2] == pytest.approx(rotation, abs=1e-6)
    assert matrix[:, 2] == pytest.approx([5.0, -3.0], abs=1e-6)


def test_align_moves_landmarks_onto_the_template():
    image = np.zeros((300, 300, 3), dtype=np.uint8)
    landmarks = template_landmarks(scale=2.0, shift=(40, 30))
    for x, y in landmarks:
        image[int(round(y)) - 1 : int(round(y)) + 2, int(round(x)) - 1 : int(round(x)) + 2] = 255
    aligned = align.align(image, landmarks)
    assert aligned.shape == (112, 112, 3)
    for x, y in align.TEMPLATE:
        assert aligned[int(round(y)), int(round(x)), 0] > 100


def test_crop_is_square_and_centred():
    image = np.zeros((200, 200, 3), dtype=np.uint8)
    image[90:110, 90:110] = 200
    crop = align.crop(image, (90, 90, 110, 110), 160)
    assert crop.shape == (160, 160, 3)
    assert crop[80, 80, 0] == 200
    assert crop[5, 5, 0] == 0


def test_frontality_is_high_for_the_template_and_low_for_a_profile():
    assert quality.frontality(align.TEMPLATE) > 0.95
    turned = align.TEMPLATE.copy()
    turned[2, 0] = turned[1, 0] + 4
    assert quality.frontality(turned) < 0.3
    upside_down = align.TEMPLATE.copy()
    upside_down[:, 1] *= -1
    assert quality.frontality(upside_down) == 0.0


def test_sharpness_and_grey_and_combine():
    flat = np.full((112, 112, 3), 128, dtype=np.uint8)
    checks = (np.indices((112, 112)).sum(axis=0) % 2 * 255).astype(np.uint8)
    busy = np.repeat(checks[:, :, None], 3, axis=2)
    assert quality.sharpness(flat) == 0.0
    assert quality.sharpness(busy) > 0.9
    assert quality.is_grey(busy)
    colour = flat.copy()
    colour[:, :, 0] = 220
    assert not quality.is_grey(colour)
    assert quality.combine(1.0, 1.0, 0.0, 1.0) == 0.0
    assert quality.combine(1.0, 1.0, 1.0, 1.0) == pytest.approx(1.0)
    assert quality.size_signal(36, 36) == 0.0
    assert quality.size_signal(200, 36) == 1.0


def test_host_tensors_are_read_through_dlpack():
    array = np.arange(24, dtype=np.float32).reshape(6, 4)
    tensor = frames.describe(array)
    assert not tensor.gpu
    assert tensor.shape == (6, 4)
    assert frames.read(tensor, None) == pytest.approx(array)
    assert frames.read_rows(tensor, np.array([4, 1]), None) == pytest.approx(array[[4, 1]])
    picture = np.arange(10 * 12 * 3, dtype=np.uint8).reshape(10, 12, 3)
    region = frames.read_region(frames.describe(picture), 2, 3, 4, 5, None)
    assert np.array_equal(region, picture[3:8, 2:6])


def test_read_layers_copies_only_rows_above_the_threshold():
    outputs = detector_outputs()
    place_face(outputs, 16, 5, 6, 0, 0.95, [30, 30, 30, 30], [[1, 1]] * 5)
    layers = {name: frames.describe(array[0]) for name, array in outputs.items()}
    read = read_layers(layers, 0.5, None)
    faces = scrfd.decode(read, 640, 0.5)
    assert len(faces) == 1
    assert faces[0].box == pytest.approx((80 - 30, 96 - 30, 80 + 30, 96 + 30))
    assert np.count_nonzero(read["box16"]) == 4


def test_best_face_ignores_faces_outside_the_upper_person_box():
    lower = scrfd.RawFace((100, 300, 140, 340), 0.95, np.zeros((5, 2)))
    upper = scrfd.RawFace((110, 110, 150, 160), 0.8, np.zeros((5, 2)))
    assert best_face([lower, upper], (100, 100, 100, 300)) is upper
    assert best_face([lower], (100, 100, 100, 300)) is None


def test_region_around_stays_inside_the_frame():
    face = scrfd.RawFace((5, 5, 45, 55), 0.9, np.zeros((5, 2)))
    left, top, width, height = region_around(face, 1920, 1080)
    assert left == 0 and top == 0
    assert width > 50 and height > 50


def test_gate_sends_first_better_and_refreshed_faces_only():
    gate = FaceGate(max_sent=3)
    assert gate.want(0, 7, 0.4, 100.0)
    gate.sent_face(0, 7, 0.4, 100.0)
    assert not gate.want(0, 7, 0.9, 100.1)
    assert not gate.want(0, 7, 0.42, 100.6)
    assert gate.want(0, 7, 0.5, 100.6)
    gate.sent_face(0, 7, 0.5, 100.6)
    assert gate.want(0, 7, 0.45, 103.0)
    gate.sent_face(0, 7, 0.45, 103.0)
    assert not gate.want(0, 7, 0.99, 110.0)
    assert not gate.want(1, 8, 0.0, 110.0)
    gate.prune(200.0)
    assert gate.tracks == {}


def test_output_names_follow_stride_and_kind():
    assert output_name((12800, 1), 640) == "score8"
    assert output_name((3200, 4), 640) == "box16"
    assert output_name((800, 10), 640) == "kps32"
    with pytest.raises(ValueError):
        output_name((7, 3), 640)
