"""Sign-in, sign-out and session check endpoints."""

from fastapi import APIRouter, Depends, Response, status

from app.auth.context import UserContext
from app.auth.dependencies import get_current_user
from app.core.security import clear_session_cookie, create_session_token, set_session_cookie
from app.modules.users.deps import get_user_service
from app.modules.users.schemas import LoginRequest, SessionUser
from app.modules.users.services import UserService

router = APIRouter()


@router.post("/login", response_model=SessionUser)
async def login(
    payload: LoginRequest,
    response: Response,
    service: UserService = Depends(get_user_service),
) -> SessionUser:
    """Sign in with a username and password and set the session cookie.

    Args:
        payload: Credentials to check.
        response: Response the session cookie is set on.
        service: User service for the request.

    Returns:
        The signed-in user.
    """
    user = await service.authenticate(payload.username, payload.password)
    set_session_cookie(response, create_session_token(user.uuid))
    return SessionUser.model_validate(user)


@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
async def logout() -> Response:
    """Sign out by clearing the session cookie.

    Returns:
        Empty response that clears the cookie.
    """
    response = Response(status_code=status.HTTP_204_NO_CONTENT)
    clear_session_cookie(response)
    return response


@router.get("/me", response_model=SessionUser)
async def me(actor: UserContext = Depends(get_current_user)) -> SessionUser:
    """Return the signed-in user.

    Args:
        actor: Signed-in user making the request.

    Returns:
        Public identity of the signed-in user.
    """
    return SessionUser(uuid=actor.uuid, username=actor.username)


@router.api_route("/verify", methods=["GET", "HEAD"], status_code=status.HTTP_204_NO_CONTENT)
async def verify(actor: UserContext = Depends(get_current_user)) -> Response:
    """Answer with an empty success when the request carries a valid session.

    Args:
        actor: Signed-in user making the request.

    Returns:
        Empty response; the dependency rejects requests without a session.
    """
    return Response(status_code=status.HTTP_204_NO_CONTENT)
