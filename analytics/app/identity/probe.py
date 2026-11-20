"""The face stage inside the DeepStream pipeline.

SCRFD runs as a secondary nvinfer on the person objects the shared detector found, after the tracker, so every face
belongs to a tracked person and inherits its track id without any matching. nvinfer crops each person box, scales
it into the detector input without distortion and attaches the raw output layers to the person object; the probe
decodes them, keeps the best face of each person, and only when that face is better than what its track already
sent copies the face's surroundings out of the frame, aligns it and sends it to the service. The batch is
converted to RGB after the face stage, because Service Maker extracts frames only in RGB.

Running SCRFD on person crops rather than on whole frames costs nothing on empty frames, gives a face in a 1080p
frame more of the detector input than a downscaled whole frame would, and makes the track id come for free.
"""

from __future__ import annotations

import logging
import multiprocessing
import queue
import time
from dataclasses import dataclass, field
from pathlib import Path

import numpy as np

from app.identity import align, frames, quality, scrfd
from app.identity.engines import detector_engine
from app.identity.settings import IdentitySettings

logger = logging.getLogger(__name__)

UNTRACKED = 0xFFFFFFFFFFFFFFFF
REGION_FACTOR = 2.4
MIN_PERSON_WIDTH = 32
MIN_PERSON_HEIGHT = 64
ELEMENT = "faces"
CONVERTER = "faces_rgb"
CAPS = "faces_rgbcaps"


@dataclass(frozen=True)
class Candidate:
    """A face worth embedding, sent from the pipeline process to the service.

    Attributes:
        pad: Muxer pad of the view, which the service maps to the view.
        track: Tracker id of the person.
        at: Wall clock time of the frame.
        box: Face box in normalised view coordinates.
        score: Detection score.
        quality: Combined quality from 0 to 1.
        size: Face box height in muxer pixels.
        frontal: Frontality signal.
        sharpness: Sharpness signal.
        grey: True when the face carries no colour, as in night vision.
        aligned: Aligned face, 112 by 112 by 3 RGB bytes.
        crop: Display crop, 160 by 160 by 3 RGB bytes.
    """

    pad: int
    track: int
    at: float
    box: tuple[float, float, float, float]
    score: float
    quality: float
    size: float
    frontal: float
    sharpness: float
    grey: bool
    aligned: bytes
    crop: bytes


@dataclass
class TrackGate:
    """What one track already sent.

    Attributes:
        best: Best quality sent so far.
        sent: Faces sent.
        last_sent: Time of the last face sent.
        last_seen: Time the track last showed a face.
    """

    best: float = 0.0
    sent: int = 0
    last_sent: float = 0.0
    last_seen: float = 0.0


@dataclass
class FaceGate:
    """Decides which faces of a track are worth copying, aligning and sending.

    The first usable face of a track is sent at once. After that a face is sent when it is clearly better than the
    best one sent, or, at a slower pace, when it is about as good, so the service sees a few different looks at the
    face to average. A track never sends more than a fixed number of faces.

    Attributes:
        max_sent: Most faces one track sends.
        improve: Factor by which a face must beat the best sent to go at once.
        interval: Seconds between two sends of one track.
        refresh: Seconds after which a face nearly as good as the best goes again.
        forget: Seconds without a face after which a track's record is dropped.
        tracks: Record per pad and track.
    """

    max_sent: int = 12
    improve: float = 1.15
    interval: float = 0.4
    refresh: float = 2.0
    forget: float = 30.0
    tracks: dict[tuple[int, int], TrackGate] = field(default_factory=dict)

    def want(self, pad: int, track: int, estimate: float, now: float) -> bool:
        """Tell whether a face is worth sending, before any pixel is copied.

        Args:
            pad: Muxer pad of the view.
            track: Tracker id.
            estimate: Quality estimate without sharpness.
            now: Frame time.

        Returns:
            True when the face should be processed and sent.
        """
        gate = self.tracks.setdefault((pad, track), TrackGate())
        gate.last_seen = now
        if estimate <= 0.0 or gate.sent >= self.max_sent:
            return False
        if gate.sent == 0:
            return True
        waited = now - gate.last_sent
        if waited < self.interval:
            return False
        return estimate >= gate.best * self.improve or (waited >= self.refresh and estimate >= gate.best * 0.85)

    def sent_face(self, pad: int, track: int, value: float, now: float) -> None:
        """Record a face that was sent.

        Args:
            pad: Muxer pad of the view.
            track: Tracker id.
            value: Its quality.
            now: Frame time.
        """
        gate = self.tracks.setdefault((pad, track), TrackGate())
        gate.sent += 1
        gate.best = max(gate.best, value)
        gate.last_sent = now

    def prune(self, now: float) -> None:
        """Drop the records of tracks not seen for a while.

        Args:
            now: Current time.
        """
        for key in [key for key, gate in self.tracks.items() if now - gate.last_seen > self.forget]:
            del self.tracks[key]


