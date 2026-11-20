"""TensorRT engines of the secondary stages, built once per host into the engine cache.

The secondary models come from several exporters, and some leave picture axes open, as the text recogniser does
with its width. The builder therefore fixes every axis but the batch at the stage's input size and lets the batch
range from one to the stage's largest batch. Each ONNX file is checked against its published digest before TensorRT
parses it, because a damaged file can make the parser allocate without bound. The cache file name carries the
TensorRT version and the GPU's compute capability, as the detector's engines do, so a Jetson builds its own.
"""

from __future__ import annotations

import hashlib
import logging
import os
import time
from pathlib import Path

from app.engines import engine_path
from app.stages.models import StageModel

logger = logging.getLogger(__name__)

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
        raise FileNotFoundError(f"Model file {path} is missing, run scripts/download-secondary-models.sh")
    actual = sha256(path)
    if actual != expected:
        raise ValueError(f"Model file {path.name} has digest {actual}, expected {expected}; download it again")


def build(model: StageModel, onnx_path: Path, target: Path, workspace_mb: int) -> Path:
    """Build an engine with a fixed picture size and a batch from one to the model's largest, written atomically.

    Args:
        model: The model with its input shape, batch and precision.
        onnx_path: Source ONNX file.
        target: Engine file to write.
        workspace_mb: Builder workspace limit in MiB, which bounds GPU memory during the build.

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
    if model.precision == "fp16":
        config.set_flag(trt.BuilderFlag.FP16)
    profile = builder.create_optimization_profile()
    tensor = network.get_input(0)
    profile.set_shape(
        tensor.name, (1, *model.input_shape), (model.batch, *model.input_shape), (model.batch, *model.input_shape)
    )
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


def ensure(model: StageModel, model_root: Path, engine_dir: Path, workspace_mb: int) -> Path:
    """Return the cached engine of a model, building it first when the cache has none.

    Args:
        model: The model.
        model_root: Folder holding one sub folder per model family.
        engine_dir: Writable engine cache.
        workspace_mb: Builder workspace limit in MiB.

    Returns:
        Path of the engine file.
    """
    target = engine_path(engine_dir, model.name, model.batch, model.precision)
    if target.is_file() and target.stat().st_size > 0:
        return target
    source = model.path(model_root)
    verify(source, model.sha256)
    return build(model, source, target, workspace_mb)
