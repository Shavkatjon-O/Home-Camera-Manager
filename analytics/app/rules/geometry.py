"""Plane geometry on normalized view coordinates, where x grows to the right and y grows downwards."""

from __future__ import annotations

import math

Point = tuple[float, float]


def point_in_polygon(point: Point, polygon: tuple[Point, ...]) -> bool:
    """Tell whether a point lies inside a polygon by ray casting.

    Args:
        point: The point to test.
        polygon: Polygon vertices in order, without repeating the first one.

    Returns:
        True when the point is inside; points on an edge may fall either way.
    """
    x, y = point
    inside = False
    count = len(polygon)
    if count < 3:
        return False
    previous = polygon[-1]
    for current in polygon:
        x1, y1 = previous
        x2, y2 = current
        if (y1 > y) != (y2 > y):
            crossing = x1 + (y - y1) * (x2 - x1) / (y2 - y1)
            if x < crossing:
                inside = not inside
        previous = current
    return inside


def side_of_line(point: Point, start: Point, end: Point) -> float:
    """Return the signed distance of a point from the infinite line through two points.

    The sign is positive on the side the line's normal points to. For a line drawn from left to right the
    positive side is below the line, because y grows downwards.

    Args:
        point: The point to measure.
        start: First point of the line.
        end: Second point of the line.

    Returns:
        The signed distance in normalized units, or 0 for a degenerate line.
    """
    dx, dy = end[0] - start[0], end[1] - start[1]
    length = math.hypot(dx, dy)
    if length == 0:
        return 0.0
    return (dx * (point[1] - start[1]) - dy * (point[0] - start[0])) / length


def segments_intersect(p1: Point, p2: Point, q1: Point, q2: Point, tolerance: float = 0.0) -> bool:
    """Tell whether segment p1-p2 meets segment q1-q2.

    Args:
        p1: Start of the first segment.
        p2: End of the first segment.
        q1: Start of the second segment.
        q2: End of the second segment.
        tolerance: Extra length allowed at both ends of the second segment, as a fraction of its length.

    Returns:
        True when the segments intersect.
    """
    if tolerance:
        dx, dy = q2[0] - q1[0], q2[1] - q1[1]
        q1 = (q1[0] - dx * tolerance, q1[1] - dy * tolerance)
        q2 = (q2[0] + dx * tolerance, q2[1] + dy * tolerance)

    def cross(o: Point, a: Point, b: Point) -> float:
        return (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0])

    d1 = cross(q1, q2, p1)
    d2 = cross(q1, q2, p2)
    d3 = cross(p1, p2, q1)
    d4 = cross(p1, p2, q2)
    return ((d1 > 0) != (d2 > 0)) and ((d3 > 0) != (d4 > 0))


def distance(a: Point, b: Point) -> float:
    """Return the Euclidean distance between two points.

    Args:
        a: First point.
        b: Second point.

    Returns:
        The distance in normalized units.
    """
    return math.hypot(a[0] - b[0], a[1] - b[1])


def iou(a: tuple[float, float, float, float], b: tuple[float, float, float, float]) -> float:
    """Return the intersection over union of two boxes given as left, top, right and bottom.

    Args:
        a: First box.
        b: Second box.

    Returns:
        A value from 0 for disjoint boxes to 1 for identical ones.
    """
    left, top = max(a[0], b[0]), max(a[1], b[1])
    right, bottom = min(a[2], b[2]), min(a[3], b[3])
    inter = max(0.0, right - left) * max(0.0, bottom - top)
    union = (a[2] - a[0]) * (a[3] - a[1]) + (b[2] - b[0]) * (b[3] - b[1]) - inter
    return inter / union if union > 0 else 0.0
