import base64
import io

import numpy as np
import pytest
from face_helpers import FakeModels, candidate, gallery_payload, settings, unit, with_similarity
from PIL import Image

from app.identity import enroll
from app.identity.scrfd import RawFace
from app.identity.stage import FaceStage, GallerySync, ViewInfo, crop_path

ALICE = unit(1)


def stage(tmp_path, vectors, arm="schedule", **changes):
    published = []
    models = FakeModels(vectors)
    face_stage = FaceStage(
        settings(**changes), models, tmp_path, published.append, lambda: arm, lambda view, track: f"rule-{track}"
    )
    face_stage.set_views({0: ViewInfo("door", "PTZ 2 Lens 2", "cam-2"), 1: ViewInfo("hall", "PTZ 2 Lens 1", "cam-2")})
    face_stage.set_gallery(gallery_payload(people=[("a", "Alice", [ALICE])]))
    return face_stage, published, models


def feed(face_stage, candidates):
    face_stage.submit(candidates)
    face_stage.drain()


def test_known_track_publishes_once_with_crop(tmp_path):
    face_stage, published, models = stage(tmp_path, {1: with_similarity(ALICE, 0.65, 3)})
    feed(face_stage, [candidate(5, 100.0), candidate(5, 100.5), candidate(5, 101.0)])
    face_stage.step(101.1)
    assert len(published) == 1
    body = published[0]
    assert body["status"] == "known" and body["person"] == "a" and body["action"] == "open"
    assert body["camera"] == "cam-2" and body["view"] == "door" and body["track"] == 5
    assert body["related_event"] == "rule-5"
    assert body["faces"] == 3 and not body["alert"]
    assert body["crop"] == crop_path(body["id"], 100.0)
    assert (tmp_path / body["crop"]).is_file()
    assert models.calls == [3]
    face_stage.step(101.2)
    assert len(published) == 1


def test_track_waits_for_more_faces_or_time(tmp_path):
    face_stage, published, _ = stage(tmp_path, {1: with_similarity(ALICE, 0.65, 3)})
    feed(face_stage, [candidate(5, 100.0)])
    face_stage.step(101.0)
    assert published == []
    face_stage.step(103.5)
    assert len(published) == 1


def test_cooldown_holds_back_the_same_person_on_the_same_view(tmp_path):
    face_stage, published, _ = stage(tmp_path, {1: with_similarity(ALICE, 0.65, 3)})
    feed(face_stage, [candidate(5, 100.0), candidate(5, 100.1), candidate(5, 100.2)])
    face_stage.step(100.3)
    feed(face_stage, [candidate(6, 200.0), candidate(6, 200.1), candidate(6, 200.2)])
    face_stage.step(200.3)
    feed(face_stage, [candidate(7, 200.0, pad=1), candidate(7, 200.1, pad=1), candidate(7, 200.2, pad=1)])
    face_stage.step(200.3)
    assert [body["view"] for body in published] == ["door", "hall"]
    assert face_stage.counters["cooldown"] == 1
    feed(face_stage, [candidate(8, 900.0), candidate(8, 900.1), candidate(8, 900.2)])
    face_stage.step(900.3)
    assert len(published) == 3


def test_unknown_track_gets_a_cluster_and_alerts_when_away(tmp_path):
    face_stage, published, _ = stage(tmp_path, {1: unit(40)}, arm="away")
    feed(face_stage, [candidate(5, 100.0), candidate(5, 100.1), candidate(5, 100.2)])
    face_stage.step(100.3)
    body = published[0]
    assert body["status"] == "unknown" and body["cluster_new"] and body["alert"]
    assert body["cluster"] in face_stage.gallery.clusters
    feed(face_stage, [candidate(9, 300.0), candidate(9, 300.1), candidate(9, 300.2)])
    face_stage.step(300.3)
    assert len(published) == 1
    assert face_stage.counters["cooldown"] == 1


def test_unknown_track_is_named_when_its_later_faces_match(tmp_path):
    vectors = {1: with_similarity(ALICE, 0.2, 3), 2: with_similarity(ALICE, 0.95, 4)}
    face_stage, published, _ = stage(tmp_path, vectors)
    feed(face_stage, [candidate(5, 100.0, marker=1, quality=0.4)])
    face_stage.step(103.5)
    assert published[0]["status"] == "unknown"
    feed(face_stage, [candidate(5, 104.0, marker=2, quality=0.9), candidate(5, 104.2, marker=2, quality=0.95)])
    face_stage.step(104.3)
    face_stage.step(111.0)
    assert [body["action"] for body in published] == ["open", "update"]
    assert published[1]["status"] == "known" and published[1]["id"] == published[0]["id"]
    assert face_stage.tracks == {}


def test_candidates_of_unknown_pads_are_ignored(tmp_path):
    face_stage, published, _ = stage(tmp_path, {1: unit(1)})
    feed(face_stage, [candidate(5, 100.0, pad=7)])
    face_stage.step(110.0)
    assert published == [] and face_stage.tracks == {}


