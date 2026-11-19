"""Minimal CUDA runtime and TensorRT execution through ctypes.

The DeepStream image ships TensorRT's Python API and the CUDA runtime library but no CUDA Python binding, so device
memory, copies and streams go through libcudart directly. Only what the face models need is wrapped.
"""

from __future__ import annotations

import ctypes
import threading
from pathlib import Path

import numpy as np

HOST_TO_DEVICE = 1
DEVICE_TO_HOST = 2
LIBRARIES = ("libcudart.so", "libcudart.so.13", "libcudart.so.12")


class CudaError(RuntimeError):
    """A CUDA runtime call failed."""


class Cuda:
    """The CUDA runtime functions the face models use.

    Attributes:
        library: The loaded libcudart.
    """

    def __init__(self):
        """Load the CUDA runtime library.

        Raises:
            OSError: If no CUDA runtime library can be loaded.
        """
        errors = []
        for name in LIBRARIES:
            try:
                self.library = ctypes.CDLL(name)
                break
            except OSError as exc:
                errors.append(str(exc))
        else:
            raise OSError("; ".join(errors))
        self.library.cudaGetErrorString.restype = ctypes.c_char_p
        size = ctypes.c_size_t
        self.library.cudaMalloc.argtypes = [ctypes.POINTER(ctypes.c_void_p), size]
        self.library.cudaFree.argtypes = [ctypes.c_void_p]
        self.library.cudaMemcpy.argtypes = [ctypes.c_void_p, ctypes.c_void_p, size, ctypes.c_int]
        self.library.cudaMemcpy2D.argtypes = [
            ctypes.c_void_p,
            size,
            ctypes.c_void_p,
            size,
            size,
            size,
            ctypes.c_int,
        ]
        self.library.cudaStreamCreate.argtypes = [ctypes.POINTER(ctypes.c_void_p)]
        self.library.cudaStreamSynchronize.argtypes = [ctypes.c_void_p]
        self.library.cudaMemGetInfo.argtypes = [ctypes.POINTER(size), ctypes.POINTER(size)]

    def check(self, code: int, call: str) -> None:
        """Raise when a runtime call returned an error.

        Args:
            code: The returned cudaError_t.
            call: Name of the call, for the message.

        Raises:
            CudaError: If the code is not success.
        """
        if code != 0:
            message = self.library.cudaGetErrorString(code).decode(errors="replace")
            raise CudaError(f"{call} failed with error {code}: {message}")

    def malloc(self, nbytes: int) -> int:
        """Allocate device memory.

        Args:
            nbytes: Size in bytes.

        Returns:
            The device pointer.
        """
        pointer = ctypes.c_void_p()
        self.check(self.library.cudaMalloc(ctypes.byref(pointer), max(1, nbytes)), "cudaMalloc")
        return int(pointer.value)

    def free(self, pointer: int) -> None:
        """Release device memory.

        Args:
            pointer: The device pointer.
        """
        self.library.cudaFree(ctypes.c_void_p(pointer))

    def upload(self, pointer: int, array: np.ndarray) -> None:
        """Copy a contiguous host array to device memory.

        Args:
            pointer: Destination device pointer.
            array: Source array.
        """
        array = np.ascontiguousarray(array)
        self.check(
            self.library.cudaMemcpy(ctypes.c_void_p(pointer), array.ctypes.data, array.nbytes, HOST_TO_DEVICE),
            "cudaMemcpy",
        )

    def download(self, array: np.ndarray, pointer: int) -> None:
        """Copy device memory into a contiguous host array.

        Args:
            array: Destination array, filled completely.
            pointer: Source device pointer.
        """
        self.check(
            self.library.cudaMemcpy(array.ctypes.data, ctypes.c_void_p(pointer), array.nbytes, DEVICE_TO_HOST),
            "cudaMemcpy",
        )

    def download_rows(self, array: np.ndarray, pointer: int, pitch: int) -> None:
        """Copy a pitched device region into a contiguous host array.

        Args:
            array: Destination array whose first axis is the rows; every row is copied whole.
            pointer: Device pointer of the first byte of the region.
            pitch: Bytes between the starts of two rows on the device.
        """
        rows = array.shape[0]
        width = array.nbytes // rows
        self.check(
            self.library.cudaMemcpy2D(
                array.ctypes.data, width, ctypes.c_void_p(pointer), pitch, width, rows, DEVICE_TO_HOST
            ),
            "cudaMemcpy2D",
        )

    def stream(self) -> int:
        """Create a CUDA stream.

        Returns:
            The stream handle.
        """
        handle = ctypes.c_void_p()
        self.check(self.library.cudaStreamCreate(ctypes.byref(handle)), "cudaStreamCreate")
        return int(handle.value or 0)

    def synchronize(self, stream: int) -> None:
        """Wait until a stream finishes.

        Args:
            stream: The stream handle.
        """
        self.check(self.library.cudaStreamSynchronize(ctypes.c_void_p(stream)), "cudaStreamSynchronize")

    def memory(self) -> tuple[int, int]:
        """Return free and total device memory.

        Returns:
            Free and total bytes.
        """
        free, total = ctypes.c_size_t(), ctypes.c_size_t()
        self.check(self.library.cudaMemGetInfo(ctypes.byref(free), ctypes.byref(total)), "cudaMemGetInfo")
        return free.value, total.value


