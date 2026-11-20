"""TensorRT engines of the face detector and embedder, built once per host into the engine cache.

The SCRFD export has a fixed batch of one, a dynamic picture size and outputs without a batch axis, which nvinfer
cannot host. The builder therefore fixes the input at the detector size and gives every output a leading batch axis
of one, named after its kind and stride, such as score8 or kps32. The glintr100 embedder keeps its dynamic batch.
Both ONNX files are checked against their published digests before TensorRT parses them, because a damaged file can
make the parser allocate without bound.
"""

from __future__ import annotations

import hashlib
import logging
import os
import time
from pathlib import Path

from app.engines import engine_path
from app.identity.settings import DETECTOR_SHA256, EMBEDDER_SHA256, IdentitySettings

logger = logging.getLogger(__name__)

DETECTOR_NAME = "scrfd-10g"
EMBEDDER_NAME = "glintr100"
EMBEDDER_SIZE = 112
STRIDES = (8, 16, 32)
KINDS = {1: "score", 4: "box", 10: "kps"}
HASH_CHUNK = 1 << 20


def sha256(path: Path) -> str:
    """Return the SHA-256 digest of a file.

    Args:
        path: The file.

    Returns:
        The hex digest.
    """
    digest = hashlib.sha256()
    with open(path, "rb") as handle:
        for chunk in iter(lambda: handle.read(HASH_CHUNK), b""):
            digest.update(chunk)
    return digest.hexdigest()


def verify(path: Path, expected: str) -> None:
    """Check a model file against its published digest before anything parses it.

    Args:
        path: The model file.
        expected: Its SHA-256 digest.

    Raises:
        FileNotFoundError: If the file is missing.
        ValueError: If the digest differs.
    """
    if not path.is_file():
        raise FileNotFoundError(f"Model file {path} is missing, run scripts/download-face-models.sh")
    actual = sha256(path)
    if actual != expected:
        raise ValueError(f"Model file {path.name} has digest {actual}, expected {expected}; download it again")


def output_name(shape: tuple[int, ...], size: int) -> str:
    """Name a detector output after its kind and stride.

    Args:
        shape: The output shape for one picture, anchors by values per anchor.
        size: Square detector input size.

    Returns:
        A name such as score8, box16 or kps32.

    Raises:
        ValueError: If the shape matches no stride or kind.
    """
    anchors, values = shape[-2], shape[-1]
    for stride in STRIDES:
        if anchors == (size // stride) ** 2 * 2 and values in KINDS:
            return f"{KINDS[values]}{stride}"
    raise ValueError(f"Unexpected detector output shape {shape}")


def build(onnx_path: Path, target: Path, detector_size: int | None, batch: int, workspace_mb: int) -> Path:
    """Build a face engine in half precision and write it atomically.

    Args:
        onnx_path: Source ONNX model.
        target: Engine file to write.
        detector_size: Square input size for the detector, or None for the embedder.
        batch: Largest batch of the embedder; the detector always takes one picture.
        workspace_mb: Builder workspace limit in MiB.

    Returns:
        The written engine path.

    Raises:
        RuntimeError: If the ONNX file does not parse or TensorRT cannot build the engine.
    """
    import tensorrt as trt

    trt_logger = trt.Logger(trt.Logger.WARNING)
    builder = trt.Builder(trt_logger)
    network = builder.create_network(0)
    parser = trt.OnnxParser(network, trt_logger)
    if not parser.parse_from_file(str(onnx_path)):
        errors = "; ".join(str(parser.get_error(index)) for index in range(parser.num_errors))
        raise RuntimeError(f"Parsing {onnx_path.name} failed: {errors}")
    config = builder.create_builder_config()
    config.set_memory_pool_limit(trt.MemoryPoolType.WORKSPACE, workspace_mb << 20)
    config.set_flag(trt.BuilderFlag.FP16)
    image = network.get_input(0)
    image.name = "image"
    if detector_size is not None:
        image.shape = (1, 3, detector_size, detector_size)
        outputs = [network.get_output(index) for index in range(network.num_outputs)]
        for output in outputs:
            network.unmark_output(output)
            shuffle = network.add_shuffle(output)
            shuffle.reshape_dims = (1, *tuple(output.shape))
            batched = shuffle.get_output(0)
            batched.name = output_name(tuple(output.shape), detector_size)
            network.mark_output(batched)
    else:
        network.get_output(0).name = "embedding"
        profile = builder.create_optimization_profile()
        dims = tuple(image.shape)[1:]
        profile.set_shape(image.name, (1, *dims), (batch, *dims), (batch, *dims))
        config.add_optimization_profile(profile)
    started = time.monotonic()
    logger.info("Building the TensorRT engine %s once for this host", target.name)
    serialized = builder.build_serialized_network(network, config)
    if serialized is None:
        raise RuntimeError(f"TensorRT could not build an engine from {onnx_path.name}")
    target.parent.mkdir(parents=True, exist_ok=True)
    temporary = target.with_suffix(".part")
    with open(temporary, "wb") as handle:
        handle.write(serialized)
    os.replace(temporary, target)
    logger.info("Built %s in %.0f s", target.name, time.monotonic() - started)
    return target


def detector_engine(settings: IdentitySettings, engine_dir: Path, workspace_mb: int) -> Path:
    """Return the cached face detector engine, building it first when the cache has none.

    Args:
        settings: Face settings with the model folder and detector size.
        engine_dir: Writable engine cache.
        workspace_mb: Builder workspace limit in MiB.

    Returns:
        Path of the engine file.
    """
    target = engine_path(engine_dir, f"{DETECTOR_NAME}-{settings.detector_size}", 1, "fp16")
    if target.is_file() and target.stat().st_size > 0:
        return target
    verify(settings.detector_path, DETECTOR_SHA256)
    return build(settings.detector_path, target, settings.detector_size, 1, workspace_mb)


def embedder_engine(settings: IdentitySettings, engine_dir: Path, workspace_mb: int) -> Path:
    """Return the cached face embedder engine, building it first when the cache has none.

    Args:
        settings: Face settings with the model folder and batch size.
        engine_dir: Writable engine cache.
        workspace_mb: Builder workspace limit in MiB.

    Returns:
        Path of the engine file.
    """
    target = engine_path(engine_dir, EMBEDDER_NAME, settings.embed_batch, "fp16")
    if target.is_file() and target.stat().st_size > 0:
        return target
    verify(settings.embedder_path, EMBEDDER_SHA256)
    return build(settings.embedder_path, target, None, settings.embed_batch, workspace_mb)
