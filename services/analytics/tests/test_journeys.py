import numpy as np

from app.reid.appearance import AppearanceSample, TrackAppearance, sample_weight
from app.reid.journeys import JourneyLinker, JourneySettings, describe
from app.rules.model import Box

DIM = 256
NAMES = {"yard": "Yard", "entrance": "Entrance", "corridor": "Corridor"}


def identity(seed):
    vector = np.random.default_rng(seed).normal(size=DIM).astype(np.float32)
    return vector / np.linalg.norm(vector)


def unit(vector):
    return (vector / np.linalg.norm(vector)).astype(np.float32)


def look(base, seed, noise=0.35):
    generator = np.random.default_rng(seed)
    return unit(base + noise * generator.normal(size=DIM).astype(np.float32) / np.sqrt(DIM))


def walk(linker, view, track, base, start, end, seed, height=140.0, camera=None):
    steps = int((end - start) * 2)
    for step in range(steps + 1):
        at = start + step * 0.5
        linker.add(
            AppearanceSample(
                view=view,
                camera=camera or view,
                track=track,
                at=at,
                box=Box(0.4, 0.2, 0.5, 0.2 + height / 1080),
                embedding=look(base, seed * 1000 + step),
                height_px=height,
            )
        )


def seeded(settings=None):
    linker = JourneyLinker(settings)
    assert linker.restore_mean({"mean": [0.0] * DIM, "tracks": 1000})
    return linker


def orthonormal(count, seed=500):
    vectors = []
    for index in range(count):
        vector = identity(seed + index).astype(np.float64)
        for other in vectors:
            vector = vector - np.dot(vector, other) * other
        vectors.append(vector / np.linalg.norm(vector))
    return [vector.astype(np.float32) for vector in vectors]


def test_sample_weight():
    assert sample_weight(30) == 0.0
    assert 0.1 <= sample_weight(60) < 0.5
    assert sample_weight(400) == 1.0


def test_track_appearance_skips_small_crops_and_averages():
    base = identity(1)
    track = TrackAppearance("yard", "cam", 1, 0.0, 0.0)
    small = AppearanceSample("yard", "cam", 1, 0.0, Box(0, 0, 0.1, 0.1), look(base, 1), 20.0)
    assert not track.add(small)
    assert track.vector() is None
    for seed in range(5):
        assert track.add(AppearanceSample("yard", "cam", 1, seed, Box(0, 0, 0.1, 0.3), look(base, seed), 150.0))
    assert float(np.dot(track.vector(), base)) > 0.9
    assert track.as_dict()["samples"] == 5
    assert len(track.as_dict()["embedding"]) == DIM


def test_one_person_across_three_views_makes_one_journey_in_order():
    linker = seeded()
    person = identity(7)
    walk(linker, "yard", 3, person, 0, 10, 1)
    journeys, appearances = linker.tick(20)
    assert journeys == [] and len(appearances) == 1
    walk(linker, "entrance", 8, person, 25, 32, 2)
    linker.tick(40)
    walk(linker, "corridor", 2, person, 45, 55, 3)
    journeys, appearances = linker.tick(70)
    assert len(journeys) == 1
    steps = journeys[0]["steps"]
    assert [step["view"] for step in steps] == ["yard", "entrance", "corridor"]
    assert steps[0]["similarity"] is None and steps[1]["similarity"] > 0.35
    assert appearances[0]["journey"] == journeys[0]["id"]
    assert describe(journeys[0], NAMES) == "Yard, then Entrance, then Corridor"
    assert linker.journey_of("yard", 3) == journeys[0]["id"]


