"""Decoding of the SCRFD face detector's raw outputs into faces with five landmarks.

SCRFD predicts, for two anchors at every cell of three feature maps with strides 8, 16 and 32, a face score, the
distances from the anchor centre to the four box edges and the offsets of five landmarks: the eyes, the nose tip and
the mouth corners, in that order. Distances and offsets are in units of the stride.
"""

from __future__ import annotations

from dataclasses import dataclass

import numpy as np

STRIDES = (8, 16, 32)
ANCHORS = 2
NMS_IOU = 0.4


@dataclass(frozen=True)
class RawFace:
    """A face as the detector found it.

    Attributes:
        box: Left, top, right and bottom edges in pixels.
        score: Detection score from 0 to 1.
        landmarks: Five landmark points in pixels, shape 5 by 2.
    """

    box: tuple[float, float, float, float]
    score: float
    landmarks: np.ndarray

    @property
    def height(self) -> float:
        """float: Height of the box in pixels."""
        return self.box[3] - self.box[1]

    def mapped(self, scale: float, left: float, top: float) -> RawFace:
        """Map the face from detector input pixels to picture pixels.

        Args:
            scale: Detector input pixels per picture pixel.
            left: Picture x of the detector input's left edge.
            top: Picture y of the detector input's top edge.

        Returns:
            The face in picture pixels.
        """
        x1, y1, x2, y2 = self.box
        box = (left + x1 / scale, top + y1 / scale, left + x2 / scale, top + y2 / scale)
        landmarks = self.landmarks / scale + np.array([left, top], dtype=np.float32)
        return RawFace(box, self.score, landmarks)


def anchor_centres(size: int, stride: int) -> np.ndarray:
    """Return the anchor centres of one feature map, two per cell, row by row.

    Args:
        size: Square detector input size in pixels.
        stride: Stride of the feature map.

    Returns:
        Centres in pixels, shape anchors by 2.
    """
    cells = size // stride
    ys, xs = np.mgrid[:cells, :cells]
    centres = np.stack([xs, ys], axis=-1).reshape(-1, 2).astype(np.float32) * stride
    return np.repeat(centres, ANCHORS, axis=0)


def nms(boxes: np.ndarray, scores: np.ndarray, iou: float) -> list[int]:
    """Suppress boxes that overlap a higher scoring box.

    Args:
        boxes: Boxes as left, top, right and bottom, shape n by 4.
        scores: Their scores, shape n.
        iou: Overlap above which the lower scoring box is dropped.

    Returns:
        Indices of the kept boxes, highest score first.
    """
    order = list(np.argsort(-scores))
    areas = (boxes[:, 2] - boxes[:, 0]) * (boxes[:, 3] - boxes[:, 1])
    keep = []
    while order:
        best = order.pop(0)
        keep.append(int(best))
        if not order:
            break
        rest = np.array(order)
        left = np.maximum(boxes[best, 0], boxes[rest, 0])
        top = np.maximum(boxes[best, 1], boxes[rest, 1])
        right = np.minimum(boxes[best, 2], boxes[rest, 2])
        bottom = np.minimum(boxes[best, 3], boxes[rest, 3])
        overlap = np.clip(right - left, 0, None) * np.clip(bottom - top, 0, None)
        ratio = overlap / np.maximum(areas[best] + areas[rest] - overlap, 1e-6)
        order = [int(index) for index, value in zip(rest, ratio) if value <= iou]
    return keep


def decode(outputs: dict[str, np.ndarray], size: int, threshold: float, iou: float = NMS_IOU) -> list[RawFace]:
    """Turn the detector outputs of one picture into faces.

    Args:
        outputs: Arrays named score8, box8, kps8 and so on for each stride; a leading batch axis of one is allowed.
        size: Square detector input size in pixels.
        threshold: Lowest score kept.
        iou: Overlap threshold of the suppression step.

    Returns:
        Faces in detector input pixels, highest score first.
    """
    boxes, scores, points = [], [], []
    for stride in STRIDES:
        score = outputs[f"score{stride}"].reshape(-1)
        chosen = np.nonzero(score >= threshold)[0]
        if chosen.size == 0:
            continue
        centres = anchor_centres(size, stride)[chosen]
        distances = outputs[f"box{stride}"].reshape(-1, 4)[chosen] * stride
        offsets = outputs[f"kps{stride}"].reshape(-1, 10)[chosen] * stride
        boxes.append(np.concatenate([centres - distances[:, :2], centres + distances[:, 2:]], axis=1))
        points.append(offsets.reshape(-1, 5, 2) + centres[:, None, :])
        scores.append(score[chosen])
    if not boxes:
        return []
    all_boxes = np.concatenate(boxes)
    all_scores = np.concatenate(scores)
    all_points = np.concatenate(points)
    faces = []
    for index in nms(all_boxes, all_scores, iou):
        box = tuple(float(value) for value in all_boxes[index])
        faces.append(RawFace(box, float(all_scores[index]), all_points[index].astype(np.float32)))
    return faces


def letterbox_scale(width: float, height: float, size: int) -> float:
    """Return the scale that fits a picture into the square detector input without distortion.

    The picture is anchored at the top left corner and padded on the right or bottom, as nvinfer does with
    maintain-aspect-ratio on and symmetric padding off.

    Args:
        width: Picture width in pixels.
        height: Picture height in pixels.
        size: Square detector input size.

    Returns:
        Detector input pixels per picture pixel.
    """
    return min(size / max(width, 1.0), size / max(height, 1.0))
