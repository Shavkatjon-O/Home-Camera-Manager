"""Service configuration: the cameras, their analytics views and the arm mode.

The configuration comes from a JSON file during development and from the backend in production; both have the same
shape::

    {
      "arm_mode": "schedule",
      "cameras": [
        {
          "id": "0f8f...", "name": "Camera A", "stream": "0f8f..._main", "lenses": 1,
          "views": [{"id": "0f8f...-0", "name": "Camera A", "lens": 0, "profile": "perimeter",
                     "enabled": true, "fps": 8, "zones": [], "lines": []}]
        }
      ]
    }

A lens of 0 means the whole frame; lenses 1 and up are the bands of a multi-lens camera, counted from the top.
"""

from __future__ import annotations

import hashlib
import json
from dataclasses import dataclass, field

from app.profiles import PROFILES, Profile
from app.rules.model import ArmMode, ViewRules


@dataclass(frozen=True)
class ViewConfig:
    """One analytics view: a camera, or one lens of a multi-lens camera.

    Attributes:
        id: Stable view id.
        name: Display name.
        camera: Camera id the view belongs to.
        lens: 0 for the whole frame, otherwise the lens band counted from 1 at the top.
        lenses: Number of lens bands the camera frame holds.
        profile: Pipeline profile.
        enabled: Whether the view is analysed.
        fps: Analysis rate in frames per second.
        rules: Zones, lines and tuning.
        faces: Whether the face stage runs on the view.
        raw: The view's configuration as received, for change detection.
    """

    id: str
    name: str
    camera: str
    lens: int
    lenses: int
    profile: Profile
    enabled: bool
    fps: float
    rules: ViewRules
    faces: bool = False
    raw: dict = field(default_factory=dict, compare=False)

    @property
    def detects(self) -> bool:
        """bool: True when the view needs the detector and tracker."""
        return self.enabled and self.profile.detect

    @property
    def recognises(self) -> bool:
        """bool: True when the view needs the face stage."""
        return self.detects and self.faces

    def pipeline_key(self) -> tuple:
        """Return what the DeepStream pipeline depends on, so rule edits never restart it.

        Returns:
            A hashable tuple of the view's pipeline settings.
        """
        return (self.id, self.camera, self.lens, self.lenses, self.detects, self.recognises, round(self.fps, 2))


@dataclass(frozen=True)
class CameraConfig:
    """A camera and its views.

    Attributes:
        id: Camera id.
        name: Display name.
        stream: go2rtc stream name of the camera's original stream.
        lenses: Number of lens bands in its frame.
        views: Its analytics views.
    """

    id: str
    name: str
    stream: str
    lenses: int
    views: tuple[ViewConfig, ...]


@dataclass(frozen=True)
class ServiceConfig:
    """Everything the service runs.

    Attributes:
        arm_mode: Global arm mode.
        cameras: Cameras with their views.
        version: Digest of the configuration, which changes whenever any part of it changes.
    """

    arm_mode: ArmMode
    cameras: tuple[CameraConfig, ...]
    version: str

    @property
    def views(self) -> list[ViewConfig]:
        """list[ViewConfig]: Every view of every camera in camera order."""
        return [view for camera in self.cameras for view in camera.views]

    def camera(self, camera_id: str) -> CameraConfig | None:
        """Look up a camera by id.

        Args:
            camera_id: The camera id.

        Returns:
            The camera, or None.
        """
        return next((camera for camera in self.cameras if camera.id == camera_id), None)

    def pipeline_key(self) -> tuple:
        """Return what the DeepStream pipeline depends on.

        Returns:
            A hashable tuple covering every view that needs detection and the streams they read.
        """
        streams = tuple((camera.id, camera.stream) for camera in self.cameras)
        return (streams, tuple(view.pipeline_key() for view in self.views if view.detects))


def parse_view(camera: dict, data: dict, default_fps: float) -> ViewConfig:
    """Build a view from its configuration.

    Args:
        camera: The camera's configuration.
        data: The view's configuration.
        default_fps: Analysis rate when the view sets none.

    Returns:
        The view.

    Raises:
        ValueError: If the profile is unknown or the lens is outside the camera's lenses.
    """
    lenses = int(camera.get("lenses") or 1)
    lens = int(data.get("lens") or 0)
    if lens < 0 or lens > lenses or (lenses > 1 and lens == 0):
        raise ValueError(f"View {data.get('id')} has lens {lens} but its camera has {lenses}")
    profile_name = str(data.get("profile") or "perimeter")
    if profile_name not in PROFILES:
        raise ValueError(f"Unknown profile {profile_name!r}, known: {', '.join(PROFILES)}")
    return ViewConfig(
        id=str(data["id"]),
        name=str(data.get("name") or data["id"]),
        camera=str(camera["id"]),
        lens=lens,
        lenses=lenses,
        profile=PROFILES[profile_name],
        enabled=bool(data.get("enabled", True)),
        fps=float(data.get("fps") or default_fps),
        rules=ViewRules.from_dict(data),
        faces=bool(data.get("faces", PROFILES[profile_name].faces)),
        raw=data,
    )


def parse_config(data: dict, default_fps: float = 8.0) -> ServiceConfig:
    """Build the service configuration from its JSON form.

    Args:
        data: The configuration mapping.
        default_fps: Analysis rate for views that set none.

    Returns:
        The configuration.
    """
    cameras = []
    for camera in data.get("cameras") or []:
        views = tuple(parse_view(camera, view, default_fps) for view in camera.get("views") or [])
        cameras.append(
            CameraConfig(
                id=str(camera["id"]),
                name=str(camera.get("name") or camera["id"]),
                stream=str(camera["stream"]),
                lenses=int(camera.get("lenses") or 1),
                views=views,
            )
        )
    digest = hashlib.sha256(json.dumps(data, sort_keys=True).encode()).hexdigest()[:16]
    return ServiceConfig(
        arm_mode=ArmMode(data.get("arm_mode", ArmMode.DISARMED)), cameras=tuple(cameras), version=digest
    )
