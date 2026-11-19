import math
from collections.abc import Iterable, Sequence
from dataclasses import dataclass

from app.models import Camera

PLAN_PASSES = 3


@dataclass(frozen=True)
class WallItem:
    camera: Camera
    lens: int | None


@dataclass(frozen=True)
class WallCell:
    index: int
    col: int
    row: int
    item: WallItem


@dataclass(frozen=True)
class WallPlan:
    cols: int
    rows: int
    cells: list[WallCell]

    def cell(self, index: int) -> WallCell | None:
        return next((cell for cell in self.cells if cell.index == index), None)


def wall_items(cameras: Iterable[Camera]) -> list[WallItem]:
    items = []
    for camera in cameras:
        if camera.lenses > 1:
            items.extend(WallItem(camera, lens) for lens in range(camera.lenses))
        else:
            items.append(WallItem(camera, None))
    return items


def auto_grid(count: int) -> tuple[int, int]:
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
