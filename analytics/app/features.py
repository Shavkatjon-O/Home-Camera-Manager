"""The view features beyond zones and lines: objects left and taken, falls, journeys, follow, plates and counts.

The service owns the pipeline, the rules engines, the tamper watch and the media; this hub owns everything the later
features add and is called from a few places in the service: when the configuration changes, for every analysed
frame, for every batch of person crops from the pipeline, for every keyframe, for every event change and once per
loop. Events it produces go back through the service's handle, so they get snapshots, clips and the backend like
any other event, and its reports go out through the service's backend outbox.
"""

from __future__ import annotations

import json
import logging
import queue
import threading
import time
from collections.abc import Callable
from dataclasses import dataclass, field
from datetime import tzinfo
from pathlib import Path

import numpy as np

from app.config import ServiceConfig, ViewConfig
from app.counts.ledger import CountLedger
from app.falls.detector import FallDetector, FallSettings
from app.falls.posture import PoseSample
from app.follow.controller import FollowController
from app.follow.mover import BackendMover, RecordingMover, execute
from app.follow.settings import FollowSettings
from app.objects.background import BackgroundWatch
from app.objects.watch import ObjectWatch
from app.objects.zones import object_zones
from app.plates.watch import PlateJob, PlateWatch
from app.reid.appearance import AppearanceSample
from app.reid.journeys import JourneyLinker, JourneySettings
from app.rules.engine import RulesEngine, Update
from app.rules.model import VEHICLES, ArmMode, Box, Detection, EventKind, Frame

logger = logging.getLogger(__name__)

COUNTS_PATH = "/internal/analytics/counts"
JOURNEYS_PATH = "/internal/analytics/journeys"
MEAN_FILE = "reid-mean.json"

REPORT_SECONDS = 5.0
MEAN_SECONDS = 600.0
PLATE_POLL_SECONDS = 0.5


@dataclass
class Follower:
    """Auto-follow of one moving lens: the controller and a worker that sends its commands to the camera.

    Attributes:
        controller: The follow controller.
        mover: The camera mover, retracing moves when the camera keeps no presets.
        commands: Commands waiting for the worker; only the newest move is kept.
        thread: The worker thread.
    """

    controller: FollowController
    mover: RecordingMover
    commands: queue.Queue = field(default_factory=lambda: queue.Queue(maxsize=8))
    thread: threading.Thread | None = None

    def submit(self, command) -> None:
        """Queue a command for the worker, dropping an older waiting move when the queue is full.

        Args:
            command: The command.
        """
        try:
            self.commands.put_nowait(command)
        except queue.Full:
            try:
                self.commands.get_nowait()
            except queue.Empty:
                pass
            self.commands.put_nowait(command)

    def run(self, stopping: threading.Event) -> None:
        """Send queued commands until stopped.

        Args:
            stopping: Set when the service stops.
        """
        while not stopping.is_set():
            try:
                command = self.commands.get(timeout=0.5)
            except queue.Empty:
                continue
            try:
                execute(self.mover, command)
            except Exception:
                logger.exception("A follow command failed")


@dataclass
class ViewFeatures:
    """The features one view runs.

    Attributes:
        config: The view's configuration.
        objects: Objects left and taken, None without object zones.
        background: Background fallback, None without zones that ask for it.
        falls: Fall detection, None when off.
        follow: Auto-follow, None when off.
    """

    config: ViewConfig
    objects: ObjectWatch | None = None
    background: BackgroundWatch | None = None
    falls: FallDetector | None = None
    follow: Follower | None = None


