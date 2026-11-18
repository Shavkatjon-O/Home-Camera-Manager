from sqlalchemy import select

from app.core.base_service import BaseModelService
from app.core.exceptions import Unauthorized
from app.core.security import placeholder_hash, verify_password
from app.models import User

__all__ = ["UserService"]


class UserService(BaseModelService[User]):
    model = User
    not_found_code = "user_not_found"

    async def by_username(self, username: str) -> User | None:
        return await self.session.scalar(select(User).where(User.username == username, User.deleted_at.is_(None)))

    async def authenticate(self, username: str, password: str) -> User:
        user = await self.by_username(username.strip())
        if user is None:
            verify_password(placeholder_hash(), password)
            raise Unauthorized("invalid_credentials", "The username or password is wrong")
        if not verify_password(user.password_hash, password):
            raise Unauthorized("invalid_credentials", "The username or password is wrong")
        return user
