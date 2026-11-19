from fastapi import APIRouter

from app.modules.cameras.routers import cameras_router
from app.modules.discovery.routers import discovery_router
from app.modules.floorplans.routers import floorplans_router
from app.modules.health.routers import health_router
from app.modules.tv.routers import tv_router
from app.modules.users.routers import auth_router

v1_routers = APIRouter()
v1_routers.include_router(auth_router, prefix="/auth", tags=["auth"])
v1_routers.include_router(cameras_router, prefix="/cameras", tags=["cameras"])
v1_routers.include_router(discovery_router, prefix="/discovery", tags=["discovery"])
v1_routers.include_router(floorplans_router, prefix="/floorplans", tags=["floorplans"])
v1_routers.include_router(health_router, prefix="/health", tags=["health"])
v1_routers.include_router(tv_router, prefix="/tv", tags=["tv"])
