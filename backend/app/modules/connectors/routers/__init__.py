"""HTTP routers of the connectors module."""

from .connectors import router as connectors_router
from .device import router as connector_device_router

__all__ = ["connector_device_router", "connectors_router"]
