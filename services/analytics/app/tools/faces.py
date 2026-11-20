"""Measure the face models and calibrate the recognition thresholds.

bench loads both engines, reports the GPU memory they take and times the detector and the embedder at several
batch sizes. embed detects, aligns and embeds the largest face of every picture a pairs file names, in several
conditions that imitate the cameras: as photographed, shrunk to a small door-camera face, grey as in night vision,
and both. calibrate reads those embeddings and prints the similarity of every same-person and different-person pair
for each pairing of conditions, with the acceptance and false match rates at a range of thresholds. The pairs file
uses the layout of the LFW benchmark's pairs.txt: a header line, then name, index, index for a same-person pair and
name, index, name, index for a different-person pair. Usage::

    python -m app.tools.faces bench --engines /engines
    python -m app.tools.faces embed --pairs pairs.txt --images lfw --output embeddings.npz
    python -m app.tools.faces calibrate --pairs pairs.txt --embeddings embeddings.npz
"""

from __future__ import annotations

import argparse
import json
import time
from pathlib import Path

import numpy as np

from app.identity import align
from app.identity.enroll import decode_photo, shrink
from app.identity.models import FaceModels
from app.identity.settings import IdentitySettings

SMALL_FACE = 40.0
CONDITIONS = ("photo", "small", "grey", "grey_small")
PAIRINGS = (
    ("photo", "photo"),
    ("photo", "small"),
    ("photo", "grey_small"),
    ("small", "small"),
    ("grey_small", "grey_small"),
    ("small", "grey_small"),
)
THRESHOLDS = (0.2, 0.25, 0.28, 0.3, 0.35, 0.4, 0.42, 0.45, 0.47, 0.5, 0.55, 0.6)


def parse_args() -> argparse.Namespace:
    """Parse the command line.

    Returns:
        The parsed arguments.
    """
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("command", choices=("bench", "embed", "calibrate"))
    parser.add_argument("--engines", default=Path("/engines"), type=Path)
    parser.add_argument("--workspace", default=1024, type=int)
    parser.add_argument("--pairs", type=Path)
    parser.add_argument("--images", type=Path)
    parser.add_argument("--embeddings", type=Path)
    parser.add_argument("--output", type=Path)
    return parser.parse_args()


def picture_path(root: Path, name: str, index: int) -> Path:
    """Return the file of one picture of a pairs file.

    Args:
        root: Folder with one sub folder per person.
        name: Person folder name.
        index: One-based picture number.

    Returns:
        The path.
    """
    return root / name / f"{name}_{index:04d}.jpg"


def read_pairs(path: Path) -> list[tuple[str, str, bool]]:
    """Read a pairs file.

    Args:
        path: The file.

    Returns:
        Picture keys of both sides and whether they show the same person.
    """
    pairs = []
    for line in path.read_text().splitlines()[1:]:
        parts = line.split()
        if len(parts) == 3:
            pairs.append((f"{parts[0]}/{int(parts[1])}", f"{parts[0]}/{int(parts[2])}", True))
        elif len(parts) == 4:
            pairs.append((f"{parts[0]}/{int(parts[1])}", f"{parts[2]}/{int(parts[3])}", False))
    return pairs


def bench(args: argparse.Namespace) -> None:
    """Load the engines and time them.

    Args:
        args: Command line arguments.
    """
    settings = IdentitySettings()
    models = FaceModels(settings, args.engines, args.workspace)
    from app.identity.runtime import Cuda

    cuda = Cuda()
    free_before, total = cuda.memory()
    started = time.monotonic()
    models.load()
    loaded = time.monotonic() - started
    free_after, _ = cuda.memory()
    rng = np.random.default_rng(0)
    results = {"load_seconds": round(loaded, 1), "engines_mib": round((free_before - free_after) / 2**20)}
    for batch in (1, 4, 8):
        faces = [rng.integers(0, 255, (112, 112, 3), dtype=np.uint8) for _ in range(batch)]
        models.embed(faces)
        started = time.perf_counter()
        for _ in range(50):
            models.embed(faces)
        results[f"embed_batch{batch}_ms"] = round((time.perf_counter() - started) * 1000 / 50, 2)
    picture = rng.integers(0, 255, (1080, 1920, 3), dtype=np.uint8)
    models.detect(picture, 0.5)
    started = time.perf_counter()
    for _ in range(20):
        models.detect(picture, 0.5)
    results["detect_1080p_ms"] = round((time.perf_counter() - started) * 1000 / 20, 2)
    free_end, _ = cuda.memory()
    results["process_mib_after_runs"] = round((free_before - free_end) / 2**20)
    results["gpu_total_mib"] = round(total / 2**20)
    print(json.dumps(results, indent=1))


