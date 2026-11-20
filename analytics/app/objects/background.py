"""Unclassed objects left and taken, found by background difference on keyframe thumbnails.

The detector knows only its classes, so a box or a parcel set down in a zone is invisible to the tracked rules.
This fallback keeps a background picture of the view, learned only where nothing stands out, and a short-term
picture. A patch that differs from the background, stays the same in the short term and is not explained by a
detection becomes an unclassed object once it stayed for the zone's left time, and raises object_left with the
label object. The background is not learned under it, so when the patch returns to that background the object is
taken. A large global brightness step, such as an infrared switch, resets both pictures. It is off by default;
a zone turns it on with background set, because slow shadows and lamps can look like objects.
"""

from __future__ import annotations

import uuid
from dataclasses import dataclass
from datetime import datetime, tzinfo

import numpy as np

from app.objects.zones import ObjectZone, object_zones
from app.rules.engine import Event, Update
from app.rules.geometry import iou, point_in_polygon
from app.rules.model import ArmMode, Box, EventKind

LABEL = "object"

FAST_RATE = 0.5
BACKGROUND_RATE = 0.05
DIFF_FLOOR = 20.0
NOISE_FACTOR = 4.0
STABLE_DIFF = 8.0

MIN_AREA = 20
BOX_OVERLAP = 0.3
RECORD_IOU = 0.3
GONE_SHARE = 0.5

SWITCH_STEP = 20.0
ABSORB_SECONDS = 6 * 3600.0
MAX_STEP_SECONDS = 30.0


def zone_mask(polygon: tuple[tuple[float, float], ...], height: int, width: int) -> np.ndarray:
    """Rasterise a zone polygon onto the thumbnail grid.

    Args:
        polygon: Vertices in normalized view coordinates.
        height: Thumbnail height.
        width: Thumbnail width.

    Returns:
        Boolean mask of the pixels whose centres are inside.
    """
    mask = np.zeros((height, width), dtype=bool)
    for row in range(height):
        for column in range(width):
            mask[row, column] = point_in_polygon(((column + 0.5) / width, (row + 0.5) / height), polygon)
    return mask


def components(mask: np.ndarray) -> list[np.ndarray]:
    """Split a boolean mask into its four-connected components.

    Args:
        mask: The mask.

    Returns:
        One array of (row, column) pixel coordinates per component.
    """
    seen = np.zeros_like(mask)
    height, width = mask.shape
    result = []
    for start in zip(*np.nonzero(mask), strict=True):
        if seen[start]:
            continue
        stack, pixels = [start], []
        seen[start] = True
        while stack:
            row, column = stack.pop()
            pixels.append((row, column))
            for next_row, next_column in ((row - 1, column), (row + 1, column), (row, column - 1), (row, column + 1)):
                if 0 <= next_row < height and 0 <= next_column < width:
                    if mask[next_row, next_column] and not seen[next_row, next_column]:
                        seen[next_row, next_column] = True
                        stack.append((next_row, next_column))
        result.append(np.array(pixels))
    return result


def pixel_box(pixels: np.ndarray, height: int, width: int) -> Box:
    """Return the normalized box around a set of thumbnail pixels.

    Args:
        pixels: (row, column) coordinates.
        height: Thumbnail height.
        width: Thumbnail width.

    Returns:
        The box.
    """
    rows, columns = pixels[:, 0], pixels[:, 1]
    return Box(columns.min() / width, rows.min() / height, (columns.max() + 1) / width, (rows.max() + 1) / height)


@dataclass
class Blob:
    """An unclassed object that raised left.

    Attributes:
        id: Object id of its events.
        zone: Zone id.
        box: Normalized box.
        pixels: Its thumbnail pixels.
        background: Background values under it when it raised left.
        since: Time it was first stable.
        gone: Consecutive samples it matched the background again.
    """

    id: int
    zone: str
    box: Box
    pixels: np.ndarray
    background: np.ndarray
    since: float
    gone: int = 0


