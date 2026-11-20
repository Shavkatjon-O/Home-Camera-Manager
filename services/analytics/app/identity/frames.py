"""Reading DeepStream tensors that live in GPU memory into host arrays.

Service Maker hands out frames and inference outputs as tensors that support DLPack but sit in device memory, which
numpy cannot import. The DLPack capsule is read with ctypes for its device pointer, shape and strides, and only the
needed bytes are copied with the CUDA runtime: a few rows of an output layer, or the rectangle around a face of an
RGB frame.
"""

from __future__ import annotations

import ctypes
from dataclasses import dataclass

import numpy as np

from app.identity.runtime import Cuda

CUDA_DEVICES = (2, 13)
CAPSULE_NAME = b"dltensor"
DTYPES = {(2, 32): np.float32, (1, 8): np.uint8, (0, 8): np.int8, (2, 16): np.float16, (0, 32): np.int32}


class DLDevice(ctypes.Structure):
    """DLPack device description.

    Attributes:
        device_type: DLPack device type code, 2 for CUDA.
        device_id: Device index.
    """

    _fields_ = [("device_type", ctypes.c_int32), ("device_id", ctypes.c_int32)]


class DLDataType(ctypes.Structure):
    """DLPack element type description.

    Attributes:
        code: Type class code: 0 signed, 1 unsigned, 2 float.
        bits: Bits per element.
        lanes: Vector lanes, 1 for scalars.
    """

    _fields_ = [("code", ctypes.c_uint8), ("bits", ctypes.c_uint8), ("lanes", ctypes.c_uint16)]


class DLTensor(ctypes.Structure):
    """DLPack tensor description.

    Attributes:
        data: Address of the data.
        device: Device the data lives on.
        ndim: Number of dimensions.
        dtype: Element type.
        shape: Size of each dimension.
        strides: Stride of each dimension in elements, or null for a compact tensor.
        byte_offset: Offset of the first element from data in bytes.
    """

    _fields_ = [
        ("data", ctypes.c_void_p),
        ("device", DLDevice),
        ("ndim", ctypes.c_int32),
        ("dtype", DLDataType),
        ("shape", ctypes.POINTER(ctypes.c_int64)),
        ("strides", ctypes.POINTER(ctypes.c_int64)),
        ("byte_offset", ctypes.c_uint64),
    ]


get_pointer = ctypes.pythonapi.PyCapsule_GetPointer
get_pointer.restype = ctypes.c_void_p
get_pointer.argtypes = [ctypes.py_object, ctypes.c_char_p]


@dataclass(frozen=True)
class DeviceTensor:
    """Where a tensor's elements are and how they are laid out.

    Attributes:
        pointer: Address of the first element.
        gpu: True when the address is device memory.
        shape: Size of each axis.
        strides: Elements between neighbours along each axis.
        dtype: Element type.
        owner: The capsule that keeps the memory alive while this description is used.
    """

    pointer: int
    gpu: bool
    shape: tuple[int, ...]
    strides: tuple[int, ...]
    dtype: np.dtype
    owner: object


def describe(tensor) -> DeviceTensor:
    """Read a DLPack-capable tensor's layout without copying it.

    Args:
        tensor: An object with a __dlpack__ method, such as a Service Maker tensor.

    Returns:
        The tensor's address and layout.

    Raises:
        ValueError: If the element type is not supported.
    """
    capsule = tensor.__dlpack__(stream=None)
    info = DLTensor.from_address(get_pointer(capsule, CAPSULE_NAME))
    shape = tuple(info.shape[axis] for axis in range(info.ndim))
    if info.strides:
        strides = tuple(info.strides[axis] for axis in range(info.ndim))
    else:
        strides = tuple(int(np.prod(shape[axis + 1 :])) for axis in range(info.ndim))
    key = (info.dtype.code, info.dtype.bits)
    if key not in DTYPES:
        raise ValueError(f"Unsupported tensor element type {key}")
    return DeviceTensor(
        pointer=int(info.data or 0) + int(info.byte_offset),
        gpu=info.device.device_type in CUDA_DEVICES,
        shape=shape,
        strides=strides,
        dtype=np.dtype(DTYPES[key]),
        owner=capsule,
    )


def read(tensor: DeviceTensor, cuda: Cuda) -> np.ndarray:
    """Copy a whole contiguous tensor into a host array.

    Args:
        tensor: The tensor description.
        cuda: CUDA runtime for device tensors.

    Returns:
        A new host array with the tensor's shape.
    """
    result = np.empty(tensor.shape, dtype=tensor.dtype)
    if tensor.gpu:
        cuda.download(result, tensor.pointer)
    else:
        ctypes.memmove(result.ctypes.data, tensor.pointer, result.nbytes)
    return result


def read_rows(tensor: DeviceTensor, rows: np.ndarray, cuda: Cuda) -> np.ndarray:
    """Copy selected rows of a contiguous two-dimensional tensor.

    Args:
        tensor: The tensor description, rows by values.
        rows: Row indices to copy.
        cuda: CUDA runtime for device tensors.

    Returns:
        Array of the selected rows, in the given order.
    """
    width = int(np.prod(tensor.shape[1:])) if len(tensor.shape) > 1 else 1
    result = np.empty((len(rows), width), dtype=tensor.dtype)
    row_bytes = width * tensor.dtype.itemsize
    for slot, row in enumerate(rows):
        source = tensor.pointer + int(row) * row_bytes
        if tensor.gpu:
            cuda.download(result[slot], source)
        else:
            ctypes.memmove(result[slot].ctypes.data, source, row_bytes)
    return result


def read_region(frame: DeviceTensor, left: int, top: int, width: int, height: int, cuda: Cuda) -> np.ndarray:
    """Copy a rectangle of a packed RGB or RGBA frame.

    Args:
        frame: Frame description, height by width by channels, uint8, rows possibly padded.
        left: Left edge of the rectangle in pixels, inside the frame.
        top: Top edge in pixels, inside the frame.
        width: Width in pixels.
        height: Height in pixels.
        cuda: CUDA runtime for device frames.

    Returns:
        The rectangle as height by width by 3 RGB pixels.
    """
    channels = frame.shape[2] if len(frame.shape) == 3 else 1
    pitch = frame.strides[0] * frame.dtype.itemsize
    region = np.empty((height, width, channels), dtype=np.uint8)
    start = frame.pointer + top * pitch + left * channels
    if frame.gpu:
        cuda.download_rows(region, start, pitch)
    else:
        for row in range(height):
            ctypes.memmove(region[row].ctypes.data, start + row * pitch, width * channels)
    return region[:, :, :3]
