"""Service for floor plans."""

from uuid import UUID

from sqlalchemy import func, select
from sqlalchemy.orm import defer

from app.core.base_service import BaseModelService
from app.core.exceptions import Unprocessable
from app.models import FloorPlan
from app.modules.operations.schemas import (
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
    """Convert plan items to JSON-compatible dicts for storage.

    Args:
        items: Walls, routers or devices.

    Returns:
        One dict per item.
    """
    return [item.model_dump(mode="json") for item in items]


def load_items(model: type, stored: list[dict] | None) -> list:
    """Rebuild plan items from stored dicts.

    Args:
        model: Item schema to validate each dict with.
        stored: Stored dicts, if any.

    Returns:
        One item per dict, empty when nothing is stored.
    """
    return [model.model_validate(item) for item in stored or []]


class FloorPlanService(BaseModelService[FloorPlan]):
    """Create, read, change and delete floor plans.

    Attributes:
        model: Floor plans.
        not_found_code: Error code of an unknown plan.
    """

    model = FloorPlan
    not_found_code = "floor_plan_not_found"

    def fields(self, plan: FloorPlan) -> dict:
        """Collect the response fields shared by plan summaries and full plans.

        Args:
            plan: Plan row.

        Returns:
            Field values for the response schema, with stored JSON turned into items and settings.
        """
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
        """Convert a plan row to the full response schema.

        Args:
            plan: Plan row.

        Returns:
            The plan with its background image.
        """
        return FloorPlanRead(
            **self.fields(plan),
            has_background=plan.background_image is not None,
            background_image=plan.background_image,
        )

    def summary(self, plan: FloorPlan, has_background: bool) -> FloorPlanSummary:
        """Convert a plan row to the listing schema.

        Args:
            plan: Plan row, loaded without its background image.
            has_background: Whether the plan has a background image.

        Returns:
            The plan without its background image.
        """
        return FloorPlanSummary(**self.fields(plan), has_background=has_background)

    async def list_page(self, page: int, page_size: int) -> FloorPlanList:
        """List one page of plans that are not deleted, newest first.

        The background image is not loaded, since it can be large.

        Args:
            page: One-based page number.
            page_size: Number of plans per page.

        Returns:
            Plan summaries on the page with the total count.
        """
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
        """Load one plan.

        Args:
            uuid: Public id of the plan.

        Returns:
            The plan with its background image.
        """
        return self.read(await self.get(uuid))

    async def create(self, payload: FloorPlanCreate) -> FloorPlanRead:
        """Store a new plan.

        Args:
            payload: Plan to create.

        Returns:
            The stored plan.
        """
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
        """Copy the fields an update sends onto a plan row.

        The result is checked as a whole before anything is copied, so a change of size cannot leave an
        existing item outside the plan.

        Args:
            plan: Plan row to change.
            payload: Update whose sent fields are applied.

        Raises:
            Unprocessable: When an item would lie outside the plan after the change.
        """
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
        """Change a plan.

        Args:
            uuid: Public id of the plan.
            payload: Fields to change.

        Returns:
            The updated plan.
        """
        plan = await self.get(uuid)
        self.apply(plan, payload)
        await self.commit()
        await self.session.refresh(plan)
        return self.read(plan)

    async def delete(self, uuid: UUID) -> None:
        """Soft-delete a plan.

        Args:
            uuid: Public id of the plan.
        """
        plan = await self.get(uuid)
        plan.deleted_at = func.now()
        await self.commit()
