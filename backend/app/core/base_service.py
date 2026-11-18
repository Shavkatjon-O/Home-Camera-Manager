from typing import Generic, TypeVar
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.core.exceptions import NotFound
from app.models.base import BaseModel

ModelT = TypeVar("ModelT", bound=BaseModel)


class BaseModelService(Generic[ModelT]):
    model: type[ModelT]
    not_found_code = "not_found"

    def __init__(self, session: AsyncSession, actor: UserContext | None = None):
        self.session = session
        self.actor = actor

    async def find(self, uuid: UUID) -> ModelT | None:
        return await self.session.scalar(
            select(self.model).where(self.model.uuid == uuid, self.model.deleted_at.is_(None))
        )

    async def get(self, uuid: UUID) -> ModelT:
        item = await self.find(uuid)
        if item is None:
            raise NotFound(self.not_found_code, f"{self.model.__name__} {uuid} does not exist")
        return item

    async def commit(self) -> None:
        await self.session.commit()
