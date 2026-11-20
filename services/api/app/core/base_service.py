"""Base class for services that load and save one model."""

from typing import Generic, TypeVar
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.core.exceptions import NotFound
from app.models.base import BaseModel

ModelT = TypeVar("ModelT", bound=BaseModel)


class BaseModelService(Generic[ModelT]):
    """Look up live rows of one model and commit the service's transaction.

    Attributes:
        model: Model class the service manages.
        not_found_code: Error code raised when a row does not exist.
        session: Database session the service works in.
        actor: User making the request, if any.
    """

    model: type[ModelT]
    not_found_code = "not_found"

    def __init__(self, session: AsyncSession, actor: UserContext | None = None):
        """Bind the service to a session and the user acting through it.

        Args:
            session: Database session the service works in.
            actor: User making the request, if any.
        """
        self.session = session
        self.actor = actor

    async def find(self, uuid: UUID) -> ModelT | None:
        """Load a row that has not been soft-deleted.

        Args:
            uuid: Public id of the row.

        Returns:
            The row, or None when it does not exist or is deleted.
        """
        return await self.session.scalar(
            select(self.model).where(self.model.uuid == uuid, self.model.deleted_at.is_(None))
        )

    async def get(self, uuid: UUID) -> ModelT:
        """Load a row that has not been soft-deleted, or fail.

        Args:
            uuid: Public id of the row.

        Returns:
            The row.

        Raises:
            NotFound: The row does not exist or is deleted.
        """
        item = await self.find(uuid)
        if item is None:
            raise NotFound(self.not_found_code, f"{self.model.__name__} {uuid} does not exist")
        return item

    async def commit(self) -> None:
        """Commit the session's transaction."""
        await self.session.commit()
