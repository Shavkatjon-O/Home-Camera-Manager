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
    user = await service.authenticate(payload.username, payload.password)
    set_session_cookie(response, create_session_token(user.uuid))
    return SessionUser.model_validate(user)


@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
async def logout() -> Response:
    response = Response(status_code=status.HTTP_204_NO_CONTENT)
    clear_session_cookie(response)
    return response


@router.get("/me", response_model=SessionUser)
async def me(actor: UserContext = Depends(get_current_user)) -> SessionUser:
    return SessionUser(uuid=actor.uuid, username=actor.username)


@router.api_route("/verify", methods=["GET", "HEAD"], status_code=status.HTTP_204_NO_CONTENT)
async def verify(actor: UserContext = Depends(get_current_user)) -> Response:
    return Response(status_code=status.HTTP_204_NO_CONTENT)