def test_models_that_fail_to_load_hold_decisions_but_drop_gone_tracks(tmp_path):
    face_stage, published, models = stage(tmp_path, {1: unit(1)})
    models.loaded = False

    def broken():
        raise RuntimeError("no engine")

    models.load = broken
    feed(face_stage, [candidate(5, 100.0)])
    face_stage.step(101.0)
    face_stage.step(120.0)
    assert published == [] and face_stage.tracks == {}


def test_gallery_sync_applies_new_versions_only(tmp_path):
    face_stage, _, _ = stage(tmp_path, {1: unit(1)})
    calls = []

    def fetch():
        calls.append(1)
        return gallery_payload(people=[("b", "Bob", [unit(2)])], version="v2")

    sync = GallerySync(fetch, face_stage, interval=10.0)
    sync.poll(100.0)
    assert face_stage.gallery.version == "v2" and "b" in face_stage.gallery.people
    sync.poll(105.0)
    assert len(calls) == 1

    def away():
        raise OSError("backend down")

    sync.fetch = away
    sync.poll(120.0)
    assert sync.error and face_stage.gallery.version == "v2"


def photo_bytes(orientation=None, size=(64, 32)):
    image = Image.new("RGB", size, (200, 10, 10))
    buffer = io.BytesIO()
    if orientation:
        exif = Image.Exif()
        exif[0x0112] = orientation
        image.save(buffer, format="JPEG", exif=exif)
    else:
        image.save(buffer, format="JPEG")
    return buffer.getvalue()


def test_photos_are_decoded_upright_and_bad_ones_refused():
    assert enroll.decode_photo(photo_bytes()).shape == (32, 64, 3)
    assert enroll.decode_photo(photo_bytes(orientation=6)).shape == (64, 32, 3)
    with pytest.raises(enroll.PhotoError):
        enroll.decode_photo(b"")
    with pytest.raises(enroll.PhotoError):
        enroll.decode_photo(b"not a picture")


class PhotoModels(FakeModels):
    def __init__(self, faces):
        super().__init__({})
        self.faces = faces

    def detect(self, image, threshold):
        return self.faces

    def embed(self, faces):
        return np.stack([unit(index) for index, _ in enumerate(faces)])


def test_embed_photo_lists_faces_largest_first_with_crops():
    landmarks = np.array([[30, 30], [50, 30], [40, 40], [32, 50], [48, 50]], dtype=np.float32)
    small = RawFace((25.0, 20.0, 55.0, 60.0), 0.9, landmarks)
    large = RawFace((100.0, 10.0, 220.0, 170.0), 0.8, landmarks * 4)
    result = enroll.embed_photo(photo_bytes(size=(400, 300)), PhotoModels([small, large]), settings())
    assert result["width"] == 400 and result["height"] == 300
    assert [face["size"] for face in result["faces"]] == [160.0, 40.0]
    crop = Image.open(io.BytesIO(base64.b64decode(result["faces"][0]["crop"])))
    assert crop.size == (160, 160)
    assert len(base64.b64decode(result["faces"][0]["embedding"])) == 2048


def test_answer_maps_failures_to_status_codes():
    status, body = enroll.answer(b"junk", PhotoModels([]), settings())
    assert status == 400 and "could not be read" in body["detail"]
    models = PhotoModels([])

    def broken():
        raise RuntimeError("no engine")

    models.load = broken
    status, body = enroll.answer(photo_bytes(), models, settings())
    assert status == 503


def test_poor_tracks_never_start_a_cluster_but_better_faces_do(tmp_path):
    face_stage, published, _ = stage(tmp_path, {1: unit(40)})
    feed(
        face_stage,
        [candidate(5, 100.0, quality=0.2), candidate(5, 100.1, quality=0.2), candidate(5, 100.2, quality=0.2)],
    )
    face_stage.step(100.3)
    assert published == [] and face_stage.gallery.clusters == {}
    assert face_stage.counters["deferred"] == 1
    face_stage.step(100.5)
    assert face_stage.counters["deferred"] == 1
    feed(face_stage, [candidate(5, 101.0, quality=0.9)])
    face_stage.step(101.1)
    assert len(published) == 1 and published[0]["cluster_new"]


def test_poor_tracks_still_join_an_existing_cluster(tmp_path):
    stranger = unit(40)
    face_stage, published, _ = stage(tmp_path, {1: with_similarity(stranger, 0.7, 41)})
    face_stage.set_gallery(
        gallery_payload(people=[("a", "Alice", [ALICE])], clusters=[("c1", 2, stranger, 3)], version="v2")
    )
    feed(
        face_stage,
        [candidate(5, 100.0, quality=0.2), candidate(5, 100.1, quality=0.2), candidate(5, 100.2, quality=0.2)],
    )
    face_stage.step(100.3)
    assert published[0]["cluster"] == "c1" and not published[0]["cluster_new"]


def test_models_load_as_soon_as_a_face_view_exists(tmp_path):
    face_stage, _, models = stage(tmp_path, {1: unit(1)})
    models.loaded = False
    calls = []

    def load():
        calls.append(1)
        models.loaded = True

    models.load = load
    face_stage.preload(100.0)
    face_stage.preload(101.0)
    assert calls == [1]
    face_stage.set_views({})
    models.loaded = False
    face_stage.preload(102.0)
    assert calls == [1]
