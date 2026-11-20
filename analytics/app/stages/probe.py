"""The person stages inside the DeepStream pipeline: appearance for re-identification and pose for falls.

The probe sits after the batch is converted to RGB. For each tracked person of a view that wants a stage, the gate
decides whether the stage takes the person this frame; only then is the rectangle around the person copied out of
the frame. Appearance crops are the person box, pose crops the box widened by a quarter to the pose model's aspect
ratio. Both models run in this process on the copied crops, batched per frame batch, and the results go to the
service as plain tuples: muxer pad, tracker id, time, normalized box, then the box height in pixels and the unit
appearance vector, or the 17 keypoints.
"""

from __future__ import annotations

import logging
import multiprocessing
import queue
import time
from dataclasses import dataclass
from pathlib import Path

import numpy as np

from app.falls.pose import region_for
from app.stages.crops import Region, canvas
from app.stages.gate import Pace, StageGate

logger = logging.getLogger(__name__)

UNTRACKED = 0xFFFFFFFFFFFFFFFF
APPEARANCE = "appearance"
POSE = "pose"
MIN_PERSON_WIDTH = 16
MIN_PERSON_HEIGHT = 48
PRUNE_SECONDS = 10.0


@dataclass(frozen=True)
class PersonStages:
    """What the person stages run on, passed from the service to the pipeline process.

    Attributes:
        appearance_pads: Muxer pads of the views that collect appearance.
        pose_pads: Muxer pads of the views that watch for falls.
        models_dir: Model layer mount.
        engines_dir: Writable engine cache.
        workspace_mb: Builder workspace limit for a first build.
        appearance_pace: Pace of appearance crops per track.
        pose_pace: Pace of pose crops per track.
    """

    appearance_pads: frozenset[int]
    pose_pads: frozenset[int]
    models_dir: str
    engines_dir: str
    workspace_mb: int = 512
    appearance_pace: Pace = Pace(1.0, 20)
    pose_pace: Pace = Pace(0.25)

    @property
    def active(self) -> bool:
        """bool: True when any view wants a person stage."""
        return bool(self.appearance_pads or self.pose_pads)


def person_crop(data: np.ndarray, origin: tuple[int, int], box: tuple[float, float, float, float]) -> np.ndarray:
    """Cut a person box out of a copied rectangle.

    Args:
        data: Copied frame rectangle, height by width by 3.
        origin: Frame position of the rectangle's top left corner.
        box: Left, top, right and bottom of the person in frame pixels.

    Returns:
        The person pixels, at least one pixel in each direction.
    """
    left = int(max(0, box[0] - origin[0]))
    top = int(max(0, box[1] - origin[1]))
    right = int(min(data.shape[1], max(left + 1, box[2] - origin[0])))
    bottom = int(min(data.shape[0], max(top + 1, box[3] - origin[1])))
    return data[top:bottom, left:right]