def test_two_people_stay_apart():
    linker = seeded()
    first, second = identity(11), identity(12)
    walk(linker, "yard", 1, first, 0, 10, 1)
    walk(linker, "yard", 2, second, 0, 10, 2)
    linker.tick(20)
    walk(linker, "entrance", 5, first, 25, 30, 3)
    walk(linker, "corridor", 6, second, 25, 30, 4)
    journeys, _ = linker.tick(40)
    assert len(journeys) == 2
    by_view = {journey["steps"][-1]["view"]: journey for journey in journeys}
    assert [step["track"] for step in by_view["entrance"]["steps"]] == [1, 5]
    assert [step["track"] for step in by_view["corridor"]["steps"]] == [2, 6]


def twins(base, spread=0.9):
    first, second = identity(1001), identity(1002)
    first = first - np.dot(first, base) * base
    first /= np.linalg.norm(first)
    second = second - np.dot(second, base) * base - np.dot(second, first) * first
    second /= np.linalg.norm(second)
    one = base + spread * first
    two = base + spread * second
    return one / np.linalg.norm(one), two / np.linalg.norm(two)


def test_ambiguous_match_does_not_link():
    linker = seeded(JourneySettings(margin=0.05))
    base = identity(21)
    twin_a, twin_b = twins(base, spread=1.5)
    assert float(np.dot(twin_a, twin_b)) < 0.35 < float(np.dot(twin_a, base))
    walk(linker, "yard", 1, twin_a, 0, 10, 1)
    walk(linker, "corridor", 2, twin_b, 0, 10, 2)
    linker.tick(20)
    walk(linker, "entrance", 3, base, 25, 30, 3)
    journeys, appearances = linker.tick(40)
    assert all(step["track"] != 3 for journey in journeys for step in journey["steps"])
    assert appearances[0]["journey"] is None


def test_time_window_is_respected():
    linker = seeded(JourneySettings(window_seconds=180))
    person = identity(31)
    walk(linker, "yard", 1, person, 0, 10, 1)
    linker.tick(20)
    walk(linker, "entrance", 2, person, 400, 405, 2)
    journeys, _ = linker.tick(420)
    assert journeys == []


def test_same_view_at_the_same_time_never_links():
    linker = seeded()
    person = identity(41)
    walk(linker, "yard", 1, person, 0, 10, 1)
    walk(linker, "yard", 2, person, 5, 12, 2)
    journeys, appearances = linker.tick(30)
    assert journeys == []
    assert len(appearances) == 2


def test_same_view_after_a_gap_links():
    linker = seeded()
    person = identity(51)
    walk(linker, "yard", 1, person, 0, 10, 1)
    linker.tick(20)
    walk(linker, "yard", 2, person, 60, 70, 2)
    journeys, _ = linker.tick(80)
    assert len(journeys) == 1
    assert describe(journeys[0], NAMES) == "Yard"


def test_journey_never_holds_two_overlapping_tracks_of_one_view():
    linker = seeded()
    person = identity(61)
    walk(linker, "yard", 1, person, 0, 10, 1)
    walk(linker, "entrance", 2, person, 2, 8, 2)
    linker.tick(20)
    walk(linker, "entrance", 3, person, 5, 12, 3)
    journeys, _ = linker.tick(30)
    for journey in journeys:
        views = [(step["view"], step["track"]) for step in journey["steps"]]
        assert not ({("entrance", 2), ("entrance", 3)} <= set(views))


def test_small_crops_are_not_reported():
    linker = seeded()
    walk(linker, "yard", 1, identity(71), 0, 10, 1, height=30)
    journeys, appearances = linker.tick(30)
    assert journeys == [] and appearances == []


def test_find_returns_the_most_similar_track():
    linker = seeded()
    first, second = identity(81), identity(82)
    walk(linker, "yard", 1, first, 0, 10, 1)
    walk(linker, "corridor", 2, second, 0, 10, 2)
    linker.tick(20)
    results = linker.find(look(second, 99), since=0)
    assert results[0]["track"] == 2 and results[0]["similarity"] > 0.8
    assert results[1]["similarity"] < 0.3
    assert linker.find(look(second, 99), since=15) == []