class EngineRunner:
    """Runs one TensorRT engine on host arrays.

    Device buffers are allocated once for the largest shapes, so a call only copies and executes. Calls are
    serialised, because an execution context is not thread-safe.

    Attributes:
        cuda: The CUDA runtime.
        inputs: Input tensor names.
        outputs: Output tensor names.
        max_batch: Largest batch the engine accepts.
    """

    def __init__(self, engine_file: Path, cuda: Cuda | None = None):
        """Load an engine and allocate its buffers.

        Args:
            engine_file: Serialized engine.
            cuda: CUDA runtime to use, loaded when None.

        Raises:
            RuntimeError: If TensorRT cannot deserialize the engine.
        """
        import tensorrt as trt

        self.cuda = cuda or Cuda()
        self.lock = threading.Lock()
        self.logger = trt.Logger(trt.Logger.WARNING)
        self.runtime = trt.Runtime(self.logger)
        self.engine = self.runtime.deserialize_cuda_engine(Path(engine_file).read_bytes())
        if self.engine is None:
            raise RuntimeError(f"TensorRT could not load {engine_file}")
        self.context = self.engine.create_execution_context()
        self.stream = self.cuda.stream()
        self.inputs: list[str] = []
        self.outputs: list[str] = []
        self.shapes: dict[str, tuple[int, ...]] = {}
        self.dtypes: dict[str, np.dtype] = {}
        self.buffers: dict[str, int] = {}
        self.max_batch = 1
        for index in range(self.engine.num_io_tensors):
            name = self.engine.get_tensor_name(index)
            dtype = np.dtype(trt.nptype(self.engine.get_tensor_dtype(name)))
            shape = tuple(self.engine.get_tensor_shape(name))
            if self.engine.get_tensor_mode(name) == trt.TensorIOMode.INPUT:
                self.inputs.append(name)
                if -1 in shape:
                    shape = tuple(self.engine.get_tensor_profile_shape(name, 0)[2])
                    self.max_batch = max(self.max_batch, shape[0])
            else:
                self.outputs.append(name)
            self.dtypes[name] = dtype
            self.shapes[name] = shape
        for name in self.inputs:
            self.context.set_input_shape(name, self.shapes[name])
        for name in self.outputs:
            self.shapes[name] = tuple(self.context.get_tensor_shape(name))
        for name, shape in self.shapes.items():
            nbytes = int(np.prod(shape)) * self.dtypes[name].itemsize
            self.buffers[name] = self.cuda.malloc(nbytes)
            self.context.set_tensor_address(name, self.buffers[name])

    def run(self, feeds: dict[str, np.ndarray]) -> dict[str, np.ndarray]:
        """Run the engine.

        Args:
            feeds: One array per input name, within the engine's largest shape.

        Returns:
            One new host array per output name.

        Raises:
            RuntimeError: If TensorRT reports a failed execution.
        """
        with self.lock:
            for name in self.inputs:
                array = np.ascontiguousarray(feeds[name], dtype=self.dtypes[name])
                self.context.set_input_shape(name, array.shape)
                self.cuda.upload(self.buffers[name], array)
            if not self.context.execute_async_v3(self.stream):
                raise RuntimeError("TensorRT execution failed")
            self.cuda.synchronize(self.stream)
            results = {}
            for name in self.outputs:
                result = np.empty(tuple(self.context.get_tensor_shape(name)), dtype=self.dtypes[name])
                self.cuda.download(result, self.buffers[name])
                results[name] = result
            return results

    def close(self) -> None:
        """Free the device buffers."""
        for pointer in self.buffers.values():
            self.cuda.free(pointer)
        self.buffers = {}
