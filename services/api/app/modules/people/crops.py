"""Storage of face crop images under the shared events folder."""

import asyncio
import base64
import binascii
import logging
import os
from collections.abc import Iterable
from pathlib import Path, PurePosixPath
from uuid import UUID, uuid4

logger = logging.getLogger(__name__)

JPEG_MAGIC = b"\xff\xd8"
CROP_MAX_BYTES = 2 * 1024 * 1024

PEOPLE_FOLDER = "people"


def enrolled_crop_path(person_uuid: UUID, sample_uuid: UUID) -> str:
    """Build the relative path of the crop of an uploaded sample.

    Args:
        person_uuid: Public id of the person the sample belongs to.
        sample_uuid: Public id of the sample.

    Returns:
        The path relative to the events folder.
    """
    return f"{PEOPLE_FOLDER}/{person_uuid}/{sample_uuid}.jpg"


def is_relative_inside(relative: str) -> bool:
    """Check that a stored path is relative and does not climb out of its folder.

    Args:
        relative: Path as sent or stored.

    Returns:
        True when the path is relative, not empty and has no parent or empty parts.
    """
    if not relative or "\\" in relative or "\x00" in relative:
        return False
    path = PurePosixPath(relative)
    if path.is_absolute():
        return False
    return all(part not in ("", ".", "..") for part in relative.split("/"))


def decode_crop(text: str | bytes) -> bytes:
    """Decode a base64 JPEG crop and check that it is one.

    Args:
        text: Standard base64 of the JPEG bytes, or the JPEG bytes themselves.

    Returns:
        The JPEG bytes.

    Raises:
        ValueError: When the text is not base64, is too large or is not a JPEG image.
    """
    if isinstance(text, bytes) and text.startswith(JPEG_MAGIC):
        content = text
    else:
        try:
            content = base64.b64decode(text, validate=True)
        except (binascii.Error, ValueError) as exc:
            raise ValueError("the crop is not valid base64") from exc
    if len(content) > CROP_MAX_BYTES:
        raise ValueError("the crop is too large")
    if not content.startswith(JPEG_MAGIC):
        raise ValueError("the crop is not a JPEG image")
    return content


class CropStore:
    """Read, write and delete face crops kept as JPEG files under one folder.

    Attributes:
        root: Folder the crops are stored under, the shared events folder.
    """

    def __init__(self, root: str | Path):
        """Bind the store to its folder.

        Args:
            root: Folder the crops are stored under.
        """
        self.root = Path(root)

    def resolve(self, relative: str | None) -> Path | None:
        """Turn a stored relative path into an absolute path inside the store folder.

        Symbolic links are followed before the check, so a link cannot lead out of the folder either.

        Args:
            relative: Path relative to the store folder, or None.

        Returns:
            The absolute path, or None when the path is empty or points outside the store folder.
        """
        if not relative:
            return None
        root = self.root.resolve()
        path = (root / relative).resolve()
        if root not in path.parents:
            return None
        return path

    async def write(self, relative: str, content: bytes) -> bool:
        """Write a crop without blocking the event loop.

        Args:
            relative: Path relative to the store folder.
            content: JPEG bytes.

        Returns:
            True when the file was written, False when the path points outside the folder or the write failed.
        """
        target = self.resolve(relative)
        if target is None or not content:
            return False
        try:
            await asyncio.to_thread(self.write_file, target, content)
        except OSError as exc:
            logger.warning("Writing the face crop %s failed: %s", relative, exc)
            return False
        return True

    def write_file(self, target: Path, content: bytes) -> None:
        """Write a file through a temporary name so a reader never sees a partial image.

        Args:
            target: Absolute path of the file.
            content: Bytes to write.

        Raises:
            OSError: When the folder or the file cannot be written.
        """
        target.parent.mkdir(parents=True, exist_ok=True)
        temporary = target.with_name(f"{target.name}.{uuid4().hex}.part")
        try:
            temporary.write_bytes(content)
            os.replace(temporary, target)
        except OSError:
            temporary.unlink(missing_ok=True)
            raise

    async def delete(self, relatives: Iterable[str | None]) -> None:
        """Delete crops without blocking the event loop and without raising.

        Args:
            relatives: Paths relative to the store folder; empty entries are skipped.
        """
        paths = sorted({relative for relative in relatives if relative})
        if paths:
            await asyncio.to_thread(self.delete_files, paths)

    def delete_files(self, relatives: Iterable[str]) -> None:
        """Delete crops and remove the person folders that become empty.

        Paths that point outside the store folder, are missing or cannot be deleted are skipped. Only folders of
        uploaded crops are removed, because the analytics service keeps writing into the day folders of event crops.

        Args:
            relatives: Paths relative to the store folder.
        """
        people = (self.root / PEOPLE_FOLDER).resolve()
        folders = set()
        for relative in relatives:
            path = self.resolve(relative)
            if path is None:
                continue
            try:
                path.unlink(missing_ok=True)
            except OSError:
                continue
            if path.parent.parent == people:
                folders.add(path.parent)
        for folder in folders:
            try:
                folder.rmdir()
            except OSError:
                continue
