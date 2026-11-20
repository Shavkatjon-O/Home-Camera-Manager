"""FastAPI dependencies of the users module."""

from fastapi import Depends, Request
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.auth.dependencies import get_current_user
from app.core.database import get_db
from app.core.exceptions import TooManyRequests
from app.core.rate_limit import RateLimiter
from app.modules.users.services import AccountService, TokenService, UserService

CREDENTIAL_ATTEMPTS = 20
MAIL_ATTEMPTS = 5
WINDOW_SECONDS = 60.0

credential_limiter = RateLimiter(CREDENTIAL_ATTEMPTS, WINDOW_SECONDS)
mail_limiter = RateLimiter(MAIL_ATTEMPTS, WINDOW_SECONDS)


def client_key(request: Request) -> str:
    """Name the client a request comes from for rate limiting.

    Args:
        request: The request.

    Returns:
        The client address, or unknown.
    """
    return request.client.host if request.client else "unknown"


def limit_credentials(request: Request) -> None:
    """Allow a client a limited number of sign-in and token attempts a minute.

    Args:
        request: The request.

    Raises:
        TooManyRequests: The client is over the limit.
    """
    if not credential_limiter.allow(client_key(request)):
        raise TooManyRequests("rate_limited", "Too many attempts, try again in a minute")


def limit_mail(request: Request) -> None:
    """Allow a client a limited number of requests that send mail a minute.

    Args:
        request: The request.

    Raises:
        TooManyRequests: The client is over the limit.
    """
    if not mail_limiter.allow(client_key(request)):
        raise TooManyRequests("rate_limited", "Too many requests, try again in a minute")


def get_user_service(session: AsyncSession = Depends(get_db)) -> UserService:
    """Build the user service for a request that is not signed in yet.

    Args:
        session: Request-scoped database session.

    Returns:
        User service bound to the session.
    """
    return UserService(session)


def get_token_service(session: AsyncSession = Depends(get_db)) -> TokenService:
    """Build the token service for a request that is not signed in yet.

    Args:
        session: Request-scoped database session.

    Returns:
        The service.
    """
    return TokenService(session)


def get_session_service(
    session: AsyncSession = Depends(get_db), actor: UserContext = Depends(get_current_user)
) -> TokenService:
    """Build the token service for a signed-in request.

    Args:
        session: Request-scoped database session.
        actor: Signed-in user.

    Returns:
        The service.
    """
    return TokenService(session, actor)


def get_public_account_service(session: AsyncSession = Depends(get_db)) -> AccountService:
    """Build the account service for a request that is not signed in.

    Args:
        session: Request-scoped database session.

    Returns:
        The service.
    """
    return AccountService(session)


def get_account_service(
    session: AsyncSession = Depends(get_db), actor: UserContext = Depends(get_current_user)
) -> AccountService:
    """Build the account service for a signed-in request.

    Args:
        session: Request-scoped database session.
        actor: Signed-in user.

    Returns:
        The service.
    """
    return AccountService(session, actor)
