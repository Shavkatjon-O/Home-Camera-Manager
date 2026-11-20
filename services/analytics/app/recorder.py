"""Rolling recording buffer per camera and the event clips and snapshots cut from it.

One ffmpeg process per camera copies the original stream into short MPEG-TS segments without re-encoding, named
after the second they start. Packets are stamped with their arrival time, because the bridged V380 streams start
without timestamps, which the segment muxer refuses, and arrival time also lines the segments up with the frames
the pipeline analyses. The same process decodes only the keyframes, scaled to a small grey picture, for the
tamper watch. When an event needs a clip, the segments around it are joined, trimmed to the event with a lead-in and
a tail, cropped to the event's lens and encoded once to H.264 MP4, which every browser plays. Encoding uses NVENC
when it works and libx264 otherwise, so a host without a hardware encoder, such as a Jetson Orin Nano, still makes
clips.
"""

from __future__ import annotations

import collections
import logging
import os
import subprocess
import tempfile
import threading
import time
from collections.abc import Callable
from dataclasses import dataclass
from pathlib import Path

from app.sources import redact

logger = logging.getLogger(__name__)

SEGMENT_SECONDS = 2
THUMB_WIDTH = 160
THUMB_HEIGHT = 90
RESTART_DELAYS = (2, 5, 10, 30, 60)
SEGMENT_STALL_SECONDS = 20
WATCH_SECONDS = 0.2
CLIP_TIMEOUT_SECONDS = 180
CLIP_WIDTH = 1920
SNAPSHOT_THUMB_WIDTH = 320
SNAPSHOT_FALLBACK_SECONDS = 10.0


@dataclass(frozen=True)
class Segment:
    """One buffered segment.

    Attributes:
        path: The file.
        start: Wall clock time it starts at.
        end: Wall clock time it ends at, the next segment's start or the file's last write.
    """

    path: Path
    start: float
    end: float


def list_segments(folder: Path, seen: dict[str, float] | None = None) -> list[Segment]:
    """List a camera's buffered segments in time order.

    Args:
        folder: The camera's buffer folder.
        seen: Times the recorder saw each segment file appear, more precise than the whole second in its name.

    Returns:
        The segments; the last one may still be growing.
    """
    starts = []
    for path in folder.glob("*.ts"):
        try:
            named = int(path.stem)
        except ValueError:
            continue
        starts.append(((seen or {}).get(path.name, float(named)), path))
    starts.sort()
    segments = []
    for number, (start, path) in enumerate(starts):
        if number + 1 < len(starts):
            end = float(starts[number + 1][0])
        else:
            try:
                end = path.stat().st_mtime
            except FileNotFoundError:
                continue
        segments.append(Segment(path, start, max(end, start)))
    return segments


def covering(segments: list[Segment], start: float, end: float) -> list[Segment]:
    """Pick the consecutive segments that cover a time range.

    Args:
        segments: Segments in time order.
        start: Range start.
        end: Range end.

    Returns:
        The segments overlapping the range.
    """
    return [segment for segment in segments if segment.end > start and segment.start < end]


def crop_filter(lens: int, lenses: int) -> list[str]:
    """Return the ffmpeg filters that cut one lens band out of a stacked frame.

    Args:
        lens: Lens band counted from 1 at the top, 0 for the whole frame.
        lenses: Number of bands in the frame.

    Returns:
        Filter expressions, empty for the whole frame.
    """
    if not lens or lenses <= 1:
        return []
    return [f"crop=iw:ih/{lenses}:0:ih*{lens - 1}/{lenses}"]


