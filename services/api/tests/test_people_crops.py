import base64
from uuid import uuid4

import pytest

from app.modules.people.crops import CropStore, decode_crop, enrolled_crop_path, is_relative_inside

JPEG = b"\xff\xd8\xff\xe0" + b"\x00" * 60


def test_resolve_keeps_paths_inside_the_folder(tmp_path):
    store = CropStore(tmp_path)
    path = store.resolve("faces/2026/11/20/a.jpg")
    assert path == (tmp_path / "faces/2026/11/20/a.jpg").resolve()


@pytest.mark.parametrize(
    "relative",
    ["", None, ".", "..", "../outside.jpg", "faces/../../outside.jpg", "/etc/passwd", "faces/../.."],
)
def test_resolve_refuses_paths_that_escape(tmp_path, relative):
    assert CropStore(tmp_path / "events").resolve(relative) is None


def test_resolve_refuses_a_link_that_leads_outside(tmp_path):
    root = tmp_path / "events"
    outside = tmp_path / "secret"
    root.mkdir()
    outside.mkdir()
    (root / "faces").symlink_to(outside)
    assert CropStore(root).resolve("faces/a.jpg") is None


def test_relative_paths_are_checked_before_storing():
    assert is_relative_inside("faces/2026/11/20/a.jpg")
    assert not is_relative_inside("/data/events/a.jpg")
    assert not is_relative_inside("faces/../a.jpg")
    assert not is_relative_inside("faces//a.jpg")
    assert not is_relative_inside("faces\\a.jpg")
    assert not is_relative_inside("")


async def test_write_replaces_the_file_whole(tmp_path):
    store = CropStore(tmp_path)
    relative = enrolled_crop_path(uuid4(), uuid4())
    assert await store.write(relative, JPEG)
    assert await store.write(relative, JPEG + b"\x01")
    target = tmp_path / relative
    assert target.read_bytes() == JPEG + b"\x01"
    assert [item.name for item in target.parent.iterdir()] == [target.name]


async def test_write_refuses_paths_that_escape(tmp_path):
    store = CropStore(tmp_path / "events")
    assert not await store.write("../outside.jpg", JPEG)
    assert not (tmp_path / "outside.jpg").exists()


async def test_delete_is_quiet_and_removes_empty_person_folders(tmp_path):
    store = CropStore(tmp_path)
    person = uuid4()
    upload = enrolled_crop_path(person, uuid4())
    event = "faces/2026/11/20/e.jpg"
    await store.write(upload, JPEG)
    await store.write(event, JPEG)
    (tmp_path / "keep.jpg").write_bytes(JPEG)
    await store.delete([upload, event, None, "", "missing/x.jpg", "../keep.jpg"])
    assert not (tmp_path / upload).exists()
    assert not (tmp_path / "people" / str(person)).exists()
    assert not (tmp_path / event).exists()
    assert (tmp_path / "faces/2026/11/20").is_dir()
    assert (tmp_path / "keep.jpg").exists()


def test_crops_decode_from_base64_jpeg_only():
    assert decode_crop(base64.b64encode(JPEG).decode()) == JPEG
    with pytest.raises(ValueError, match="JPEG"):
        decode_crop(base64.b64encode(b"\x89PNG....").decode())
    with pytest.raises(ValueError, match="base64"):
        decode_crop("%%%")


def test_enrolled_crops_live_under_the_person():
    person = uuid4()
    sample = uuid4()
    assert enrolled_crop_path(person, sample) == f"people/{person}/{sample}.jpg"