def infer_config(settings: IdentitySettings, engine_dir: Path, workspace_mb: int, person_ids: list[int]) -> Path:
    """Write the nvinfer configuration of the face detector and return its path.

    Args:
        settings: Face settings.
        engine_dir: Writable engine cache.
        workspace_mb: Builder workspace limit for a first build.
        person_ids: Class ids of the shared detector that mean person.

    Returns:
        Path of the configuration file.
    """
    engine = detector_engine(settings, engine_dir, workspace_mb)
    size = settings.detector_size
    lines = [
        "[property]",
        "gpu-id=0",
        f"model-engine-file={engine}",
        "batch-size=1",
        "network-mode=2",
        "network-type=100",
        "output-tensor-meta=1",
        "process-mode=2",
        "operate-on-gie-id=1",
        f"operate-on-class-ids={';'.join(str(value) for value in person_ids)}",
        "model-color-format=0",
        f"net-scale-factor={1 / 128}",
        "offsets=127.5;127.5;127.5",
        "maintain-aspect-ratio=1",
        "symmetric-padding=0",
        f"input-object-min-width={MIN_PERSON_WIDTH}",
        f"input-object-min-height={MIN_PERSON_HEIGHT}",
        "gie-unique-id=2",
        f"infer-dims=3;{size};{size}",
    ]
    path = engine_dir / "faces" / "nvinfer.txt"
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines) + "\n")
    return path


def add_elements(pipeline, config: Path) -> tuple[str, str]:
    """Add the face detector and the RGB conversion to a pipeline.

    Args:
        pipeline: The Service Maker pipeline.
        config: The face detector's nvinfer configuration.

    Returns:
        Names of the first and last added elements, to link after the tracker and before the sink; attach the
        probe from collector to the last.
    """
    pipeline.add("nvinfer", ELEMENT, {"config-file-path": str(config)})
    pipeline.add("nvvideoconvert", CONVERTER, {"output-buffers": 2})
    pipeline.add("capsfilter", CAPS, {"caps": "video/x-raw(memory:NVMM), format=RGB"})
    pipeline.link(ELEMENT, CONVERTER, CAPS)
    return ELEMENT, CAPS


def read_layers(layers: dict, threshold: float, cuda) -> dict[str, np.ndarray]:
    """Copy what decoding needs from the detector outputs of one person.

    The score layers are copied whole; the box and landmark rows only where a score passes the threshold, which
    keeps the copy small.

    Args:
        layers: Output layer name to device tensor description.
        threshold: Lowest score of interest.
        cuda: CUDA runtime.

    Returns:
        Arrays named like the layers, zero where nothing was copied.
    """
    outputs: dict[str, np.ndarray] = {}
    for stride in scrfd.STRIDES:
        scores = frames.read(layers[f"score{stride}"], cuda).reshape(-1)
        outputs[f"score{stride}"] = scores
        rows = np.nonzero(scores >= threshold)[0]
        for name, width in ((f"box{stride}", 4), (f"kps{stride}", 10)):
            array = np.zeros((scores.size, width), dtype=np.float32)
            if rows.size:
                array[rows] = frames.read_rows(layers[name], rows, cuda)
            outputs[name] = array
    return outputs


def region_around(face: scrfd.RawFace, width: int, height: int) -> tuple[int, int, int, int]:
    """Return the frame rectangle copied around a face for alignment and the display crop.

    Args:
        face: The face in frame pixels.
        width: Frame width.
        height: Frame height.

    Returns:
        Left, top, width and height of the rectangle, inside the frame.
    """
    x1, y1, x2, y2 = face.box
    side = max(x2 - x1, y2 - y1) * REGION_FACTOR
    left = int(max(0, (x1 + x2) / 2 - side / 2))
    top = int(max(0, (y1 + y2) / 2 - side / 2))
    right = int(min(width, (x1 + x2) / 2 + side / 2))
    bottom = int(min(height, (y1 + y2) / 2 + side / 2))
    return left, top, max(2, right - left), max(2, bottom - top)


def candidate_from(
    face: scrfd.RawFace,
    region: np.ndarray,
    origin: tuple[int, int],
    frame_size: tuple[int, int],
    pad: int,
    track: int,
    at: float,
    settings: IdentitySettings,
) -> Candidate:
    """Align a face, judge its quality and package it.

    Args:
        face: The face in frame pixels.
        region: RGB pixels of the rectangle around it.
        origin: Frame position of the rectangle's top left corner.
        frame_size: Frame width and height, for normalising the box.
        pad: Muxer pad of the view.
        track: Tracker id.
        at: Frame time.
        settings: Face settings.

    Returns:
        The candidate.
    """
    left, top = origin
    shift = np.array([left, top], dtype=np.float32)
    aligned = align.align(region, face.landmarks - shift)
    x1, y1, x2, y2 = face.box
    crop = align.crop(region, (x1 - left, y1 - top, x2 - left, y2 - top))
    signals = quality.assess(face.height, face.landmarks, aligned, face.score, settings.min_face)
    width, height = frame_size
    return Candidate(
        pad=pad,
        track=track,
        at=at,
        box=(x1 / width, y1 / height, x2 / width, y2 / height),
        score=round(face.score, 4),
        quality=round(signals.value, 4),
        size=round(face.height, 1),
        frontal=round(signals.frontal, 3),
        sharpness=round(signals.sharpness, 3),
        grey=quality.is_grey(aligned),
        aligned=aligned.tobytes(),
        crop=crop.tobytes(),
    )


