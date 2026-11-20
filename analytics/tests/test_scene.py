from pathlib import Path

import numpy as np

from app.rules.model import Zone
from app.scene import SceneMatcher
from app.tamper import gradients


def scene(seed):
    generator = np.random.default_rng(seed)
    image = np.zeros((90, 160), np.float32)
    for _ in range(12):
        x, y = generator.integers(0, 140), generator.integers(0, 70)
        image[y : y + 20, x : x + 20] = generator.integers(60, 250)
    return image


def test_zone_is_suspended_after_two_mismatches_and_resumes():
    matcher = SceneMatcher(Path("/nonexistent"))
    matcher.references["ref.jpg"] = gradients(scene(1))
    assert not matcher.update("view", scene(1), {"ref.jpg"})
    assert matcher.matched("view", "ref.jpg")
    assert not matcher.update("view", scene(2), {"ref.jpg"})
    assert matcher.update("view", scene(2), {"ref.jpg"})
    assert not matcher.matched("view", "ref.jpg")
    matcher.update("view", scene(1) * 0.6, {"ref.jpg"})
    assert matcher.update("view", scene(1) * 0.6, {"ref.jpg"})
    assert matcher.matched("view", "ref.jpg")


def test_whole_view_zone():
    whole = Zone.from_dict({"id": "a", "polygon": [[0, 0], [1, 0], [1, 1], [0, 1]]})
    part = Zone.from_dict({"id": "b", "polygon": [[0, 0.5], [1, 0.5], [1, 1], [0, 1]]})
    assert whole.whole_view
    assert not part.whole_view
