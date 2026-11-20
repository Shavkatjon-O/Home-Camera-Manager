import os

from app.recorder import Segment, covering, crop_filter, list_segments


def test_segments_are_listed_in_time_order_with_their_ends(tmp_path):
    for start in (1000, 1004, 1009):
        (tmp_path / f"{start}.ts").write_bytes(b"x")
    os.utime(tmp_path / "1009.ts", (1011, 1011))
    (tmp_path / "notes.txt").write_text("ignored")
    segments = list_segments(tmp_path)
    assert [(segment.start, segment.end) for segment in segments] == [(1000, 1004), (1004, 1009), (1009, 1011)]
    precise = list_segments(tmp_path, {"1004.ts": 1004.6})
    assert [(segment.start, segment.end) for segment in precise][:2] == [(1000, 1004.6), (1004.6, 1009)]


def test_covering_picks_the_overlapping_segments():
    segments = [Segment(None, 0, 4), Segment(None, 4, 9), Segment(None, 9, 12)]
    assert [segment.start for segment in covering(segments, 3, 5)] == [0, 4]
    assert [segment.start for segment in covering(segments, 9.5, 20)] == [9]
    assert covering(segments, 20, 30) == []


def test_crop_filter_cuts_lens_bands():
    assert crop_filter(0, 1) == []
    assert crop_filter(1, 2) == ["crop=iw:ih/2:0:ih*0/2"]
    assert crop_filter(2, 2) == ["crop=iw:ih/2:0:ih*1/2"]


def test_a_snapshot_past_the_last_frame_of_a_segment_also_tries_the_next_one():
    from app.recorder import ClipMaker

    segments = [Segment("a", 0.0, 5.3), Segment("b", 5.3, 10.4), Segment("c", 10.4, 11.0)]
    candidates = ClipMaker.snapshot_candidates(segments, 5.2)
    assert [(segment.path, round(offset, 3)) for segment, offset in candidates] == [("a", 5.2), ("b", 0.0)]
    newest = ClipMaker.snapshot_candidates(segments, 10.6)
    assert [(segment.path, round(offset, 3)) for segment, offset in newest] == [("c", 0.2)]


def test_a_snapshot_before_the_buffer_falls_back_to_the_first_following_frame():
    import pytest

    from app.recorder import ClipMaker

    segments = [Segment("a", 100.0, 103.0), Segment("b", 103.0, 106.0)]
    candidates = ClipMaker.snapshot_candidates(segments, 96.5)
    assert [(segment.path, offset) for segment, offset in candidates] == [("a", 0.0)]
    with pytest.raises(FileNotFoundError):
        ClipMaker.snapshot_candidates(segments, 80.0)
    with pytest.raises(FileNotFoundError):
        ClipMaker.snapshot_candidates([], 80.0)
