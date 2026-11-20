import numpy as np
import pytest

from app.falls.pose import INPUT_HEIGHT, INPUT_WIDTH, PoseEstimator, decode, region_for
from app.reid.embedder import Embedder, prepare
from app.stages import engines
from app.stages.crops import Region, canvas, imagenet, is_grey, resize, text_line, widened
from app.stages.gate import Pace, StageGate
from app.stages.models import MODELS, POSE, REID
from app.stages.probe import person_crop


class FakeRunner:
    def __init__(self, outputs, max_batch=4):
        self.inputs = ["input"]
        self.outputs = list(outputs)
        self.max_batch = max_batch
        self.make = outputs
        self.batches = []

    def run(self, feeds):
        batch = feeds["input"]
        self.batches.append(batch.shape)
        return {name: make(batch) for name, make in self.make.items()}


def test_widened_keeps_the_centre_and_aspect():
    region = widened((100, 100, 140, 260), 1.25, 0.75)
    assert region.left + region.width / 2 == pytest.approx(120)
    assert region.top + region.height / 2 == pytest.approx(180)
    assert region.width / region.height == pytest.approx(0.75)
    assert region.height == pytest.approx(200)


def test_region_clips_to_the_frame():
    assert Region(-10, -5, 50, 40).clipped(100, 100) == (0, 0, 40, 35)
    assert Region(120, 10, 20, 20).clipped(100, 100)[2:] == (0, 0)


def test_canvas_is_black_outside_the_frame():
    pixels = np.full((35, 40, 3), 200, np.uint8)
    result = canvas(pixels, Region(-10, -5, 50, 40), (0, 0))
    assert result.shape == (40, 50, 3)
    assert result[:5].max() == 0
    assert result[:, :10].max() == 0
    assert result[5:, 10:].min() == 200


def test_resize_keeps_a_flat_picture_flat_and_scales_a_gradient():
    flat = np.full((10, 20, 3), 77, np.uint8)
    assert np.allclose(resize(flat, 7, 3), 77)
    ramp = np.tile(np.arange(0, 256, 32, dtype=np.float32)[None, :, None], (4, 1, 3))
    wide = resize(ramp, 16, 4)
    assert wide.shape == (4, 16, 3)
    assert np.all(np.diff(wide[0, :, 0]) >= 0)


def test_imagenet_normalization():
    image = np.zeros((2, 2, 3), np.uint8)
    image[..., 0] = 124
    result = imagenet(image)
    assert result.shape == (3, 2, 2)
    assert abs(result[0, 0, 0]) < 0.01
    assert result[1, 0, 0] < -1.9


def test_text_line_scales_to_height_and_pads_right():
    image = np.full((20, 100, 3), 255, np.uint8)
    line = text_line(image, 48, 320)
    assert line.shape == (3, 48, 320)
    assert np.allclose(line[:, :, :240], 1.0)
    assert np.allclose(line[:, :, 241:], 0.0)


def test_is_grey():
    grey = np.full((8, 8, 3), 90, np.uint8)
    colour = grey.copy()
    colour[..., 0] = 160
    assert is_grey(grey)
    assert not is_grey(colour)


def test_gate_paces_and_limits_each_track():
    gate = StageGate({"appearance": Pace(1.0, 2), "pose": Pace(0.25)})
    assert gate.want("appearance", 0, 7, 10.0)
    assert not gate.want("appearance", 0, 7, 10.5)
    assert gate.want("appearance", 1, 7, 10.5)
    assert gate.want("appearance", 0, 7, 11.0)
    assert not gate.want("appearance", 0, 7, 20.0)
    assert gate.want("pose", 0, 7, 20.0)
    assert gate.want("pose", 0, 7, 20.3)
    assert not gate.want("faces", 0, 7, 20.3)
    gate.prune(60.0)
    assert not gate.tracks


def test_person_crop_inside_a_copied_rectangle():
    data = np.arange(60 * 40 * 3, dtype=np.uint8).reshape(60, 40, 3)
    crop = person_crop(data, (100, 200), (110, 210, 130, 250))
    assert crop.shape == (40, 20, 3)
    assert np.array_equal(crop, data[10:50, 10:30])


def test_embedder_batches_and_normalizes():
    runner = FakeRunner({"embeddings": lambda batch: np.ones((len(batch), 512), np.float32) * 3}, max_batch=2)
    crops = [np.zeros((80, 30, 3), np.uint8) for _ in range(5)]
    vectors = Embedder(runner).embed(crops)
    assert vectors.shape == (5, 512)
    assert np.allclose(np.linalg.norm(vectors, axis=1), 1.0)
    assert runner.batches == [(2, 3, 256, 128), (2, 3, 256, 128), (1, 3, 256, 128)]
    assert prepare(crops[0]).shape == REID.input_shape


def test_pose_decode_maps_back_to_the_view():
    region = Region(100, 50, 192, 256)
    simcc_x = np.zeros((17, INPUT_WIDTH * 2), np.float32)
    simcc_y = np.zeros((17, INPUT_HEIGHT * 2), np.float32)
    simcc_x[:, 96 * 2] = 0.9
    simcc_y[:, 128 * 2] = 0.7
    points = decode(simcc_x, simcc_y, region, (1920, 1080))
    assert points.shape == (17, 3)
    assert points[0, 0] == pytest.approx((100 + 96) / 1920)
    assert points[0, 1] == pytest.approx((50 + 128) / 1080)
    assert points[0, 2] == pytest.approx(0.7)


def test_pose_estimator_uses_the_widened_region():
    def simcc(size):
        def make(batch):
            result = np.zeros((len(batch), 17, size), np.float32)
            result[:, :, size // 2] = 1.0
            return result

        return make

    runner = FakeRunner({"simcc_x": simcc(INPUT_WIDTH * 2), "simcc_y": simcc(INPUT_HEIGHT * 2)})
    box = (900, 300, 1000, 700)
    region = region_for(box)
    pixels = np.zeros((int(region.height), int(region.width), 3), np.uint8)
    [points] = PoseEstimator(runner).estimate([(pixels, region)], (1920, 1080))
    assert points[0, 0] == pytest.approx(950 / 1920)
    assert points[0, 1] == pytest.approx(500 / 1080)
    assert region.width / region.height == pytest.approx(0.75)
    assert region.height == pytest.approx(500)


def test_model_registry_matches_the_download_script():
    from pathlib import Path

    path = Path(__file__).resolve().parents[2] / "scripts" / "download-secondary-models.sh"
    if not path.is_file():
        pytest.skip("the repository scripts are not mounted")
    script = path.read_text()
    for model in MODELS.values():
        assert model.sha256 in script
        assert model.onnx in script
    assert POSE.input_shape == (3, 256, 192)


def test_verify_refuses_a_damaged_file(tmp_path):
    path = tmp_path / "model.onnx"
    path.write_bytes(b"not a model")
    with pytest.raises(ValueError):
        engines.verify(path, REID.sha256)
    with pytest.raises(FileNotFoundError):
        engines.verify(tmp_path / "missing.onnx", REID.sha256)
    engines.verify(path, engines.sha256(path))
