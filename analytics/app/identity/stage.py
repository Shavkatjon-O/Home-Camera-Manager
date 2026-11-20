"""The face stage in the service process: embedding, track decisions, cooldowns and face events.

Candidates arrive from the pipeline process in batches. A worker thread keeps the best faces of each track, embeds
the few that matter, decides each track once it has enough faces or time, and publishes one face result per
decided track. A track decided as unknown is checked again when it ends, and becomes known when its later faces
name a person. The same person or cluster produces at most one event per view within the cooldown.
"""

from __future__ import annotations

import logging
import os
import queue
import threading
import time
from collections import Counter
from collections.abc import Callable
from dataclasses import dataclass
from pathlib import Path

import numpy as np

from app.identity.align import CROP_SIZE
from app.identity.gallery import Gallery, Match, Matcher, encode_vector
from app.identity.models import FaceModels
from app.identity.probe import Candidate
from app.identity.settings import IdentitySettings
from app.identity.tracks import TrackFaces

logger = logging.getLogger(__name__)

STEP_SECONDS = 0.25
RETRY_SECONDS = 60.0
JPEG_QUALITY = 90
RECENT_RESULTS = 50


@dataclass(frozen=True)
class ViewInfo:
    """What the face stage needs to know about a view.

    Attributes:
        id: View id.
        name: View name.
        camera: Camera id.
    """

    id: str
    name: str
    camera: str


def write_jpeg(target: Path, pixels: bytes, size: int) -> None:
    """Write RGB pixels as a JPEG file atomically.

    Args:
        target: The file.
        pixels: Square RGB pixels.
        size: Side of the square.
    """
    from PIL import Image

    target.parent.mkdir(parents=True, exist_ok=True)
    image = Image.frombytes("RGB", (size, size), pixels)
    temporary = target.with_suffix(".part")
    image.save(temporary, format="JPEG", quality=JPEG_QUALITY)
    os.replace(temporary, target)


def crop_path(event: str, at: float) -> str:
    """Return the crop path of a face event relative to the events folder.

    Args:
        event: Face event id.
        at: Time the track started.

    Returns:
        A path such as faces/2026/11/20/<id>.jpg.
    """
    day = time.gmtime(at)
    return f"faces/{day.tm_year:04d}/{day.tm_mon:02d}/{day.tm_mday:02d}/{event}.jpg"


