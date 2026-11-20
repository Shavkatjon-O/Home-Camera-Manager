"""The Annex-B video output that go2rtc reads from a stream process's standard output."""

import asyncio
import os
from asyncio.streams import FlowControlMixin

from camera_adapters.v380.client import AudioFrame, VideoFrame

__all__ = ["AnnexBPipe", "four_byte_start"]


def four_byte_start(access_unit: bytes) -> bytes:
    """Give an access unit a four-byte start code, which Annex B requires before its first NAL unit.

    Args:
        access_unit: An aligned access unit.

    Returns:
        The access unit starting with 00 00 00 01.
    """
    if access_unit.startswith(b"\0\0\1"):
        return b"\0" + access_unit
    return access_unit


class AnnexBPipe:
    """Writes the video elementary stream to a file descriptor, with flow control when it is a pipe.

    The output is the sequence of access units in arrival order; it continues across reconnects, and each session
    starts with a key frame that carries its parameter sets. Audio is not part of this output.

    Attributes:
        fd: File descriptor, 1 for standard output.
        writer: Stream writer when the descriptor is a pipe, None when writes are plain.
        written: Bytes written.
    """

    def __init__(self, fd: int = 1):
        """Bind the output to a descriptor.

        Args:
            fd: File descriptor.
        """
        self.fd = fd
        self.writer: asyncio.StreamWriter | None = None
        self.written = 0

    async def open(self) -> None:
        """Set up flow control when the descriptor is a pipe or socket."""
        loop = asyncio.get_running_loop()
        try:
            transport, protocol = await loop.connect_write_pipe(
                FlowControlMixin, os.fdopen(self.fd, "wb", 0, closefd=False)
            )
        except (ValueError, OSError):
            self.writer = None
            return
        self.writer = asyncio.StreamWriter(transport, protocol, None, loop)

    async def __call__(self, frame: VideoFrame | AudioFrame) -> None:
        """Write a video frame; audio frames are ignored.

        Args:
            frame: The frame.

        Raises:
            BrokenPipeError: The reader went away.
        """
        if not isinstance(frame, VideoFrame):
            return
        data = four_byte_start(frame.data)
        if self.writer is not None:
            if self.writer.is_closing():
                raise BrokenPipeError("The output reader went away")
            self.writer.write(data)
            await self.writer.drain()
        else:
            view = memoryview(data)
            while view:
                view = view[os.write(self.fd, view) :]
        self.written += len(data)

    def close(self) -> None:
        """Close the flow-controlled writer, if any."""
        if self.writer is not None:
            self.writer.close()
