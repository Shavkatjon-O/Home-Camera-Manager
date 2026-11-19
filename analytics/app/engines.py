"""TensorRT engine cache: build each detector's engine once per host and reuse it.

nvinfer resolves the ONNX path before it saves an engine it built, so with read-only model mounts it would rebuild
on every start. The service therefore builds engines itself with the TensorRT Python API into the writable cache
folder and hands nvinfer the finished engine. The file name carries the TensorRT version and the GPU compute
capability, so a driver or hardware change, or a Jetson sharing the same configuration, builds its own engine.
"""

from __future__ import annotations

import ctypes
import logging
import os
import time
from pathlib import Path

logger = logging.getLogger(__name__)


def compute_capability() -> str:
    """Return the compute capability of GPU 0 as a short tag such as sm120.

    Returns:
        The tag, or sm0 when the CUDA driver cannot be queried.
    """
    try:
        cuda = ctypes.CDLL("libcuda.so.1")
        major, minor, device = ctypes.c_int(), ctypes.c_int(), ctypes.c_int()
        if cuda.cuInit(0) != 0 or cuda.cuDeviceGet(ctypes.byref(device), 0) != 0:
            return "sm0"
        cuda.cuDeviceGetAttribute(ctypes.byref(major), 75, device)
        cuda.cuDeviceGetAttribute(ctypes.byref(minor), 76, device)
        return f"sm{major.value}{minor.value}"
    except OSError:
        return "sm0"


def engine_path(engine_dir: Path, name: str, batch_size: int, precision: str) -> Path:
    """Return the cache path of an engine for this host.

    Args:
        engine_dir: Writable cache folder.
        name: Detector name.
        batch_size: Maximum batch the engine accepts.
        precision: fp16 or fp32.

    Returns:
        The engine path, which may not exist yet.
    """
    import tensorrt

    tag = f"trt{tensorrt.__version__}_{compute_capability()}"
    return engine_dir / name / f"{name}_b{batch_size}_{precision}_{tag}.engine"


def build_engine(onnx_path: Path, target: Path, batch_size: int, precision: str, workspace_mb: int) -> Path:
    """Build a TensorRT engine with a dynamic batch dimension and write it atomically.

    Args:
        onnx_path: Source ONNX model whose first dimension is the batch.
        target: Engine file to write.
        batch_size: Largest batch the optimization profile covers; it is also the optimum.
        precision: fp16 enables half precision kernels, fp32 keeps full precision.
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
    if precision == "fp16":
        config.set_flag(trt.BuilderFlag.FP16)
    profile = builder.create_optimization_profile()
    for index in range(network.num_inputs):
        tensor = network.get_input(index)
        dims = tuple(tensor.shape)[1:]
        profile.set_shape(tensor.name, (1, *dims), (batch_size, *dims), (batch_size, *dims))
    config.add_optimization_profile(profile)
    started = time.monotonic()
    logger.info("Building the TensorRT engine %s, this takes a few minutes once per host", target.name)
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


def ensure_engine(
    onnx_path: Path, engine_dir: Path, name: str, batch_size: int, precision: str, workspace_mb: int
) -> Path:
    """Return a cached engine for the model, building it first when the cache has none.

    Args:
        onnx_path: Source ONNX model.
        engine_dir: Writable cache folder.
        name: Detector name used for the cache sub folder and file name.
        batch_size: Largest batch the engine accepts.
        precision: fp16 or fp32.
        workspace_mb: Builder workspace limit in MiB.

    Returns:
        Path of the engine file.
    """
    target = engine_path(engine_dir, name, batch_size, precision)
    if target.is_file() and target.stat().st_size > 0:
        return target
    return build_engine(onnx_path, target, batch_size, precision, workspace_mb)
