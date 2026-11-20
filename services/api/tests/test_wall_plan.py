from uuid import uuid4

from app.models import Camera
from app.streaming.wall import arrange, auto_grid, wall_items, wall_plan


def camera(name: str, lenses: int = 1) -> Camera:
    return Camera(uuid=uuid4(), name=name, lenses=lenses, sub_path=None, ptz_enabled=False)


def layout(plan) -> list[tuple[int, int, int, str, int | None]]:
    return [(cell.index, cell.col, cell.row, cell.item.camera.name, cell.item.lens) for cell in plan.cells]


def test_auto_grid_matches_the_web_wall():
    assert [auto_grid(count) for count in (0, 1, 2, 3, 4, 5, 6, 7, 9, 10, 17)] == [
        (1, 1),
        (1, 1),
        (2, 1),
        (2, 2),
        (2, 2),
        (3, 2),
        (3, 2),
        (3, 3),
        (3, 3),
        (4, 3),
        (4, 5),
    ]


def test_wall_items_split_lenses():
    items = wall_items([camera("Gate"), camera("Yard", 2)])
    assert [(item.camera.name, item.lens) for item in items] == [("Gate", None), ("Yard", 0), ("Yard", 1)]


def test_arrange_keeps_lenses_in_one_column():
    items = wall_items([camera("A"), camera("Yard", 2)])
    slots = arrange(items, 2)
    assert [slot.camera.name if slot else None for slot in slots] == ["A", None, "Yard", "Yard"]


def test_home_wall_fills_three_columns_of_two():
    plan = wall_plan([camera("A"), camera("B"), camera("PTZ 1", 2), camera("PTZ 2", 2)])
    assert (plan.cols, plan.rows) == (3, 2)
    assert layout(plan) == [
        (0, 0, 0, "A", None),
        (1, 0, 1, "B", None),
        (2, 1, 0, "PTZ 1", 0),
        (3, 1, 1, "PTZ 1", 1),
        (4, 2, 0, "PTZ 2", 0),
        (5, 2, 1, "PTZ 2", 1),
    ]


def test_split_lenses_grow_the_grid_like_the_web_wall():
    plan = wall_plan([camera("A"), camera("PTZ 1", 2), camera("PTZ 2", 2), camera("B")])
    assert (plan.cols, plan.rows) == (3, 3)
    assert layout(plan) == [
        (0, 0, 0, "A", None),
        (1, 0, 1, "PTZ 1", 0),
        (2, 0, 2, "PTZ 1", 1),
        (3, 1, 0, "PTZ 2", 0),
        (4, 1, 1, "PTZ 2", 1),
        (5, 1, 2, "B", None),
    ]


def test_gaps_keep_their_slot_index():
    plan = wall_plan([camera("A"), camera("Yard", 2), camera("B"), camera("C")])
    assert (plan.cols, plan.rows) == (3, 2)
    assert [cell.index for cell in plan.cells] == [0, 2, 3, 4, 5]
    assert plan.cell(1) is None
    assert plan.cell(2).item.camera.name == "Yard"


def test_tall_grid_still_reports_column_major_indexes():
    plan = wall_plan([camera(f"C{number}") for number in range(17)])
    assert (plan.cols, plan.rows) == (4, 5)
    first = plan.cells[:3]
    assert [(cell.index, cell.col, cell.row, cell.item.camera.name) for cell in first] == [
        (0, 0, 0, "C0"),
        (1, 0, 1, "C4"),
        (2, 0, 2, "C8"),
    ]
    assert all(cell.index == cell.col * plan.rows + cell.row for cell in plan.cells)


def test_empty_and_single_walls():
    assert wall_plan([]).cells == []
    single = wall_plan([camera("Only")])
    assert (single.cols, single.rows) == (1, 1)
    assert layout(single) == [(0, 0, 0, "Only", None)]
