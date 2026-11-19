"""Layout of the camera wall: which camera lens goes into which grid cell."""

import math
from collections.abc import Iterable, Sequence
from dataclasses import dataclass

from app.models import Camera

PLAN_PASSES = 3


@dataclass(frozen=True)
class WallItem:
    """One picture of the wall, a whole camera or one lens of a multi-lens camera.

    Attributes:
        camera: Camera that supplies the picture.
        lens: Lens index within the camera, or None for a single-lens camera.
    """

    camera: Camera
    lens: int | None


@dataclass(frozen=True)
class WallCell:
    """One placed picture of the wall.

    Attributes:
        index: Column-major position of the cell in the grid.
        col: Column of the cell.
        row: Row of the cell.
        item: Picture shown in the cell.
    """

    index: int
    col: int
    row: int
    item: WallItem


@dataclass(frozen=True)
class WallPlan:
    """Grid and placed pictures of the wall.

    Attributes:
        cols: Number of columns.
        rows: Number of rows.
        cells: Placed pictures ordered by cell index.
    """

    cols: int
    rows: int
    cells: list[WallCell]

    def cell(self, index: int) -> WallCell | None:
        """Find a cell by its index.

        Args:
            index: Cell index.

        Returns:
            The cell, or None when no picture occupies that index.
        """
        return next((cell for cell in self.cells if cell.index == index), None)


def wall_items(cameras: Iterable[Camera]) -> list[WallItem]:
    """Expand cameras into wall pictures, one per lens for a multi-lens camera.

    Args:
        cameras: Cameras in wall order.

    Returns:
        The pictures in order.
    """
    items = []
    for camera in cameras:
        if camera.lenses > 1:
            items.extend(WallItem(camera, lens) for lens in range(camera.lenses))
        else:
            items.append(WallItem(camera, None))
    return items


def auto_grid(count: int) -> tuple[int, int]:
    """Choose the grid size for a number of pictures.

    Args:
        count: Number of pictures.

    Returns:
        The number of columns and the number of rows.
    """
    if count <= 1:
        return 1, 1
    if count == 2:
        return 2, 1
    if count <= 4:
        return 2, 2
    if count <= 6:
        return 3, 2
    if count <= 9:
        return 3, 3
    return 4, math.ceil(count / 4)


def arrange(items: Sequence[WallItem], line: int) -> list[WallItem | None]:
    """Lay pictures out in slots, keeping the lenses of one camera on the same line when they fit.

    Empty slots are inserted so that a camera's lenses start on a new line instead of being split across two.

    Args:
        items: Pictures in order.
        line: Number of slots in a line.

    Returns:
        The slots in order, with None for an empty slot.
    """
    slots: list[WallItem | None] = []
    for item in items:
        span = item.camera.lenses if item.lens == 0 else 1
        used = len(slots) % line
        if 1 < span <= line and used + span > line:
            while len(slots) % line:
                slots.append(None)
        slots.append(item)
    return slots


def wall_plan(cameras: Iterable[Camera]) -> WallPlan:
    """Plan the wall for a set of cameras.

    Chooses a grid, arranges the pictures and repeats with a larger grid while the empty slots left by the
    arrangement make them overflow it, for a limited number of passes. Pictures that still do not fit are dropped.

    Args:
        cameras: Cameras in wall order.

    Returns:
        The wall plan.
    """
    items = wall_items(cameras)
    count = len(items)
    cols, rows, by_column, slots = 1, 1, True, []
    for _ in range(PLAN_PASSES):
        cols, rows = auto_grid(count)
        by_column = cols >= rows
        slots = arrange(items, rows if by_column else cols)
        if len(slots) <= cols * rows:
            break
        count = len(slots)
    cells = []
    for position, item in enumerate(slots[: cols * rows]):
        if item is None:
            continue
        if by_column:
            col, row = divmod(position, rows)
        else:
            row, col = divmod(position, cols)
        cells.append(WallCell(index=col * rows + row, col=col, row=row, item=item))
    cells.sort(key=lambda cell: cell.index)
    return WallPlan(cols=cols, rows=rows, cells=cells)