class BackgroundWatch:
    """Unclassed objects left and taken in the background zones of one view.

    Attributes:
        view: View id.
        background: Learned background picture.
        fast: Short-term picture.
        ages: Seconds each pixel has stood out stably.
        last_at: Time of the previous sample.
        blobs: Unclassed objects that raised left.
        masks: Rasterised zone masks by zone id and polygon.
        next_id: Next object id.
    """

    def __init__(self, view: str):
        """Create the watch of a view.

        Args:
            view: View id.
        """
        self.view = view
        self.background: np.ndarray | None = None
        self.fast: np.ndarray | None = None
        self.ages: np.ndarray | None = None
        self.last_at: float | None = None
        self.blobs: list[Blob] = []
        self.masks: dict[tuple, np.ndarray] = {}
        self.next_id = 1

    def reset(self, image: np.ndarray) -> None:
        """Start the pictures from a sample and forget the objects.

        Args:
            image: The sample.
        """
        self.background = image.copy()
        self.fast = image.copy()
        self.ages = np.zeros_like(image)
        self.blobs = []

    def mask(self, rule: ObjectZone, shape: tuple[int, int]) -> np.ndarray:
        """Return the cached mask of a zone.

        Args:
            rule: The object zone.
            shape: Thumbnail height and width.

        Returns:
            The boolean mask.
        """
        key = (rule.id, rule.zone.polygon, shape)
        if key not in self.masks:
            self.masks[key] = zone_mask(rule.zone.polygon, *shape)
        return self.masks[key]

    def update(
        self,
        image: np.ndarray,
        at: float,
        zones: list[dict],
        arm: ArmMode,
        timezone: tzinfo,
        boxes: list[Box] | None = None,
    ) -> list[Update]:
        """Fold one keyframe band in and return the unclassed objects left and taken.

        Args:
            image: Grey band of the view as float32.
            at: Time of the keyframe.
            zones: The view's zone mappings.
            arm: Current arm mode.
            timezone: Time zone of the schedules.
            boxes: Boxes of the objects the detector currently sees, which explain a difference.

        Returns:
            Instant updates.
        """
        rules = [rule for rule in object_zones(zones) if rule.background]
        if not rules:
            self.background = None
            return []
        if self.background is None or self.background.shape != image.shape:
            self.reset(image)
            self.last_at = at
            return []
        step = min(MAX_STEP_SECONDS, max(0.0, at - (self.last_at or at)))
        self.last_at = at
        if abs(float(image.mean()) - float(self.fast.mean())) > SWITCH_STEP:
            self.reset(image)
            return []
        noise = float(np.median(np.abs(image - self.fast)))
        self.fast = (1 - FAST_RATE) * self.fast + FAST_RATE * image
        standing = np.abs(self.fast - self.background) > max(DIFF_FLOOR, NOISE_FACTOR * noise)
        stable = standing & (np.abs(image - self.fast) < STABLE_DIFF)
        self.ages = np.where(stable, self.ages + step, np.where(standing, self.ages, 0.0))
        frozen = np.zeros_like(standing)
        for blob in self.blobs:
            frozen[blob.pixels[:, 0], blob.pixels[:, 1]] = True
        learn = ~standing & ~frozen
        self.background[learn] = (1 - BACKGROUND_RATE) * self.background[learn] + BACKGROUND_RATE * image[learn]
        moment = datetime.fromtimestamp(at, timezone)
        updates = self.taken(rules, at, moment, arm)
        updates += self.left(rules, at, moment, arm, frozen, boxes or [])
        self.absorb(at)
        return updates

    def left(
        self,
        rules: list[ObjectZone],
        at: float,
        moment: datetime,
        arm: ArmMode,
        frozen: np.ndarray,
        boxes: list[Box],
    ) -> list[Update]:
        """Raise left for stable patches that stayed long enough.

        Args:
            rules: Background zones.
            at: Sample time.
            moment: Local sample time.
            arm: Current arm mode.
            frozen: Pixels already held by a blob.
            boxes: Boxes of detected objects.

        Returns:
            Instant updates.
        """
        updates = []
        height, width = self.ages.shape
        for rule in rules:
            if not rule.left_seconds or not rule.zone.schedule.active(moment):
                continue
            ready = (self.ages >= rule.left_seconds) & self.mask(rule, (height, width)) & ~frozen
            for pixels in components(ready):
                if len(pixels) < MIN_AREA:
                    continue
                box = pixel_box(pixels, height, width)
                if any(iou(box.as_tuple(), other.as_tuple()) > BOX_OVERLAP for other in boxes):
                    continue
                if any(iou(box.as_tuple(), blob.box.as_tuple()) > RECORD_IOU for blob in self.blobs):
                    continue
                blob = Blob(
                    id=self.next_id,
                    zone=rule.id,
                    box=box,
                    pixels=pixels,
                    background=self.background[pixels[:, 0], pixels[:, 1]].copy(),
                    since=at - float(self.ages[pixels[:, 0], pixels[:, 1]].max()),
                )
                self.next_id += 1
                self.blobs.append(blob)
                frozen[pixels[:, 0], pixels[:, 1]] = True
                updates.append(self.event(EventKind.OBJECT_LEFT, blob, rule, at, moment, arm))
        return updates

    def taken(self, rules: list[ObjectZone], at: float, moment: datetime, arm: ArmMode) -> list[Update]:
        """Raise taken for blobs whose patch matches the background again.

        Args:
            rules: Background zones.
            at: Sample time.
            moment: Local sample time.
            arm: Current arm mode.

        Returns:
            Instant updates.
        """
        updates = []
        by_id = {rule.id: rule for rule in rules}
        for blob in list(self.blobs):
            current = self.fast[blob.pixels[:, 0], blob.pixels[:, 1]]
            back = np.abs(current - blob.background) <= DIFF_FLOOR
            blob.gone = blob.gone + 1 if back.mean() >= GONE_SHARE else 0
            if blob.gone < 2:
                continue
            self.blobs.remove(blob)
            self.ages[blob.pixels[:, 0], blob.pixels[:, 1]] = 0.0
            rule = by_id.get(blob.zone)
            if rule is None or not rule.taken_seconds or at - blob.since < rule.taken_seconds:
                continue
            if rule.zone.schedule.active(moment):
                updates.append(self.event(EventKind.OBJECT_TAKEN, blob, rule, at, moment, arm))
        return updates

    def absorb(self, at: float) -> None:
        """Take blobs that stayed for hours into the background.

        Args:
            at: Current time.
        """
        for blob in list(self.blobs):
            if at - blob.since > ABSORB_SECONDS:
                self.background[blob.pixels[:, 0], blob.pixels[:, 1]] = self.fast[blob.pixels[:, 0], blob.pixels[:, 1]]
                self.ages[blob.pixels[:, 0], blob.pixels[:, 1]] = 0.0
                self.blobs.remove(blob)

    def event(self, kind: EventKind, blob: Blob, rule: ObjectZone, at: float, moment: datetime, arm: ArmMode) -> Update:
        """Build the instant event of a blob.

        Args:
            kind: object_left or object_taken.
            blob: The blob.
            rule: Its zone.
            at: Event time.
            moment: Local event time.
            arm: Current arm mode.

        Returns:
            The instant update.
        """
        event = Event(
            id=str(uuid.uuid4()),
            view=self.view,
            kind=kind,
            label=LABEL,
            started_at=at,
            ended_at=at,
            zone=rule.zone.id,
            zone_name=rule.zone.name,
            objects=[blob.id],
            boxes=[{"object": blob.id, "label": LABEL, "box": blob.box.rounded(), "at": round(at, 3)}],
            count=1,
            alert=rule.zone.alert.alerts(arm, LABEL, moment),
        )
        return Update("instant", event)
