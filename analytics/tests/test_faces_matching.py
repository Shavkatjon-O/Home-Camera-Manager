import numpy as np
import pytest
from face_helpers import candidate, gallery_payload, settings, unit, with_similarity

from app.identity.gallery import Gallery, Matcher, decode_vector, encode_vector
from app.identity.tracks import TrackFaces


def test_vectors_survive_encoding_and_wrong_sizes_fail():
    vector = unit(3)
    assert decode_vector(encode_vector(vector)) == pytest.approx(vector, abs=1e-6)
    with pytest.raises(ValueError):
        decode_vector(encode_vector(np.ones(10, dtype=np.float32)))


def test_known_person_needs_threshold_and_margin():
    alice, bob = unit(1), unit(2)
    gallery = Gallery.from_payload(gallery_payload(people=[("a", "Alice", [alice]), ("b", "Bob", [bob])]))
    matcher = Matcher(settings())
    match = matcher.match(gallery, with_similarity(alice, 0.6, 9), False, 0.0)
    assert match.known and match.person == "a" and match.person_name == "Alice"
    assert match.confidence == pytest.approx(0.6, abs=0.01)
    weak = matcher.match(gallery, with_similarity(alice, 0.38, 10), False, 0.0)
    assert not weak.known
    assert weak.candidate[0] == "a"
    assert weak.cluster_new


def test_grey_faces_need_a_stricter_score():
    alice = unit(1)
    gallery = Gallery.from_payload(gallery_payload(people=[("a", "Alice", [alice])]))
    matcher = Matcher(settings())
    probe = with_similarity(alice, 0.44, 4)
    assert matcher.match(gallery, probe, False, 0.0).known
    assert not matcher.match(gallery, probe, True, 0.0).known


def test_two_close_people_leave_the_face_unknown():
    alice = unit(1)
    twin = with_similarity(alice, 0.9, 5)
    gallery = Gallery.from_payload(gallery_payload(people=[("a", "Alice", [alice]), ("t", "Twin", [twin])]))
    probe = with_similarity(alice, 0.7, 6)
    match = Matcher(settings()).match(gallery, probe, False, 0.0)
    assert not match.known


def test_unknown_faces_join_a_close_cluster_or_start_one():
    stranger = unit(7)
    gallery = Gallery.from_payload(gallery_payload(clusters=[("c1", 3, stranger, 4)]))
    matcher = Matcher(settings())
    joined = matcher.match(gallery, with_similarity(stranger, 0.6, 8), False, 0.0)
    assert joined.cluster == "c1" and not joined.cluster_new
    assert gallery.clusters["c1"].count == 5
    other = matcher.match(gallery, unit(11), False, 5.0)
    assert other.cluster_new and other.cluster in gallery.clusters
    again = matcher.match(gallery, with_similarity(unit(11), 0.7, 12), False, 6.0)
    assert again.cluster == other.cluster


def test_refresh_keeps_new_local_clusters_for_a_while():
    gallery = Gallery()
    match = Matcher(settings()).match(gallery, unit(1), False, 100.0)
    refreshed = Gallery.from_payload(gallery_payload(version="v2"), gallery, now=150.0)
    assert match.cluster in refreshed.clusters
    later = Gallery.from_payload(gallery_payload(version="v3"), refreshed, now=400.0)
    assert match.cluster not in later.clusters


def test_track_keeps_best_faces_and_weights_its_mean():
    track = TrackFaces("view", 1, 0.0, 0.0)
    for index, value in enumerate([0.2, 0.9, 0.5, 0.1, 0.7]):
        track.add(candidate(1, float(index), quality=value), keep=3)
    assert [face.candidate.quality for face in track.faces] == [0.9, 0.7, 0.5]
    assert not track.add(candidate(1, 6.0, quality=0.3), keep=3)
    for face, seed in zip(track.faces, (1, 1, 2)):
        face.embedding = unit(seed)
    mean = track.embedding()
    assert float(mean @ unit(1)) > float(mean @ unit(2))
    assert track.quality() == pytest.approx(0.7)
    assert track.best().candidate.quality == 0.9


def test_track_is_grey_when_most_faces_are():
    track = TrackFaces("view", 1, 0.0, 0.0)
    track.add(candidate(1, 0.0, grey=True), keep=5)
    track.add(candidate(1, 1.0, grey=True, quality=0.5), keep=5)
    track.add(candidate(1, 2.0, grey=False, quality=0.4), keep=5)
    for face in track.faces:
        face.embedding = unit(1)
    assert track.grey()
