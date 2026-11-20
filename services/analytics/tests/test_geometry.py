from app.rules.geometry import iou, point_in_polygon, segments_intersect, side_of_line

SQUARE = ((0.2, 0.2), (0.8, 0.2), (0.8, 0.8), (0.2, 0.8))


def test_point_in_polygon():
    assert point_in_polygon((0.5, 0.5), SQUARE)
    assert not point_in_polygon((0.1, 0.5), SQUARE)
    assert not point_in_polygon((0.5, 0.9), SQUARE)
    assert not point_in_polygon((0.5, 0.5), ((0.0, 0.0), (1.0, 1.0)))


def test_side_of_left_to_right_line_is_positive_below():
    assert side_of_line((0.5, 0.7), (0.1, 0.5), (0.9, 0.5)) > 0
    assert side_of_line((0.5, 0.3), (0.1, 0.5), (0.9, 0.5)) < 0
    assert side_of_line((0.5, 0.5), (0.5, 0.5), (0.5, 0.5)) == 0


def test_segments_intersect():
    assert segments_intersect((0.5, 0.4), (0.5, 0.6), (0.1, 0.5), (0.9, 0.5))
    assert not segments_intersect((0.95, 0.4), (0.95, 0.6), (0.1, 0.5), (0.9, 0.5))
    assert segments_intersect((0.92, 0.4), (0.92, 0.6), (0.1, 0.5), (0.9, 0.5), tolerance=0.05)


def test_iou():
    assert iou((0, 0, 1, 1), (0, 0, 1, 1)) == 1
    assert iou((0, 0, 1, 1), (2, 2, 3, 3)) == 0
    assert round(iou((0, 0, 2, 1), (1, 0, 3, 1)), 3) == 0.333
