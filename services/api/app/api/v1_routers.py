"""Aggregator of every domain's routers under /api/v1, each at its stable prefix and tag."""

from fastapi import APIRouter

from app.modules.alerting.routers import arm_router, push_router
from app.modules.analytics.routers import analytics_router
from app.modules.devices.routers import (
    cameras_router,
    connector_device_router,
    connectors_router,
    control_router,
    devices_router,
    discovery_router,
    pairing_router,
)
from app.modules.events.routers import events_router
from app.modules.identity.routers import auth_router
from app.modules.insights.routers import counts_router
from app.modules.investigation.routers import journeys_router, people_router, search_router
from app.modules.media.routers import live_router
from app.modules.operations.routers import floorplans_router, health_router
from app.modules.tenancy.routers import invitations_router, members_router, organisations_router, sites_router
from app.modules.tv.routers import tv_router

v1_routers = APIRouter()
v1_routers.include_router(auth_router, prefix="/auth", tags=["auth"])
v1_routers.include_router(organisations_router, prefix="/organisations", tags=["organisations"])
v1_routers.include_router(members_router, prefix="/organisations", tags=["members"])
v1_routers.include_router(sites_router, tags=["sites"])
v1_routers.include_router(invitations_router, tags=["invitations"])
v1_routers.include_router(arm_router, prefix="/analytics", tags=["analytics"])
v1_routers.include_router(analytics_router, prefix="/analytics", tags=["analytics"])
v1_routers.include_router(counts_router, prefix="/analytics", tags=["analytics"])
v1_routers.include_router(journeys_router, prefix="/analytics", tags=["analytics"])
v1_routers.include_router(cameras_router, prefix="/cameras", tags=["cameras"])
v1_routers.include_router(control_router, prefix="/cameras", tags=["control"])
v1_routers.include_router(live_router, tags=["live"])
v1_routers.include_router(connectors_router, prefix="/connectors", tags=["connectors"])
v1_routers.include_router(connector_device_router, prefix="/connector", tags=["connector-device"])
v1_routers.include_router(discovery_router, prefix="/discovery", tags=["discovery"])
v1_routers.include_router(devices_router, prefix="/devices", tags=["devices"])
v1_routers.include_router(pairing_router, prefix="/pairing", tags=["pairing"])
v1_routers.include_router(events_router, prefix="/events", tags=["events"])
v1_routers.include_router(floorplans_router, prefix="/floorplans", tags=["floorplans"])
v1_routers.include_router(health_router, prefix="/health", tags=["health"])
v1_routers.include_router(people_router, prefix="/people", tags=["people"])
v1_routers.include_router(search_router, prefix="/search", tags=["search"])
v1_routers.include_router(push_router, prefix="/push", tags=["push"])
v1_routers.include_router(tv_router, prefix="/tv", tags=["tv"])
