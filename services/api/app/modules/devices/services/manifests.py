"""Capability manifests of cameras registered by hand, built from their brand and settings."""

from app.models import Camera
from camera_adapters.manifest import CapabilityManifest
from camera_adapters.registry import default_registry

__all__ = ["camera_manifest"]


def camera_manifest(camera: Camera) -> CapabilityManifest:
    """Build the manifest a camera's adapter gives for what is known about it without identifying it.

    Args:
        camera: Camera row.

    Returns:
        The manifest; an adapter the registry does not know falls back to plain RTSP.
    """
    registry = default_registry()
    name = camera.brand if camera.brand in registry.adapters else "rtsp"
    return registry.manifest(name, ptz=bool(camera.ptz_enabled), sub=bool(camera.sub_path))