class FeatureHub:
    """Runs the later features of every view.

    Attributes:
        timezone: Time zone of schedules.
        arm: Returns the current arm mode.
        handle: The service's handle, called with a view and the updates it produced.
        send: Queues a delivery to the backend, None without a backend.
        attach: Adds details to a published event and publishes it again.
        reader: Returns the plate reader, built on first use, or None when plates are off.
        picture: Cuts a full-resolution picture for a plate job, or None.
        state_dir: Writable folder for state kept across restarts.
        backend: Backend base URL and token for the follow mover, None without a backend.
        appearance: Whether person appearance and journeys run.
        views: Features per view id.
        ledger: Line crossing counts.
        linker: Journeys across views.
        plates: Plate reading plans.
    """

    def __init__(
        self,
        timezone: tzinfo,
        arm: Callable[[], ArmMode],
        handle: Callable[[ViewConfig, list[Update]], None],
        send: Callable[[str, dict, bool], None] | None,
        attach: Callable[[str, dict], None],
        reader: Callable[[], object | None],
        picture: Callable[[ViewConfig, PlateJob], np.ndarray | None],
        state_dir: Path | None = None,
        backend: tuple[str, str] | None = None,
        appearance: bool = True,
        journeys: JourneySettings | None = None,
    ):
        """Create the hub; call start to run its threads.

        Args:
            timezone: Time zone of schedules.
            arm: Returns the current arm mode.
            handle: The service's handle.
            send: Queues a delivery to the backend, None without a backend.
            attach: Adds details to a published event and publishes it again.
            reader: Returns the plate reader, or None when plates are off.
            picture: Cuts a full-resolution picture for a plate job.
            state_dir: Writable folder for state kept across restarts.
            backend: Backend base URL and token for the follow mover.
            appearance: Whether person appearance and journeys run.
            journeys: Journey linking settings.
        """
        self.timezone = timezone
        self.arm = arm
        self.handle = handle
        self.send = send
        self.attach = attach
        self.reader = reader
        self.picture = picture
        self.state_dir = state_dir
        self.backend = backend
        self.appearance = appearance
        self.views: dict[str, ViewFeatures] = {}
        self.ledger = CountLedger()
        self.linker = JourneyLinker(journeys)
        self.plates = PlateWatch()
        self.lock = threading.RLock()
        self.stopping = threading.Event()
        self.reported = 0.0
        self.mean_saved = time.time()
        self.plate_reads = 0
        self.restore_mean()

    def start(self) -> None:
        """Run the plate reading thread."""
        threading.Thread(target=self.plate_loop, name="plates", daemon=True).start()

    def stop(self) -> None:
        """Stop following and the threads, returning cameras that follow moved."""
        with self.lock:
            for features in self.views.values():
                self.end_follow(features)
        self.save_mean()
        self.stopping.set()

    def apply(self, config: ServiceConfig, now: float | None = None) -> None:
        """Make the features match a configuration.

        Args:
            config: The new configuration.
            now: Current time.
        """
        now = now or time.time()
        with self.lock:
            wanted = {view.id: view for view in config.views if view.enabled}
            for view_id in [key for key in self.views if key not in wanted]:
                self.end_follow(self.views.pop(view_id))
            for view in wanted.values():
                features = self.views.get(view.id) or ViewFeatures(view)
                features.config = view
                self.views[view.id] = features
                zones = object_zones(view.raw.get("zones") or [])
                if zones and view.detects:
                    features.objects = features.objects or ObjectWatch(view.id)
                else:
                    features.objects = None
                if any(zone.background for zone in zones):
                    features.background = features.background or BackgroundWatch(view.id)
                else:
                    features.background = None
                falls = FallSettings.from_view(view.raw)
                if falls.enabled and view.detects:
                    if features.falls is None:
                        features.falls = FallDetector(view.id, falls, self.timezone, self.arm)
                    else:
                        features.falls.settings = falls
                else:
                    features.falls = None
                self.configure_follow(features, FollowSettings.from_view(view.raw), now)
                self.plates.configure(view.id, view.raw if view.detects else {})

    def configure_follow(self, features: ViewFeatures, settings: FollowSettings, now: float) -> None:
        """Start, change or end the auto-follow of a view.

        Args:
            features: The view's features.
            settings: Its follow settings.
            now: Current time.
        """
        if not settings.enabled or self.backend is None or not features.config.detects:
            self.end_follow(features)
            return
        if features.follow is None:
            url, token = self.backend
            mover = RecordingMover(BackendMover(url, token, features.config.camera), use_presets=settings.presets)
            follower = Follower(FollowController(settings, now), mover)
            follower.thread = threading.Thread(
                target=follower.run, args=(self.stopping,), name=f"follow-{features.config.id[:8]}", daemon=True
            )
            follower.thread.start()
            features.follow = follower
            return
        for command in features.follow.controller.configure(settings, now):
            features.follow.submit(command)

    def end_follow(self, features: ViewFeatures) -> None:
        """End a view's auto-follow, stopping the camera and returning it when it moved.

        Args:
            features: The view's features.
        """
        if features.follow is None:
            return
        for command in features.follow.controller.disable():
            features.follow.submit(command)
        features.follow = None

    def on_frame(
        self, view: ViewConfig, at: float, detections: tuple[Detection, ...], engine: RulesEngine | None
    ) -> None:
        """Feed one analysed frame of a view, with objects of every label.

        Args:
            view: The view.
            at: Frame time.
            detections: Tracked objects of every label.
            engine: The view's rules engine, which maps tracker ids to object ids, or None.
        """
        features = self.views.get(view.id)
        if features is None:
            return
        if features.objects is not None:
            updates = features.objects.update(
                Frame(at, detections), view.raw.get("zones") or [], self.arm(), self.timezone
            )
            if updates:
                self.handle(view, updates)
        if features.follow is not None:
            command = features.follow.controller.update(detections, at)
            if command is not None:
                features.follow.submit(command)
        by_track = engine.book.by_track if engine is not None else {}
        vehicles = [
            (by_track.get(item.track_id, item.track_id), item.box) for item in detections if item.label in VEHICLES
        ]
        if vehicles:
            self.plates.observe(view.id, at, vehicles)

    def on_persons(self, views: dict[int, ViewConfig], appearance: list[tuple], poses: list[tuple]) -> None:
        """Feed a batch of person crops results from the pipeline.

        Args:
            views: View of each muxer pad.
            appearance: Tuples of pad, track, time, box, height in pixels and unit vector.
            poses: Tuples of pad, track, time, box and 17 by 3 keypoints.
        """
        if self.appearance:
            for pad, track, at, box, height, vector in appearance:
                view = views.get(pad)
                if view is None:
                    continue
                self.linker.add(
                    AppearanceSample(view.id, view.camera, int(track), float(at), Box(*box), vector, float(height))
                )
        grouped: dict[str, list[PoseSample]] = {}
        latest: dict[str, float] = {}
        for pad, track, at, box, keypoints in poses:
            view = views.get(pad)
            if view is None:
                continue
            grouped.setdefault(view.id, []).append(PoseSample(view.id, int(track), float(at), Box(*box), keypoints))
            latest[view.id] = max(latest.get(view.id, 0.0), float(at))
        for view_id, samples in grouped.items():
            features = self.views.get(view_id)
            if features is None or features.falls is None:
                continue
            updates = features.falls.update(samples, latest[view_id])
            if updates:
                self.handle(features.config, updates)

    def on_keyframe(self, view: ViewConfig, band: np.ndarray, at: float, boxes: list[Box]) -> None:
        """Feed a keyframe band of a view to its background fallback.

        Args:
            view: The view.
            band: Grey keyframe band as float32.
            at: Keyframe time.
            boxes: Boxes of the objects tracked in the view's latest frame.
        """
        features = self.views.get(view.id)
        if features is None or features.background is None:
            return
        updates = features.background.update(band, at, view.raw.get("zones") or [], self.arm(), self.timezone, boxes)
        if updates:
            self.handle(view, updates)

    def on_update(self, update: Update) -> None:
        """Watch event changes for vehicle events that should have their plates read.

        Args:
            update: An event change from any source.
        """
        if update.event.kind == EventKind.VEHICLE:
            self.plates.follow(update.event.as_dict())

    def crossing(self, view: str, line: str, direction: str, label: str, at: float) -> None:
        """Count one line crossing.

        Args:
            view: View id.
            line: Line id.
            direction: in or out.
            label: Object label.
            at: Crossing time.
        """
        self.ledger.add(view, line, direction, label, at)

    def tick(self, now: float) -> None:
        """Run the timed work: fall timers, journey linking and the reports.

        Args:
            now: Current time.
        """
        with self.lock:
            for features in self.views.values():
                if features.falls is not None:
                    updates = features.falls.tick(now)
                    if updates:
                        self.handle(features.config, updates)
        if now - self.reported < REPORT_SECONDS:
            return
        self.reported = now
        journeys, appearances = self.linker.tick(now)
        appearances = [item for item in appearances if len(item.get("embedding") or []) == 512]
        if self.send is not None:
            report = self.ledger.report(now)
            if report is not None:
                self.send(COUNTS_PATH, report, False)
            if journeys or appearances:
                self.send(JOURNEYS_PATH, {"journeys": journeys, "appearances": appearances}, False)
        if now - self.mean_saved >= MEAN_SECONDS:
            self.save_mean()

    def save_mean(self) -> None:
        """Keep the journey linker's running mean in the state folder."""
        self.mean_saved = time.time()
        state = self.linker.mean_state()
        if self.state_dir is None or state is None:
            return
        try:
            target = self.state_dir / MEAN_FILE
            temporary = target.with_suffix(".part")
            temporary.write_text(json.dumps(state))
            temporary.replace(target)
        except OSError as exc:
            logger.warning("Keeping the appearance mean failed: %s", exc)

    def restore_mean(self) -> None:
        """Load the journey linker's running mean from the state folder, if kept."""
        if self.state_dir is None:
            return
        try:
            data = json.loads((self.state_dir / MEAN_FILE).read_text())
        except (OSError, ValueError):
            return
        if self.linker.restore_mean(data):
            logger.info("Restored the appearance mean of %s tracks", data.get("tracks", "some"))

    def plate_loop(self) -> None:
        """Read the plates of due jobs until stopped."""
        while not self.stopping.is_set():
            try:
                self.read_plates(time.time())
            except Exception:
                logger.exception("Reading plates failed")
            self.stopping.wait(PLATE_POLL_SECONDS)

    def read_plates(self, now: float) -> None:
        """Read every due plate job and attach the results to its event.

        Args:
            now: Current time.
        """
        jobs = self.plates.due(now)
        if not jobs:
            return
        reader = self.reader()
        if reader is None:
            return
        for job in jobs:
            features = self.views.get(job.view)
            if features is None:
                continue
            pixels = self.picture(features.config, job)
            if pixels is None:
                continue
            reader.settings = self.plates.reading(job.view)
            read = reader.read(pixels)
            self.plate_reads += 1
            details = self.plates.record(job, read)
            if details is not None:
                self.attach(job.event, details)

    def status(self) -> dict:
        """Return the state of the features for the status endpoint.

        Returns:
            Per view feature states, journeys, plates and counts.
        """
        with self.lock:
            views = {}
            for view_id, features in self.views.items():
                views[view_id] = {
                    "objects": features.objects.snapshot() if features.objects else None,
                    "falls": features.falls.status() if features.falls else None,
                    "follow": features.follow.controller.status() if features.follow else None,
                }
        return {
            "views": views,
            "journeys": self.linker.status(),
            "plates": {
                "waiting": len(self.plates.queue),
                "followed": len(self.plates.followed),
                "reads": self.plate_reads,
            },
            "counts": {"boot": self.ledger.boot, "buckets": len(self.ledger.counts)},
        }
