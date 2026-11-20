"""Model registry: every table's model, imported in one place for Alembic and the import order."""

from app.models.base import BaseModel
from app.modules.analytics.models.appearances import AnalyticsAppearance
from app.modules.analytics.models.areas import AnalyticsArea
from app.modules.analytics.models.counts import AnalyticsCount
from app.modules.analytics.models.journeys import AnalyticsJourney
from app.modules.analytics.models.lines import AnalyticsLine
from app.modules.analytics.models.settings import AnalyticsSettings
from app.modules.analytics.models.views import AnalyticsView
from app.modules.analytics.models.zones import AnalyticsZone
from app.modules.cameras.models.cameras import Camera
from app.modules.connectors.models.connectors import Connector
from app.modules.connectors.models.discovered import DiscoveredCamera
from app.modules.connectors.models.pairings import ConnectorPairing
from app.modules.events.models.events import Event
from app.modules.floorplans.models.floorplans import FloorPlan
from app.modules.health.models.devices import NetworkDevice
from app.modules.health.models.links import CameraLink
from app.modules.health.models.outages import Outage
from app.modules.health.models.samples import HealthSample
from app.modules.organisations.models.invitations import Invitation
from app.modules.organisations.models.memberships import Membership, MembershipSite
from app.modules.organisations.models.organisations import Organisation
from app.modules.organisations.models.sites import Site
from app.modules.people.models.clusters import UnknownCluster
from app.modules.people.models.people import Person
from app.modules.people.models.samples import FaceSample
from app.modules.push.models.targets import PushTarget
from app.modules.tv.models.devices import TvDevice
from app.modules.tv.models.pairings import TvPairing
from app.modules.users.models.email_tokens import EmailToken
from app.modules.users.models.refresh_tokens import RefreshToken
from app.modules.users.models.sessions import AuthSession
from app.modules.users.models.users import User

__all__ = [
    "AnalyticsAppearance",
    "AnalyticsArea",
    "AnalyticsCount",
    "AnalyticsJourney",
    "AnalyticsLine",
    "AnalyticsSettings",
    "AnalyticsView",
    "AnalyticsZone",
    "AuthSession",
    "BaseModel",
    "Camera",
    "CameraLink",
    "Connector",
    "ConnectorPairing",
    "DiscoveredCamera",
    "EmailToken",
    "Event",
    "FaceSample",
    "FloorPlan",
    "HealthSample",
    "Invitation",
    "Membership",
    "MembershipSite",
    "NetworkDevice",
    "Organisation",
    "Outage",
    "Person",
    "PushTarget",
    "RefreshToken",
    "Site",
    "TvDevice",
    "TvPairing",
    "UnknownCluster",
    "User",
]
