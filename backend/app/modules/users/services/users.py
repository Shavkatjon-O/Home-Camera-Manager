"""User service: account lookup and password sign-in."""

from sqlalchemy import select

from app.core.base_service import BaseModelService
from app.core.exceptions import Unauthorized
from app.core.security import placeholder_hash, verify_password
from app.models import User

__all__ = ["UserService"]


class UserService(BaseModelService[User]):
    """Find users and check their credentials."""

    model = User
    not_found_code = "user_not_found"

    async def by_username(self, username: str) -> User | None:
        """Load a live user by sign-in name.

        Args:
            username: Sign-in name to look up.

        Returns:
            The user, or None when no live user has that name.
        """
        return await self.session.scalar(select(User).where(User.username == username, User.deleted_at.is_(None)))

    async def authenticate(self, username: str, password: str) -> User:
        """Check a username and password.

        A password check against a placeholder hash runs when the user does not exist, so the failure
        looks the same whether the name or the password was wrong.

        Args:
            username: Sign-in name; surrounding whitespace is ignored.
            password: Password to check.

        Returns:
            The user the credentials belong to.

        Raises:
            Unauthorized: The user does not exist or the password is wrong.
        """
        user = await self.by_username(username.strip())
        if user is None:
            verify_password(placeholder_hash(), password)
            raise Unauthorized("invalid_credentials", "The username or password is wrong")
        if not verify_password(user.password_hash, password):
            raise Unauthorized("invalid_credentials", "The username or password is wrong")
        return user
