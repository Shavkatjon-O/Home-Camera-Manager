"""HTTP routers of the devices module."""

from .cameras import router as cameras_router
from .connector_device import router as connector_device_router
from .connectors import router as connectors_router
from .control import router as control_router
from .discovery import router as discovery_router

__all__ = ["cameras_router", "connector_device_router", "connectors_router", "control_router", "discovery_router"]
