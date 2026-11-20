"""Model registry: every table's model, imported in one place for Alembic and the import order."""

from app.models.base import BaseModel
from app.modules.analytics.models.lines import AnalyticsLine
from app.modules.analytics.models.settings import AnalyticsSettings
from app.modules.analytics.models.views import AnalyticsView
from app.modules.analytics.models.zones import AnalyticsZone
from app.modules.cameras.models.cameras import Camera
from app.modules.events.models.events import Event
from app.modules.floorplans.models.floorplans import FloorPlan
from app.modules.health.models.devices import NetworkDevice
from app.modules.health.models.links import CameraLink
from app.modules.health.models.outages import Outage
from app.modules.health.models.samples import HealthSample
from app.modules.people.models.clusters import UnknownCluster
from app.modules.people.models.people import Person
from app.modules.people.models.samples import FaceSample
from app.modules.tv.models.devices import TvDevice
from app.modules.tv.models.pairings import TvPairing
from app.modules.users.models.users import User

__all__ = [
    "AnalyticsLine",
    "AnalyticsSettings",
    "AnalyticsView",
    "AnalyticsZone",
    "BaseModel",
    "Camera",
    "CameraLink",
    "Event",
    "FaceSample",
    "FloorPlan",
    "HealthSample",
    "NetworkDevice",
    "Outage",
    "Person",
    "TvDevice",
    "TvPairing",
    "UnknownCluster",
    "User",
]
