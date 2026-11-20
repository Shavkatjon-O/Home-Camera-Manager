"""Aggregator of every module's router under /api/v1, each with its stable tag."""

from fastapi import APIRouter

from app.modules.analytics.routers import analytics_router
from app.modules.cameras.routers import cameras_router
from app.modules.connectors.routers import connector_device_router, connectors_router
from app.modules.control.routers import control_router
from app.modules.discovery.routers import discovery_router
from app.modules.events.routers import events_router
from app.modules.floorplans.routers import floorplans_router
from app.modules.health.routers import health_router
from app.modules.live.routers import live_router
from app.modules.organisations.routers import invitations_router, members_router, organisations_router, sites_router
from app.modules.people.routers import people_router
from app.modules.push.routers import push_router
from app.modules.search.routers import search_router
from app.modules.tv.routers import tv_router
from app.modules.users.routers import auth_router

v1_routers = APIRouter()
v1_routers.include_router(auth_router, prefix="/auth", tags=["auth"])
v1_routers.include_router(organisations_router, prefix="/organisations", tags=["organisations"])
v1_routers.include_router(members_router, prefix="/organisations", tags=["members"])
v1_routers.include_router(sites_router, tags=["sites"])
v1_routers.include_router(invitations_router, tags=["invitations"])
v1_routers.include_router(analytics_router, prefix="/analytics", tags=["analytics"])
v1_routers.include_router(cameras_router, prefix="/cameras", tags=["cameras"])
v1_routers.include_router(control_router, prefix="/cameras", tags=["control"])
v1_routers.include_router(live_router, tags=["live"])
v1_routers.include_router(connectors_router, prefix="/connectors", tags=["connectors"])
v1_routers.include_router(connector_device_router, prefix="/connector", tags=["connector-device"])
v1_routers.include_router(discovery_router, prefix="/discovery", tags=["discovery"])
v1_routers.include_router(events_router, prefix="/events", tags=["events"])
v1_routers.include_router(floorplans_router, prefix="/floorplans", tags=["floorplans"])
v1_routers.include_router(health_router, prefix="/health", tags=["health"])
v1_routers.include_router(people_router, prefix="/people", tags=["people"])
v1_routers.include_router(search_router, prefix="/search", tags=["search"])
v1_routers.include_router(push_router, prefix="/push", tags=["push"])
v1_routers.include_router(tv_router, prefix="/tv", tags=["tv"])
