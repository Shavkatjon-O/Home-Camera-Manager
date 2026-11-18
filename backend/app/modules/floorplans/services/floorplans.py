from uuid import UUID

from sqlalchemy import func, select
from sqlalchemy.orm import defer

from app.core.base_service import BaseModelService
from app.core.exceptions import Unprocessable
from app.models import FloorPlan
from app.modules.floorplans.schemas import (
    AccessPoint,
    Device,
    FloorPlanCreate,
    FloorPlanList,
    FloorPlanRead,
    FloorPlanSummary,
    FloorPlanUpdate,
    PlanSettings,
    Wall,
    outside_plan,
)

__all__ = ["FloorPlanService"]

ITEM_FIELDS = {"walls": Wall, "access_points": AccessPoint, "devices": Device}


def dump_items(items: list) -> list[dict]:
    return [item.model_dump(mode="json") for item in items]


def load_items(model: type, stored: list[dict] | None) -> list:
    return [model.model_validate(item) for item in stored or []]


class FloorPlanService(BaseModelService[FloorPlan]):
    model = FloorPlan
    not_found_code = "floor_plan_not_found"

    def fields(self, plan: FloorPlan) -> dict:
        return {
            "uuid": plan.uuid,
            "name": plan.name,
            "width_m": plan.width_m,
            "height_m": plan.height_m,
            "walls": load_items(Wall, plan.walls),
            "access_points": load_items(AccessPoint, plan.access_points),
            "devices": load_items(Device, plan.devices),
            "settings": PlanSettings.model_validate(plan.settings or {}),
            "background_opacity": plan.background_opacity,
            "created_at": plan.created_at,
            "updated_at": plan.updated_at,
        }

    def read(self, plan: FloorPlan) -> FloorPlanRead:
        return FloorPlanRead(
            **self.fields(plan),
            has_background=plan.background_image is not None,
            background_image=plan.background_image,
        )

    def summary(self, plan: FloorPlan, has_background: bool) -> FloorPlanSummary:
        return FloorPlanSummary(**self.fields(plan), has_background=has_background)

    async def list_page(self, page: int, page_size: int) -> FloorPlanList:
        total = await self.session.scalar(
            select(func.count()).select_from(FloorPlan).where(FloorPlan.deleted_at.is_(None))
        )
        result = await self.session.execute(
            select(FloorPlan, FloorPlan.background_image.is_not(None).label("has_background"))
            .options(defer(FloorPlan.background_image))
            .where(FloorPlan.deleted_at.is_(None))
            .order_by(FloorPlan.created_at.desc(), FloorPlan.id.desc())
            .offset((page - 1) * page_size)
            .limit(page_size)
        )
        return FloorPlanList(
            items=[self.summary(plan, bool(has_background)) for plan, has_background in result.all()],
            total=total or 0,
            page=page,
            page_size=page_size,
        )

    async def detail(self, uuid: UUID) -> FloorPlanRead:
        return self.read(await self.get(uuid))

    async def create(self, payload: FloorPlanCreate) -> FloorPlanRead:
        plan = FloorPlan(
            name=payload.name,
            width_m=payload.width_m,
            height_m=payload.height_m,
            walls=dump_items(payload.walls),
            access_points=dump_items(payload.access_points),
            devices=dump_items(payload.devices),
            settings=payload.settings.model_dump(mode="json"),
            background_image=payload.background_image,
            background_opacity=payload.background_opacity,
        )
        self.session.add(plan)
        await self.commit()
        await self.session.refresh(plan)
        return self.read(plan)

    def apply(self, plan: FloorPlan, payload: FloorPlanUpdate) -> None:
        changed = payload.model_fields_set
        width_m = payload.width_m if "width_m" in changed else plan.width_m
        height_m = payload.height_m if "height_m" in changed else plan.height_m
        items = {
            field: getattr(payload, field) if field in changed else load_items(model, getattr(plan, field))
            for field, model in ITEM_FIELDS.items()
        }
        problem = outside_plan(width_m, height_m, items["walls"], items["access_points"], items["devices"])
        if problem is not None:
            raise Unprocessable("outside_plan", problem)
        for field in changed:
            value = getattr(payload, field)
            if field in ITEM_FIELDS:
                value = dump_items(value)
            elif field == "settings":
                value = value.model_dump(mode="json")
            setattr(plan, field, value)

    async def update(self, uuid: UUID, payload: FloorPlanUpdate) -> FloorPlanRead:
        plan = await self.get(uuid)
        self.apply(plan, payload)
        await self.commit()
        await self.session.refresh(plan)
        return self.read(plan)

    async def delete(self, uuid: UUID) -> None:
        plan = await self.get(uuid)
        plan.deleted_at = func.now()
        await self.commit()