def best_face(faces: list[scrfd.RawFace], person: tuple[float, float, float, float]) -> scrfd.RawFace | None:
    """Pick the face that belongs to a person box.

    A person crop can show part of someone else's face near its edge, so the face must sit in the top part of the
    box, and the highest scoring such face wins.

    Args:
        faces: Faces in frame pixels.
        person: Person box as left, top, width and height in frame pixels.

    Returns:
        The face, or None.
    """
    left, top, width, height = person
    for face in faces:
        centre_x = (face.box[0] + face.box[2]) / 2
        centre_y = (face.box[1] + face.box[3]) / 2
        if left <= centre_x <= left + width and top <= centre_y <= top + height * 0.6:
            return face
    return None


def collector(pads: set[int], settings: IdentitySettings, outbox: multiprocessing.Queue, width: int, height: int):
    """Build the probe operator that turns detector outputs into face candidates.

    Args:
        pads: Muxer pads of the views with faces enabled.
        settings: Face settings.
        outbox: Queue to the service process.
        width: Muxer frame width.
        height: Muxer frame height.

    Returns:
        A Service Maker buffer operator for a Probe on the last face stage element.
    """
    from pyservicemaker import BufferOperator

    from app.identity.runtime import Cuda

    cuda = Cuda()
    gate = FaceGate()
    detect_threshold = min(settings.min_score, 0.5)
    stats = {"pruned": time.monotonic(), "dropped": 0}

    class FaceCollector(BufferOperator):
        """Collect the best faces of tracked people on face views."""

        def handle_buffer(self, buffer) -> bool:
            """Process one batch.

            Args:
                buffer: The batch after the face detector and the RGB conversion.

            Returns:
                True, so the buffer always flows on.
            """
            try:
                self.process(buffer)
            except Exception:
                logger.exception("The face probe failed on a batch")
            return True

        def process(self, buffer) -> None:
            """Find, gate, align and send faces of one batch.

            Args:
                buffer: The batch.
            """
            candidates = []
            for frame in buffer.batch_meta.frame_items:
                pad = int(frame.pad_index)
                if pad not in pads:
                    continue
                at = frame.ntp_timestamp / 1e9 if frame.ntp_timestamp else time.time()
                pixels = None
                for item in frame.object_items:
                    if item.object_id == UNTRACKED:
                        continue
                    tensors = list(item.tensor_items)
                    if not tensors:
                        continue
                    raw = tensors[0].as_tensor_output().get_layers()
                    layers = {name: frames.describe(tensor) for name, tensor in raw.items()}
                    rect = item.rect_params
                    scale = scrfd.letterbox_scale(rect.width, rect.height, settings.detector_size)
                    found = scrfd.decode(
                        read_layers(layers, detect_threshold, cuda), settings.detector_size, detect_threshold
                    )
                    mapped = [face.mapped(scale, rect.left, rect.top) for face in found]
                    face = best_face(mapped, (rect.left, rect.top, rect.width, rect.height))
                    if face is None or face.score < settings.min_score or face.height < settings.min_face:
                        continue
                    track = int(item.object_id)
                    estimate = quality.combine(
                        quality.size_signal(face.height, settings.min_face),
                        quality.frontality(face.landmarks),
                        1.0,
                        face.score,
                    )
                    if not gate.want(pad, track, estimate, at):
                        continue
                    if pixels is None:
                        pixels = frames.describe(buffer.extract(frame.batch_id))
                    left, top, region_width, region_height = region_around(face, pixels.shape[1], pixels.shape[0])
                    region = frames.read_region(pixels, left, top, region_width, region_height, cuda)
                    candidate = candidate_from(face, region, (left, top), (width, height), pad, track, at, settings)
                    if candidate.quality <= 0.0:
                        continue
                    gate.sent_face(pad, track, candidate.quality, at)
                    candidates.append(candidate)
            if candidates:
                try:
                    outbox.put_nowait(("faces", time.time(), candidates))
                except queue.Full:
                    stats["dropped"] += 1
            now = time.monotonic()
            if now - stats["pruned"] > 10:
                stats["pruned"] = now
                gate.prune(time.time())

    return FaceCollector()
