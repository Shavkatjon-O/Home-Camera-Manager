from uuid import uuid4

from app.models import AnalyticsView, Camera
from app.modules.analytics.enums import ViewStream
from app.modules.analytics.services.config import camera_stream, view_config
from app.modules.analytics.services.views import view_stream
from app.streaming.names import MAIN, SUB, stream_name


def camera(sub_path="/sub"):
    return Camera(uuid=uuid4(), name="Door", sub_path=sub_path)


def view(stream="sub", faces=None, plates=False, profile="perimeter", enabled=True):
    return AnalyticsView(
        uuid=uuid4(),
        camera_uuid=uuid4(),
        lens=0,
        name="Door",
        profile=profile,
        enabled=enabled,
        fps=8.0,
        moving=False,
        tuning={},
        stream=stream,
        faces=faces,
        plates=plates,
    )


def test_view_reads_sub_when_asked_and_the_camera_has_one():
    assert view_stream(view(), camera()) == ViewStream.SUB


def test_view_reads_main_without_a_choice():
    assert view_stream(view(stream=None), camera()) == ViewStream.MAIN


def test_view_reads_main_when_the_camera_has_no_sub_path():
    assert view_stream(view(), camera(sub_path=None)) == ViewStream.MAIN


def test_view_with_faces_reads_main():
    assert view_stream(view(faces=True), camera()) == ViewStream.MAIN


def test_view_with_plates_reads_main():
    assert view_stream(view(plates=True), camera()) == ViewStream.MAIN


def test_identity_profile_reads_main_unless_faces_are_off():
    assert view_stream(view(profile="identity"), camera()) == ViewStream.MAIN
    assert view_stream(view(profile="identity", faces=False), camera()) == ViewStream.SUB


def test_camera_decodes_sub_when_every_enabled_view_reads_sub():
    found = camera()
    assert camera_stream(found, [ViewStream.SUB, ViewStream.SUB]) == stream_name(found.uuid, SUB)


def test_camera_decodes_main_when_one_view_reads_main():
    found = camera()
    assert camera_stream(found, [ViewStream.SUB, ViewStream.MAIN]) == stream_name(found.uuid, MAIN)


def test_camera_decodes_main_without_enabled_views():
    found = camera()
    assert camera_stream(found, []) == stream_name(found.uuid, MAIN)


def test_camera_without_a_sub_path_decodes_main():
    found = camera(sub_path=None)
    assert camera_stream(found, [ViewStream.SUB]) == stream_name(found.uuid, MAIN)


def test_view_config_forces_faces_off_when_not_allowed():
    data = view_config(view(faces=True), [], [], faces_allowed=False)
    assert data["faces"] is False


def test_view_config_keeps_the_faces_choice_when_allowed():
    assert view_config(view(faces=True), [], [])["faces"] is True
    assert "faces" not in view_config(view(faces=None), [], [])


def test_view_config_carries_owner_and_stream():
    owner = {"site": "s1", "organisation": "o1"}
    data = view_config(view(), [], [], owner=owner, stream=ViewStream.SUB)
    assert data["site"] == "s1"
    assert data["organisation"] == "o1"
    assert data["stream"] == "sub"


def test_view_config_defaults_to_the_main_stream():
    assert view_config(view(), [], [])["stream"] == "main"
