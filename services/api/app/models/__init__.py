"""Model registry: every table's model, imported in one place for Alembic and the import order."""

from app.models.base import BaseModel
from app.modules.alerting.models.settings import AnalyticsSettings
from app.modules.alerting.models.targets import PushTarget
from app.modules.analytics.models.lines import AnalyticsLine
from app.modules.analytics.models.views import AnalyticsView
from app.modules.analytics.models.zones import AnalyticsZone
from app.modules.devices.models.cameras import Camera
from app.modules.devices.models.connectors import Connector
from app.modules.devices.models.devices import Device
from app.modules.devices.models.discovered import DiscoveredCamera
from app.modules.devices.models.pairing_attempts import PairingAttempt
from app.modules.devices.models.pairings import ConnectorPairing
from app.modules.events.models.events import Event
from app.modules.identity.models.email_tokens import EmailToken
from app.modules.identity.models.refresh_tokens import RefreshToken
from app.modules.identity.models.sessions import AuthSession
from app.modules.identity.models.users import User
from app.modules.insights.models.areas import AnalyticsArea
from app.modules.insights.models.counts import AnalyticsCount
from app.modules.investigation.models.appearances import AnalyticsAppearance
from app.modules.investigation.models.clusters import UnknownCluster
from app.modules.investigation.models.journeys import AnalyticsJourney
from app.modules.investigation.models.people import Person
from app.modules.investigation.models.samples import FaceSample
from app.modules.operations.models.devices import NetworkDevice
from app.modules.operations.models.floorplans import FloorPlan
from app.modules.operations.models.links import CameraLink
from app.modules.operations.models.outages import Outage
from app.modules.operations.models.samples import HealthSample
from app.modules.tenancy.models.invitations import Invitation
from app.modules.tenancy.models.memberships import Membership, MembershipSite
from app.modules.tenancy.models.organisations import Organisation
from app.modules.tenancy.models.sites import Site
from app.modules.tv.models.devices import TvDevice
from app.modules.tv.models.pairings import TvPairing

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
    "Device",
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
    "PairingAttempt",
    "Person",
    "PushTarget",
    "RefreshToken",
    "Site",
    "TvDevice",
    "TvPairing",
    "UnknownCluster",
    "User",
]