def test_old_tracks_and_journeys_are_forgotten():
    linker = seeded(JourneySettings(keep_seconds=100))
    person = identity(91)
    walk(linker, "yard", 1, person, 0, 10, 1)
    linker.tick(20)
    walk(linker, "entrance", 2, person, 25, 30, 2)
    linker.tick(40)
    status = linker.status()
    assert (status["active"], status["finished"], status["journeys"], status["linking"]) == (0, 2, 1, True)
    linker.tick(500)
    status = linker.status()
    assert (status["finished"], status["journeys"]) == (0, 0)
    assert status["mean_tracks"] == 1002


def test_nothing_links_until_the_mean_has_seen_enough_tracks():
    linker = JourneyLinker()
    person = identity(101)
    walk(linker, "yard", 1, person, 0, 10, 1)
    linker.tick(15)
    walk(linker, "entrance", 2, person, 20, 25, 2)
    journeys, _ = linker.tick(35)
    assert journeys == [] and not linker.status()["linking"]
    for index in range(18):
        start = 1000 + index * 400
        walk(linker, "street", 10 + index, identity(200 + index), start, start + 5, 10 + index)
        linker.tick(start + 20)
    assert linker.status()["mean_tracks"] == 20 and linker.status()["linking"]
    other = identity(102)
    walk(linker, "yard", 3, other, 20000, 20010, 3)
    linker.tick(20015)
    walk(linker, "entrance", 4, other, 20020, 20025, 4)
    journeys, _ = linker.tick(20035)
    assert len(journeys) == 1
    assert [step["track"] for step in journeys[0]["steps"]] == [3, 4]


def test_centring_removes_the_shared_floor():
    linker = JourneyLinker()
    shared = identity(300)

    def person(seed):
        return unit(0.75 * shared + 0.66 * identity(seed))

    for index in range(30):
        start = index * 400
        walk(linker, "street", index, person(400 + index), start, start + 5, 50 + index)
        linker.tick(start + 20)
    first, second = person(1), person(2)
    assert float(np.dot(first, second)) > 0.45
    walk(linker, "yard", 1, first, 50000, 50010, 1)
    linker.tick(50015)
    walk(linker, "entrance", 2, second, 50015, 50020, 2)
    journeys, _ = linker.tick(50025)
    assert journeys == []
    walk(linker, "corridor", 3, first, 50030, 50040, 3)
    journeys, _ = linker.tick(50050)
    assert len(journeys) == 1
    assert [step["track"] for step in journeys[0]["steps"]] == [1, 3]


def test_link_needs_a_mutual_best_match():
    linker = seeded()
    axis, side, other = orthonormal(3)
    walk(linker, "yard", 1, axis, 0, 10, 1)
    linker.tick(15)
    weaker = unit(0.5 * axis + 0.866 * other)
    stronger = unit(0.8 * axis + 0.6 * side)
    walk(linker, "entrance", 2, weaker, 20, 25, 2)
    walk(linker, "corridor", 3, stronger, 20, 25, 3)
    journeys, appearances = linker.tick(40)
    assert len(journeys) == 1
    assert [step["track"] for step in journeys[0]["steps"]] == [1, 3]
    by_track = {item["track"]: item["journey"] for item in appearances}
    assert by_track[2] is None and by_track[3] == journeys[0]["id"]


def test_mean_persists_and_restores():
    linker = JourneyLinker()
    for index in range(3):
        walk(linker, "street", index, identity(600 + index), index * 400, index * 400 + 5, index)
        linker.tick(index * 400 + 20)
    state = linker.mean_state()
    assert state["tracks"] == 3 and len(state["mean"]) == DIM
    restored = JourneyLinker()
    assert restored.restore_mean(state)
    assert np.allclose(restored.mean, linker.mean, atol=1e-5)
    assert restored.mean_tracks == 3
    assert not JourneyLinker().restore_mean(None)
    assert JourneyLinker().mean_state() is None