class FaceStage:
    """Turns face candidates into face events.

    Attributes:
        settings: Face settings.
        models: The face models.
        events_dir: Events folder shared with the backend, where crops are written.
        publish: Called with every face result for the backend.
        arm_mode: Returns the current arm mode.
        related: Returns the analytics event of a view's track, or None.
        gallery: Known people and unknown clusters.
        tracks: Tracks being collected, by view id and tracker id.
        views: View of each muxer pad.
        counters: Running totals for the status endpoint.
        recent: Latest published results without their embeddings.
    """

    def __init__(
        self,
        settings: IdentitySettings,
        models: FaceModels,
        events_dir: Path,
        publish: Callable[[dict], None],
        arm_mode: Callable[[], str],
        related: Callable[[str, int], str | None] | None = None,
    ):
        """Create the stage; call start to run its worker.

        Args:
            settings: Face settings.
            models: The face models.
            events_dir: Events folder shared with the backend.
            publish: Called with every face result.
            arm_mode: Returns the current arm mode.
            related: Returns the analytics event of a view's track, or None.
        """
        self.settings = settings
        self.models = models
        self.events_dir = events_dir
        self.publish = publish
        self.arm_mode = arm_mode
        self.related = related or (lambda view, track: None)
        self.matcher = Matcher(settings)
        self.gallery = Gallery()
        self.tracks: dict[tuple[str, int], TrackFaces] = {}
        self.views: dict[int, ViewInfo] = {}
        self.cooldowns: dict[tuple[str, str, str], float] = {}
        self.counters: Counter = Counter()
        self.recent: list[dict] = []
        self.inbox: queue.Queue = queue.Queue(maxsize=500)
        self.lock = threading.RLock()
        self.stopping = threading.Event()
        self.retry_at = 0.0

    def start(self) -> None:
        """Run the worker thread."""
        threading.Thread(target=self.loop, name="faces", daemon=True).start()

    def stop(self) -> None:
        """Stop the worker thread."""
        self.stopping.set()

    def set_views(self, views: dict[int, ViewInfo]) -> None:
        """Set the view of every muxer pad after the pipeline starts, forgetting tracks of the previous run.

        Args:
            views: View per pad for the views with faces enabled.
        """
        with self.lock:
            self.views = dict(views)
            self.tracks = {}

    def set_gallery(self, data: dict) -> None:
        """Replace the gallery with the backend's.

        Args:
            data: The gallery payload.
        """
        gallery = Gallery.from_payload(data, self.gallery)
        with self.lock:
            self.gallery = gallery
        logger.info(
            "Face gallery %s: %d people with %d samples, %d unknown clusters",
            gallery.version,
            len(gallery.people),
            len(gallery.owners),
            len(gallery.clusters),
        )

    def submit(self, candidates: list[Candidate]) -> None:
        """Hand candidates from the pipeline to the worker.

        Args:
            candidates: Faces the pipeline sent.
        """
        try:
            self.inbox.put_nowait(candidates)
        except queue.Full:
            self.counters["dropped"] += len(candidates)

    def loop(self) -> None:
        """Process candidates until stopped."""
        while not self.stopping.is_set():
            try:
                self.preload(time.time())
                self.drain()
                self.step(time.time())
            except Exception:
                logger.exception("The face stage failed a step")
            self.stopping.wait(STEP_SECONDS)

    def preload(self, now: float) -> None:
        """Load the face models as soon as any view needs them, so no face or photo waits for a first load.

        Args:
            now: Current time.
        """
        if not self.views or self.models.loaded or now < self.retry_at:
            return
        try:
            self.models.load()
        except Exception:
            logger.exception("Loading the face models failed, retrying in %.0f s", RETRY_SECONDS)
            self.retry_at = now + RETRY_SECONDS

    def drain(self) -> None:
        """Move waiting candidates into their tracks."""
        while True:
            try:
                batch = self.inbox.get_nowait()
            except queue.Empty:
                return
            for candidate in batch:
                self.collect(candidate)

    def collect(self, candidate: Candidate) -> None:
        """Add one candidate to its track.

        Args:
            candidate: The face.
        """
        with self.lock:
            view = self.views.get(candidate.pad)
            if view is None:
                return
            self.counters["candidates"] += 1
            key = (view.id, candidate.track)
            track = self.tracks.get(key)
            if track is None:
                track = self.tracks[key] = TrackFaces(view.id, candidate.track, candidate.at, candidate.at)
            if track.add(candidate, self.settings.faces_per_track):
                self.counters["kept"] += 1

    def step(self, now: float) -> None:
        """Embed pending faces, decide due tracks and close gone ones.

        Args:
            now: Current time.
        """
        with self.lock:
            tracks = list(self.tracks.values())
        ready = self.embed(tracks, now)
        for track in tracks:
            gone = now - track.last_at > self.settings.track_gap
            if ready and track.match is None and self.due(track, now, gone):
                self.decide(track, now)
            if gone:
                unknown = track.match is not None and not track.match.known
                if ready and unknown and len(track.embedded()) > track.decided_with:
                    self.upgrade(track, now)
                with self.lock:
                    self.tracks.pop((track.view, track.track), None)

    def due(self, track: TrackFaces, now: float, gone: bool) -> bool:
        """Tell whether a track has enough to be decided.

        Args:
            track: The track.
            now: Current time.
            gone: True when the track stopped sending faces.

        Returns:
            True when it should be decided now.
        """
        embedded = len(track.embedded())
        if embedded == 0 or embedded <= track.deferred:
            return False
        waited = now - track.first_at >= self.settings.decide_seconds
        return embedded >= self.settings.decide_faces or waited or gone

    def embed(self, tracks: list[TrackFaces], now: float) -> bool:
        """Embed the kept faces that wait for an embedding.

        Args:
            tracks: Tracks to look at.
            now: Current time.

        Returns:
            False while the models cannot be loaded.
        """
        pending = [face for track in tracks for face in track.pending()]
        if not pending:
            return True
        if not self.models.loaded:
            if now < self.retry_at:
                return False
            try:
                self.models.load()
            except Exception:
                logger.exception("Loading the face models failed, retrying in %.0f s", RETRY_SECONDS)
                self.retry_at = now + RETRY_SECONDS
                return False
        aligned = [np.frombuffer(face.candidate.aligned, dtype=np.uint8).reshape(112, 112, 3) for face in pending]
        embeddings = self.models.embed(aligned)
        for face, embedding in zip(pending, embeddings):
            face.embedding = embedding
        self.counters["embedded"] += len(pending)
        return True

    def cooling(self, kind: str, key: str, view: str, now: float) -> bool:
        """Tell whether a person or cluster produced an event on a view within the cooldown.

        Args:
            kind: person or cluster.
            key: Its id.
            view: View id.
            now: Current time.

        Returns:
            True while the cooldown lasts.
        """
        last = self.cooldowns.get((kind, key, view))
        return last is not None and now - last < self.settings.cooldown

    def remember(self, match: Match, view: str, now: float) -> None:
        """Start the cooldown of a match on a view.

        Args:
            match: The published match.
            view: View id.
            now: Current time.
        """
        kind, key = ("person", match.person) if match.known else ("cluster", match.cluster)
        self.cooldowns[(kind, key, view)] = now
        for entry in [entry for entry, at in self.cooldowns.items() if now - at > self.settings.cooldown]:
            del self.cooldowns[entry]

    def decide(self, track: TrackFaces, now: float) -> None:
        """Decide who a track is and publish the result unless a cooldown holds it back.

        Args:
            track: The track.
            now: Current time.
        """
        embedding = track.embedding()
        with self.lock:
            match = self.matcher.match(self.gallery, embedding, track.grey(), now)
            if match.cluster_new and track.quality() < self.settings.cluster_quality:
                # Dark or blurred faces would start clusters of nobody in particular; wait for better ones.
                del self.gallery.clusters[match.cluster]
                track.deferred = len(track.embedded())
                self.counters["deferred"] += 1
                return
        track.match = match
        track.decided_with = len(track.embedded())
        self.counters["known" if match.known else "unknown"] += 1
        kind, key = ("person", match.person) if match.known else ("cluster", match.cluster)
        if not match.cluster_new and self.cooling(kind, key, track.view, now):
            self.counters["cooldown"] += 1
            return
        self.send(track, match, "open", now)

    def upgrade(self, track: TrackFaces, now: float) -> None:
        """Check an unknown track again with all its faces and name it when they now match a person.

        Args:
            track: The ended track.
            now: Current time.
        """
        embedding = track.embedding()
        with self.lock:
            scores = self.gallery.person_scores(embedding)
            people = dict(self.gallery.people)
        if not scores:
            return
        person, best = scores[0]
        second = scores[1][1] if len(scores) > 1 else -1.0
        if best < self.matcher.known_threshold(track.grey()) or best - second < self.settings.margin:
            return
        match = Match(True, person=person, person_name=people.get(person), confidence=round(best, 4))
        self.counters["upgraded"] += 1
        if track.published:
            track.match = match
            self.send(track, match, "update", now)
        elif not self.cooling("person", person, track.view, now):
            track.match = match
            self.send(track, match, "open", now)

    def send(self, track: TrackFaces, match: Match, action: str, now: float) -> None:
        """Write the crop and publish a face result.

        Args:
            track: The track.
            match: Who it is.
            action: open or update.
            now: Current time.
        """
        view = next((info for info in self.views.values() if info.id == track.view), None)
        best = track.best()
        if view is None or best is None:
            return
        relative = crop_path(track.event, track.first_at)
        try:
            write_jpeg(self.events_dir / relative, best.candidate.crop, CROP_SIZE)
        except OSError as exc:
            logger.warning("Writing the face crop of %s failed: %s", track.event, exc)
            relative = None
        body = {
            "id": track.event,
            "action": action,
            "camera": view.camera,
            "view": view.id,
            "view_name": view.name,
            "track": track.track,
            "related_event": self.related(view.id, track.track),
            "started_at": round(track.first_at, 3),
            "seen_at": round(best.candidate.at, 3),
            "status": "known" if match.known else "unknown",
            "person": match.person,
            "cluster": match.cluster,
            "cluster_new": match.cluster_new,
            "confidence": match.confidence,
            "candidate": {"person": match.candidate[0], "score": match.candidate[1]} if match.candidate else None,
            "embedding": encode_vector(track.embedding()),
            "quality": round(track.quality(), 4),
            "faces": len(track.embedded()),
            "crop": relative,
            "box": [round(value, 4) for value in best.candidate.box],
            "alert": not match.known and self.arm_mode() == "away",
        }
        track.published = True
        self.remember(match, track.view, now)
        self.counters["published"] += 1
        summary = {key: value for key, value in body.items() if key != "embedding"}
        summary["person_name"] = match.person_name
        self.recent = (self.recent + [summary])[-RECENT_RESULTS:]
        logger.info(
            "Face %s %s on %s track %d: %s confidence %.2f from %d faces",
            action,
            body["status"],
            view.name,
            track.track,
            match.person_name or match.cluster,
            match.confidence,
            body["faces"],
        )
        self.publish(body)

    def status(self) -> dict:
        """Return the stage's state for the status endpoint.

        Returns:
            Models, gallery, open tracks, counters and recent results.
        """
        with self.lock:
            return {
                "models": self.models.status(),
                "gallery": {
                    "version": self.gallery.version,
                    "people": len(self.gallery.people),
                    "samples": len(self.gallery.owners),
                    "clusters": len(self.gallery.clusters),
                },
                "views": sorted(info.name for info in self.views.values()),
                "tracks": len(self.tracks),
                "counters": dict(self.counters),
                "thresholds": {
                    "known": self.settings.known_threshold,
                    "known_grey": self.matcher.known_threshold(True),
                    "margin": self.settings.margin,
                    "candidate": self.settings.candidate_threshold,
                    "cluster": self.settings.cluster_threshold,
                    "cooldown_seconds": self.settings.cooldown,
                },
                "recent": list(self.recent[-20:]),
            }


class GallerySync:
    """Keeps the stage's gallery in step with the backend.

    Attributes:
        fetch: Returns the backend's gallery payload; raises OSError when the backend is away.
        stage: The face stage.
        interval: Seconds between two fetches.
        fetched: Time of the last fetch.
        error: The latest fetch error, or None.
    """

    def __init__(self, fetch: Callable[[], dict | None], stage: FaceStage, interval: float = 10.0):
        """Create the sync.

        Args:
            fetch: Returns the gallery payload.
            stage: The face stage.
            interval: Seconds between two fetches.
        """
        self.fetch = fetch
        self.stage = stage
        self.interval = interval
        self.fetched = 0.0
        self.error: str | None = None

    def poll(self, now: float) -> None:
        """Fetch the gallery when due and apply it when its version changed.

        Args:
            now: Current time.
        """
        if now - self.fetched < self.interval:
            return
        self.fetched = now
        try:
            data = self.fetch()
        except (OSError, ValueError) as exc:
            if self.error is None:
                logger.warning("Fetching the face gallery failed: %s", exc)
            self.error = f"{type(exc).__name__}: {exc}"
            return
        self.error = None
        if data and str(data.get("version") or "") != self.stage.gallery.version:
            self.stage.set_gallery(data)