def conditions(image: np.ndarray, landmarks: np.ndarray, height: float) -> dict[str, np.ndarray]:
    """Align one face in every measured condition.

    Args:
        image: The picture.
        landmarks: The face's landmarks.
        height: The face's box height.

    Returns:
        Aligned face per condition.
    """
    grey = np.repeat(image.astype(np.float32).mean(axis=2, keepdims=True), 3, axis=2).astype(np.uint8)
    factor = min(1.0, SMALL_FACE / max(height, 1.0))
    small = shrink(image, factor)
    small_grey = shrink(grey, factor)
    return {
        "photo": align.align(image, landmarks),
        "small": align.align(small, landmarks * factor),
        "grey": align.align(grey, landmarks),
        "grey_small": align.align(small_grey, landmarks * factor),
    }


def embed(args: argparse.Namespace) -> None:
    """Embed every picture a pairs file names in every condition.

    Args:
        args: Command line arguments.
    """
    settings = IdentitySettings()
    models = FaceModels(settings, args.engines, args.workspace)
    keys = sorted({key for left, right, _ in read_pairs(args.pairs) for key in (left, right)})
    names, vectors, missing = [], {condition: [] for condition in CONDITIONS}, []
    started = time.monotonic()
    for number, key in enumerate(keys):
        name, index = key.split("/")
        image = decode_photo(picture_path(args.images, name, int(index)).read_bytes())
        found = models.detect(image, 0.5)
        if not found:
            missing.append(key)
            continue
        centre = np.array([image.shape[1] / 2, image.shape[0] / 2])
        face = min(found, key=lambda item: np.hypot(*(item.landmarks[2] - centre)))
        aligned = conditions(image, face.landmarks, face.height)
        embeddings = models.embed([aligned[condition] for condition in CONDITIONS])
        names.append(key)
        for condition, embedding in zip(CONDITIONS, embeddings):
            vectors[condition].append(embedding)
        if number % 500 == 0:
            print(f"{number} of {len(keys)} pictures, {time.monotonic() - started:.0f} s")
    np.savez_compressed(
        args.output, names=np.array(names), **{condition: np.stack(vectors[condition]) for condition in CONDITIONS}
    )
    print(f"{len(names)} pictures embedded, {len(missing)} without a face, {time.monotonic() - started:.0f} s")


def rates(genuine: np.ndarray, impostor: np.ndarray) -> list[dict]:
    """Compute acceptance and false match rates at the measured thresholds.

    Args:
        genuine: Same-person similarities.
        impostor: Different-person similarities.

    Returns:
        One row per threshold.
    """
    return [
        {
            "threshold": threshold,
            "accepted": round(float((genuine >= threshold).mean()), 4),
            "false_match": round(float((impostor >= threshold).mean()), 5),
        }
        for threshold in THRESHOLDS
    ]


def calibrate(args: argparse.Namespace) -> None:
    """Print similarity statistics for every pairing of conditions.

    Args:
        args: Command line arguments.
    """
    with np.load(args.embeddings) as stored:
        data = {name: stored[name] for name in stored.files}
    index = {str(name): row for row, name in enumerate(data["names"])}
    pairs = [(index.get(left), index.get(right), same) for left, right, same in read_pairs(args.pairs)]
    pairs = [(left, right, same) for left, right, same in pairs if left is not None and right is not None]
    report = {}
    for first, second in PAIRINGS:
        lefts = np.array([pair[0] for pair in pairs])
        rights = np.array([pair[1] for pair in pairs])
        scores = (data[first][lefts] * data[second][rights]).sum(axis=1)
        same = np.array([pair[2] for pair in pairs])
        genuine, impostor = scores[same], scores[~same]
        report[f"{first}-{second}"] = {
            "pairs": [int(same.sum()), int((~same).sum())],
            "genuine_percentiles": {p: round(float(np.percentile(genuine, p)), 3) for p in (1, 5, 10, 25, 50)},
            "impostor_percentiles": {p: round(float(np.percentile(impostor, p)), 3) for p in (50, 99, 99.9, 100)},
            "rates": rates(genuine, impostor),
        }
    print(json.dumps(report, indent=1))


def main() -> None:
    """Run the chosen command."""
    args = parse_args()
    {"bench": bench, "embed": embed, "calibrate": calibrate}[args.command](args)


if __name__ == "__main__":
    main()
