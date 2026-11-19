import asyncio
import logging
import os
from datetime import datetime
from pathlib import Path
from uuid import UUID

import httpx

logger = logging.getLogger(__name__)

FRAME_PATH = "/api/frame.jpeg"
FRAME_TIMEOUT_SECONDS = 12.0
THUMBNAIL_WIDTH = 320
MAX_FRAME_BYTES = 8 * 1024 * 1024
JPEG_MAGIC = b"\xff\xd8"


class SnapshotStore:
    def __init__(self, root: str, go2rtc_url: str):
        self.root = Path(root)
        self.go2rtc_url = go2rtc_url.rstrip("/")

    def resolve(self, relative: str | None) -> Path | None:
        if not relative:
            return None
        path = (self.root / relative).resolve()
        root = self.root.resolve()
        if root not in path.parents:
            return None
        return path

    async def fetch(self, http: httpx.AsyncClient, stream: str, width: int | None) -> bytes | None:
        params = [("src", stream)]
        if width:
            params.append(("width", str(width)))
        try:
            response = await http.get(f"{self.go2rtc_url}{FRAME_PATH}", params=params)
        except httpx.HTTPError as exc:
            logger.info("Snapshot of %s failed: %s", stream, type(exc).__name__)
            return None
        content = response.content
        if response.status_code != 200 or len(content) > MAX_FRAME_BYTES or not content.startswith(JPEG_MAGIC):
            logger.info("Snapshot of %s answered HTTP %s", stream, response.status_code)
            return None
        return content

    async def capture(self, stream: str, event_uuid: UUID, at: datetime) -> tuple[str | None, str | None]:
        folder = Path(f"{at:%Y}") / f"{at:%m}" / f"{at:%d}"
        async with httpx.AsyncClient(timeout=FRAME_TIMEOUT_SECONDS) as http:
            full, thumbnail = await asyncio.gather(
                self.fetch(http, stream, None), self.fetch(http, stream, THUMBNAIL_WIDTH)
            )
        snapshot_path = await self.write(folder / f"{event_uuid}.jpg", full)
        thumbnail_path = await self.write(folder / f"{event_uuid}.thumb.jpg", thumbnail)
        return snapshot_path, thumbnail_path

    async def write(self, relative: Path, content: bytes | None) -> str | None:
        if not content:
            return None
        target = self.root / relative
        try:
            await asyncio.to_thread(self.write_file, target, content)
        except OSError as exc:
            logger.warning("Writing the snapshot %s failed: %s", relative, exc)
            return None
        return relative.as_posix()

    def write_file(self, target: Path, content: bytes) -> None:
        target.parent.mkdir(parents=True, exist_ok=True)
        temporary = target.with_suffix(".part")
        temporary.write_bytes(content)
        os.replace(temporary, target)

    async def remove(self, relatives: list[str]) -> None:
        if relatives:
            await asyncio.to_thread(self.remove_files, relatives)

    def remove_files(self, relatives: list[str]) -> None:
        folders = set()
        for relative in relatives:
            path = self.resolve(relative)
            if path is None:
                continue
            try:
                path.unlink(missing_ok=True)
            except OSError:
                continue
            folders.add(path.parent)
        root = self.root.resolve()
        for folder in sorted(folders, key=lambda item: len(item.parts), reverse=True):
            current = folder
            while current != root and root in current.parents:
                try:
                    current.rmdir()
                except OSError:
                    break
                current = current.parent
