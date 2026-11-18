from uuid import UUID

from app.streaming.names import belongs_to, camera_streams, is_managed, rtsp_url, stream_name

CAMERA = UUID("0f3c2b1a-1111-4222-8333-944455556666")


def test_rtsp_url_encodes_credentials_and_skips_missing_ones():
    assert rtsp_url("192.168.1.237", 554, "/live/ch00_0", None, None) == "rtsp://192.168.1.237:554/live/ch00_0"
    assert rtsp_url("cam", 554, "/a", "ad@min", "p:w/d#1") == "rtsp://ad%40min:p%3Aw%2Fd%231@cam:554/a"
    assert rtsp_url("cam", 554, "/a", "admin", None) == "rtsp://admin@cam:554/a"
    assert rtsp_url("cam", 554, "/a", None, "orphan") == "rtsp://cam:554/a"


def test_camera_streams_add_a_transcode_after_the_camera_source():
    streams = camera_streams(CAMERA, "192.168.1.237", 554, "/live/ch00_0", "/live/ch00_1", None, None)
    main = stream_name(CAMERA, "main")
    assert main == "0f3c2b1a11114222833394445555666" + "6_main"
    assert streams[main] == ["rtsp://192.168.1.237:554/live/ch00_0", f"ffmpeg:{main}#video=h264#audio=aac"]
    assert set(streams) == {main, stream_name(CAMERA, "sub")}


def test_camera_without_sub_path_has_only_a_main_stream():
    streams = camera_streams(CAMERA, "cam", 554, "/main", None, None, None)
    assert list(streams) == [stream_name(CAMERA, "main")]


def test_managed_names():
    assert is_managed(stream_name(CAMERA, "sub"))
    assert not is_managed("cam_a")
    assert belongs_to(stream_name(CAMERA, "main"), CAMERA)
    assert not belongs_to(stream_name(UUID(int=1), "main"), CAMERA)
