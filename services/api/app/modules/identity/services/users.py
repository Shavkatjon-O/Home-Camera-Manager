"""User service: account lookup and password sign-in."""

from sqlalchemy import or_, select

from app.core.base_service import BaseModelService
from app.core.exceptions import Forbidden, Unauthorized
from app.core.security import placeholder_hash, verify_password
from app.models import User

__all__ = ["UserService", "require_verified"]


def require_verified(user: User) -> None:
    """Refuse an account whose email address is not confirmed yet.

    Accounts created from the settings have no email address and need no confirmation.

    Args:
        user: The account.

    Raises:
        Forbidden: The address is not confirmed.
    """
    if user.email is not None and user.email_verified_at is None:
        raise Forbidden("email_not_verified", "Confirm your email address first; the link is in your mail")


class UserService(BaseModelService[User]):
    """Find users and check their credentials.

    Attributes:
        model: Users.
        not_found_code: Error code of an unknown user.
    """

    model = User
    not_found_code = "user_not_found"

    async def by_username(self, username: str) -> User | None:
        """Load a live user by sign-in name or email address.

        Args:
            username: Sign-in name or email address to look up.

        Returns:
            The user, or None when no live user has that name or address.
        """
        lowered = username.lower()
        return await self.session.scalar(
            select(User).where(or_(User.username == username, User.email == lowered), User.deleted_at.is_(None))
        )

    async def authenticate(self, username: str, password: str) -> User:
        """Check a sign-in name or email address and a password.

        A password check against a placeholder hash runs when the user does not exist, so the failure
        looks the same whether the name or the password was wrong.

        Args:
            username: Sign-in name or email address; surrounding whitespace is ignored.
            password: Password to check.

        Returns:
            The user the credentials belong to.

        Raises:
            Unauthorized: The user does not exist or the password is wrong.
            Forbidden: The user's email address is not confirmed yet.
        """
        user = await self.by_username(username.strip())
        if user is None:
            verify_password(placeholder_hash(), password)
            raise Unauthorized("invalid_credentials", "The username or password is wrong")
        if not verify_password(user.password_hash, password):
            raise Unauthorized("invalid_credentials", "The username or password is wrong")
        require_verified(user)
        return user