def collector(stages: PersonStages, outbox: multiprocessing.Queue, labels: dict[int, str], width: int, height: int):
    """Build the probe operator that runs the person stages.

    Args:
        stages: What the stages run on.
        outbox: Queue to the service process.
        labels: Shared detector class id to canonical label.
        width: Muxer frame width.
        height: Muxer frame height.

    Returns:
        A Service Maker buffer operator for a Probe on the element that outputs the RGB batch.
    """
    from pyservicemaker import BufferOperator

    from app.falls.pose import PoseEstimator
    from app.identity import frames
    from app.identity.runtime import Cuda, EngineRunner
    from app.reid.embedder import Embedder
    from app.stages import engines
    from app.stages.models import POSE as POSE_MODEL
    from app.stages.models import REID

    cuda = Cuda()
    models_dir, engines_dir = Path(stages.models_dir), Path(stages.engines_dir)
    embedder = None
    estimator = None
    if stages.appearance_pads:
        embedder = Embedder(EngineRunner(engines.ensure(REID, models_dir, engines_dir, stages.workspace_mb), cuda))
    if stages.pose_pads:
        runner = EngineRunner(engines.ensure(POSE_MODEL, models_dir, engines_dir, stages.workspace_mb), cuda)
        estimator = PoseEstimator(runner)
    paces = {}
    if embedder is not None:
        paces[APPEARANCE] = stages.appearance_pace
    if estimator is not None:
        paces[POSE] = stages.pose_pace
    gate = StageGate(paces)
    persons = {class_id for class_id, label in labels.items() if label == "person"}
    state = {"pruned": time.monotonic(), "dropped": 0}

    class PersonCollector(BufferOperator):
        """Collect appearance vectors and keypoints of tracked people."""

        def handle_buffer(self, buffer) -> bool:
            """Process one batch.

            Args:
                buffer: The RGB batch.

            Returns:
                True, so the buffer always flows on.
            """
            try:
                self.process(buffer)
            except Exception:
                logger.exception("The person stages failed on a batch")
            return True

        def process(self, buffer) -> None:
            """Crop, embed and pose the people of one batch and send the results.

            Args:
                buffer: The RGB batch.
            """
            appearance_crops, appearance_keys = [], []
            pose_crops, pose_keys = [], []
            frame_size = (width, height)
            for frame in buffer.batch_meta.frame_items:
                pad = int(frame.pad_index)
                wants_appearance = embedder is not None and pad in stages.appearance_pads
                wants_pose = estimator is not None and pad in stages.pose_pads
                if not (wants_appearance or wants_pose):
                    continue
                at = frame.ntp_timestamp / 1e9 if frame.ntp_timestamp else time.time()
                pixels = None
                for item in frame.object_items:
                    if item.object_id == UNTRACKED or item.class_id not in persons:
                        continue
                    rect = item.rect_params
                    if rect.width < MIN_PERSON_WIDTH or rect.height < MIN_PERSON_HEIGHT:
                        continue
                    track = int(item.object_id)
                    take_appearance = wants_appearance and gate.want(APPEARANCE, pad, track, at)
                    take_pose = wants_pose and gate.want(POSE, pad, track, at)
                    if not (take_appearance or take_pose):
                        continue
                    if pixels is None:
                        pixels = frames.describe(buffer.extract(frame.batch_id))
                        frame_size = (pixels.shape[1], pixels.shape[0])
                    box = (rect.left, rect.top, rect.left + rect.width, rect.top + rect.height)
                    region = region_for(box) if take_pose else Region(box[0], box[1], rect.width, rect.height)
                    left, top, copy_width, copy_height = region.clipped(*frame_size)
                    if copy_width < 2 or copy_height < 2:
                        continue
                    data = frames.read_region(pixels, left, top, copy_width, copy_height, cuda)
                    normalized = (box[0] / width, box[1] / height, box[2] / width, box[3] / height)
                    key = (pad, track, at, tuple(round(value, 4) for value in normalized))
                    if take_appearance:
                        appearance_crops.append(person_crop(data, (left, top), box))
                        appearance_keys.append((*key, float(rect.height)))
                    if take_pose:
                        pose_crops.append((canvas(data, region, (left, top)), region))
                        pose_keys.append(key)
            appearance, poses = [], []
            if appearance_crops:
                vectors = embedder.embed(appearance_crops)
                appearance = [(*key, vector) for key, vector in zip(appearance_keys, vectors)]
            if pose_crops:
                keypoints = estimator.estimate(pose_crops, frame_size)
                poses = [(*key, points) for key, points in zip(pose_keys, keypoints)]
            if appearance or poses:
                try:
                    outbox.put_nowait(("persons", time.time(), appearance, poses))
                except queue.Full:
                    state["dropped"] += 1
            now = time.monotonic()
            if now - state["pruned"] > PRUNE_SECONDS:
                state["pruned"] = now
                gate.prune(time.time())

    return PersonCollector()