class CameraRecorder:
    """Keeps one camera's rolling buffer and feeds its keyframe thumbnails to a callback.

    Attributes:
        camera: Camera id.
        uri: Stream URI with credentials.
        lenses: Lens bands in the frame.
        folder: Buffer folder of this camera.
        keep_seconds: Seconds of segments kept.
        on_keyframe: Called with the camera id, the time and the grey thumbnail bytes of each keyframe.
        errors: Recent ffmpeg error lines.
        restarts: How often ffmpeg was restarted.
        last_keyframe: Time of the latest keyframe.
        started: Time the current ffmpeg process started.
        seen: Time each segment file appeared, found by polling the folder five times a second.
    """

    def __init__(
        self,
        camera: str,
        uri: str,
        lenses: int,
        folder: Path,
        keep_seconds: float,
        on_keyframe: Callable[[str, float, bytes], None],
    ):
        """Prepare a recorder; call start to run it.

        Args:
            camera: Camera id.
            uri: Stream URI with credentials.
            lenses: Lens bands in the frame.
            folder: Buffer folder of this camera.
            keep_seconds: Seconds of segments kept.
            on_keyframe: Keyframe thumbnail callback.
        """
        self.camera = camera
        self.uri = uri
        self.lenses = max(1, lenses)
        self.folder = folder
        self.keep_seconds = keep_seconds
        self.on_keyframe = on_keyframe
        self.errors: collections.deque[str] = collections.deque(maxlen=20)
        self.restarts = 0
        self.last_keyframe: float | None = None
        self.started: float | None = None
        self.seen: dict[str, float] = {}
        self.process: subprocess.Popen | None = None
        self.stopping = threading.Event()
        self.thread: threading.Thread | None = None

    @property
    def thumb_size(self) -> tuple[int, int]:
        """tuple[int, int]: Width and height of the keyframe thumbnail, one 16 by 9 band per lens."""
        return THUMB_WIDTH, THUMB_HEIGHT * self.lenses

    def command(self) -> list[str]:
        """Return the ffmpeg command line.

        Returns:
            The arguments.
        """
        width, height = self.thumb_size
        return [
            "ffmpeg",
            "-nostdin",
            "-hide_banner",
            "-loglevel",
            "error",
            "-rtsp_transport",
            "tcp",
            "-timeout",
            "15000000",
            "-fflags",
            "+genpts",
            "-use_wallclock_as_timestamps",
            "1",
            "-threads",
            "2",
            "-skip_frame",
            "nokey",
            "-i",
            self.uri,
            "-map",
            "0:v:0",
            "-c:v",
            "copy",
            "-f",
            "segment",
            "-segment_time",
            str(SEGMENT_SECONDS),
            "-segment_format",
            "mpegts",
            "-reset_timestamps",
            "1",
            "-strftime",
            "1",
            str(self.folder / "%s.ts"),
            "-map",
            "0:v:0",
            "-vf",
            f"scale={width}:{height}:flags=area,format=gray",
            "-fps_mode",
            "passthrough",
            "-f",
            "rawvideo",
            "pipe:1",
        ]

    def start(self) -> None:
        """Start recording in a background thread."""
        self.folder.mkdir(parents=True, exist_ok=True)
        self.thread = threading.Thread(target=self.loop, name=f"recorder-{self.camera[:8]}", daemon=True)
        self.thread.start()
        threading.Thread(target=self.watch, name=f"segments-{self.camera[:8]}", daemon=True).start()

    def watch(self) -> None:
        """Note when each segment file appears.

        Segment names carry only the whole second, which would place an event's snapshot up to a second off.
        """
        while not self.stopping.is_set():
            now = time.time()
            try:
                names = {path.name for path in self.folder.glob("*.ts")}
            except OSError:
                names = set()
            for name in names - self.seen.keys():
                self.seen[name] = now
            for name in self.seen.keys() - names:
                del self.seen[name]
            self.stopping.wait(WATCH_SECONDS)

    def stop(self) -> None:
        """Stop recording and wait for ffmpeg to exit."""
        self.stopping.set()
        if self.process and self.process.poll() is None:
            self.process.terminate()
            try:
                self.process.wait(5)
            except subprocess.TimeoutExpired:
                self.process.kill()
        if self.thread:
            self.thread.join(10)

    def loop(self) -> None:
        """Run ffmpeg, restarting it with a growing delay whenever it exits."""
        failures = 0
        while not self.stopping.is_set():
            started = time.monotonic()
            self.run_once()
            if self.stopping.is_set():
                return
            failures = 0 if time.monotonic() - started > 60 else failures + 1
            self.restarts += 1
            delay = RESTART_DELAYS[min(failures, len(RESTART_DELAYS) - 1)]
            self.stopping.wait(delay)

    def run_once(self) -> None:
        """Run one ffmpeg process until it exits, reading thumbnails and errors."""
        width, height = self.thumb_size
        size = width * height
        self.started = time.time()
        self.process = subprocess.Popen(self.command(), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        errors = threading.Thread(target=self.read_errors, args=(self.process,), daemon=True)
        errors.start()
        stdout = self.process.stdout
        while True:
            data = stdout.read(size)
            if not data or len(data) < size:
                break
            self.last_keyframe = time.time()
            try:
                self.on_keyframe(self.camera, self.last_keyframe, data)
            except Exception:
                logger.exception("Keyframe handling of camera %s failed", self.camera)
        self.process.wait()
        errors.join(2)

    def read_errors(self, process: subprocess.Popen) -> None:
        """Keep the last ffmpeg error lines.

        Args:
            process: The running ffmpeg.
        """
        for line in process.stderr:
            text = redact(line.decode(errors="replace").strip())
            if text:
                self.errors.append(f"{time.strftime('%H:%M:%S')} {text}")

    def check(self) -> None:
        """Restart ffmpeg when it runs but its segments stopped growing.

        A stream that starts without timestamps can make the segment output fail while the thumbnail output keeps
        the process alive, so liveness is judged by the segments.
        """
        process = self.process
        if process is None or process.poll() is not None or self.started is None:
            return
        if time.time() - self.started < SEGMENT_STALL_SECONDS:
            return
        newest = max((segment.end for segment in list_segments(self.folder, self.seen)), default=0.0)
        if time.time() - newest > SEGMENT_STALL_SECONDS:
            self.errors.append(f"{time.strftime('%H:%M:%S')} segments stopped growing, restarting ffmpeg")
            process.terminate()

    def prune(self, needed_from: float | None) -> None:
        """Delete segments older than the buffer length unless a pending clip still needs them.

        Args:
            needed_from: Start of the earliest pending clip of this camera, or None.
        """
        cutoff = time.time() - self.keep_seconds
        if needed_from is not None:
            cutoff = min(cutoff, needed_from - SEGMENT_SECONDS * 2)
        for segment in list_segments(self.folder, self.seen)[:-1]:
            if segment.end < cutoff:
                segment.path.unlink(missing_ok=True)

    @property
    def running(self) -> bool:
        """bool: True while ffmpeg runs and delivered a keyframe in the last 30 seconds."""
        alive = self.process is not None and self.process.poll() is None
        return alive and self.last_keyframe is not None and time.time() - self.last_keyframe < 30


class ClipMaker:
    """Cuts snapshots and clips for events out of the buffered segments.

    Attributes:
        encoder: Preferred encoder: auto, h264_nvenc, libx264 or copy.
        working: Encoder that worked last, tried first next time.
    """

    def __init__(self, encoder: str):
        """Create the clip maker.

        Args:
            encoder: Preferred encoder: auto, h264_nvenc, libx264 or copy.
        """
        self.encoder = encoder
        self.working: str | None = None

    def encoders(self) -> list[str]:
        """Return the encoders to try in order.

        Returns:
            Encoder names.
        """
        if self.encoder == "auto":
            order = ["h264_nvenc", "libx264"]
            if self.working in order:
                order.remove(self.working)
                order.insert(0, self.working)
            return order
        return [self.encoder]

    @staticmethod
    def concat_list(segments: list[Segment]) -> str:
        """Write an ffmpeg concat list for segments.

        Args:
            segments: The segments in order.

        Returns:
            Path of the temporary list file; the caller deletes it.
        """
        handle, name = tempfile.mkstemp(suffix=".txt", prefix="concat-")
        with os.fdopen(handle, "w") as listing:
            for segment in segments:
                listing.write(f"file '{segment.path}'\n")
        return name

    @staticmethod
    def snapshot_candidates(segments: list[Segment], at: float) -> list[tuple[Segment, float]]:
        """Choose where in the buffer to take the picture of a moment.

        The segment start times are estimates, so a moment near the end of a segment can lie past its last frame;
        the first frame of the next segment is then the nearest picture. A moment before the oldest buffered
        segment, as after a restart, falls back to the first frame that follows it within a few seconds.

        Args:
            segments: Buffered segments in time order.
            at: Wall clock time of the picture.

        Returns:
            Segment and offset pairs to try in order.

        Raises:
            FileNotFoundError: No buffered video covers the time or follows it closely.
        """
        found = covering(segments, at - 0.01, at + 0.01)
        if found:
            index = segments.index(found[0])
            candidates = [(found[0], max(0.0, at - found[0].start))]
            if index + 1 < len(segments):
                candidates.append((segments[index + 1], 0.0))
            return candidates
        following = [segment for segment in segments if 0.0 <= segment.start - at <= SNAPSHOT_FALLBACK_SECONDS]
        if not following:
            raise FileNotFoundError("No buffered video covers the time of the snapshot")
        return [(following[0], 0.0)]

    def snapshot(
        self,
        folder: Path,
        at: float,
        lens: int,
        lenses: int,
        target: Path,
        thumbnail: Path | None = None,
        seen: dict[str, float] | None = None,
    ) -> bool:
        """Write a JPEG of the frame at a time, or of the nearest buffered frame after it.

        Args:
            folder: Camera buffer folder.
            at: Wall clock time of the frame.
            lens: Lens band, 0 for the whole frame.
            lenses: Bands in the frame.
            target: JPEG to write.
            thumbnail: Optional smaller JPEG to write as well.
            seen: Times the segment files appeared.

        Returns:
            True when the snapshot was written; False when the buffer does not reach the time yet or no frame
            could be decoded.

        Raises:
            FileNotFoundError: The buffer no longer holds the time.
        """
        listed = list_segments(folder, seen)
        if not listed or listed[-1].end < at + 0.5:
            return False
        filters = crop_filter(lens, lenses)
        target.parent.mkdir(parents=True, exist_ok=True)
        for segment, offset in self.snapshot_candidates(listed, at):
            command = ["ffmpeg", "-nostdin", "-hide_banner", "-loglevel", "error", "-y", "-i", str(segment.path)]
            command += ["-ss", f"{offset:.3f}", "-frames:v", "1"]
            command += ["-vf", ",".join(filters + [f"scale='min({CLIP_WIDTH},iw)':-2"]), "-q:v", "3", str(target)]
            if thumbnail is not None:
                command += ["-ss", f"{offset:.3f}", "-frames:v", "1"]
                command += ["-vf", ",".join(filters + [f"scale={SNAPSHOT_THUMB_WIDTH}:-2"]), "-q:v", "5"]
                command += [str(thumbnail)]
            target.unlink(missing_ok=True)
            result = subprocess.run(command, capture_output=True, timeout=60, check=False)
            if result.returncode == 0 and target.is_file():
                return True
        return False

    def clip(
        self,
        folder: Path,
        start: float,
        end: float,
        lens: int,
        lenses: int,
        target: Path,
        seen: dict[str, float] | None = None,
    ) -> bool:
        """Write an MP4 clip of a time range.

        Args:
            folder: Camera buffer folder.
            start: Clip start, wall clock.
            end: Clip end, wall clock.
            lens: Lens band, 0 for the whole frame.
            lenses: Bands in the frame.
            target: MP4 to write.
            seen: Times the segment files appeared.

        Returns:
            True when the clip was written.
        """
        segments = covering(list_segments(folder, seen), start, end)
        if not segments:
            logger.warning("No buffered video covers the clip %s", target.name)
            return False
        listing = self.concat_list(segments)
        target.parent.mkdir(parents=True, exist_ok=True)
        temporary = target.with_suffix(".part.mp4")
        offset = max(0.0, start - segments[0].start)
        duration = max(1.0, end - max(start, segments[0].start))
        try:
            for encoder in self.encoders():
                command = ["ffmpeg", "-nostdin", "-hide_banner", "-loglevel", "error", "-y"]
                command += [
                    "-f",
                    "concat",
                    "-safe",
                    "0",
                    "-i",
                    listing,
                    "-ss",
                    f"{offset:.3f}",
                    "-t",
                    f"{duration:.3f}",
                ]
                command += ["-map", "0:v:0", "-an"]
                if encoder == "copy":
                    command += ["-c:v", "copy", "-tag:v", "hvc1"]
                else:
                    filters = crop_filter(lens, lenses) + [f"scale='min({CLIP_WIDTH},iw)':-2", "format=yuv420p"]
                    command += ["-vf", ",".join(filters), "-c:v", encoder]
                    if encoder == "h264_nvenc":
                        command += ["-preset", "p4", "-rc", "vbr", "-cq", "28", "-b:v", "0"]
                    else:
                        command += ["-preset", "veryfast", "-crf", "26"]
                    command += ["-profile:v", "high"]
                command += ["-movflags", "+faststart", "-f", "mp4", str(temporary)]
                try:
                    result = subprocess.run(command, capture_output=True, timeout=CLIP_TIMEOUT_SECONDS, check=False)
                except subprocess.TimeoutExpired:
                    logger.warning("Encoding %s with %s timed out", target.name, encoder)
                    continue
                if result.returncode == 0 and temporary.is_file() and temporary.stat().st_size > 0:
                    os.replace(temporary, target)
                    self.working = encoder
                    return True
                logger.warning(
                    "Encoding %s with %s failed: %s", target.name, encoder, redact(result.stderr.decode()[-300:])
                )
            return False
        finally:
            os.unlink(listing)
            temporary.unlink(missing_ok=True)


def latest_frame(folder: Path, lens: int, lenses: int) -> bytes | None:
    """Return a JPEG of the newest keyframe in a camera's buffer, cropped to a lens.

    Args:
        folder: Camera buffer folder.
        lens: Lens band, 0 for the whole frame.
        lenses: Bands in the frame.

    Returns:
        The JPEG bytes, or None when the buffer has no usable segment.
    """
    segments = list_segments(folder)
    for segment in reversed(segments[-3:]):
        filters = crop_filter(lens, lenses) + [f"scale='min({CLIP_WIDTH},iw)':-2"]
        command = ["ffmpeg", "-nostdin", "-hide_banner", "-loglevel", "error", "-i", str(segment.path)]
        command += ["-frames:v", "1", "-vf", ",".join(filters), "-q:v", "3", "-f", "image2pipe", "-c:v", "mjpeg"]
        command += ["pipe:1"]
        try:
            result = subprocess.run(command, capture_output=True, timeout=30, check=False)
        except (OSError, subprocess.SubprocessError):
            continue
        if result.returncode == 0 and result.stdout.startswith(b"\xff\xd8"):
            return result.stdout
    return None
