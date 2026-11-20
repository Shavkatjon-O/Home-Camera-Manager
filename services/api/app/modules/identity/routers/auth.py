"""Sign-in, accounts, app tokens and device sessions."""

from urllib.parse import parse_qs, urlsplit
from uuid import UUID

from fastapi import APIRouter, Depends, Request, Response, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.auth.dependencies import get_current_user
from app.core.database import get_db
from app.core.exceptions import Forbidden
from app.core.security import clear_session_cookie, create_session_token, set_session_cookie
from app.core.tokens import jwks
from app.models import Camera
from app.modules.users.deps import (
    get_account_service,
    get_public_account_service,
    get_session_service,
    get_token_service,
    get_user_service,
    limit_credentials,
    limit_mail,
)
from app.modules.users.schemas import (
    AccountDelete,
    AccountRead,
    AccountRegister,
    AccountUpdate,
    EmailRequest,
    JwkSet,
    LoginRequest,
    PasswordChange,
    PasswordReset,
    RefreshRequest,
    SessionList,
    SessionUser,
    TokenPair,
    TokenRequest,
    VerifyEmail,
)
from app.modules.users.services import AccountService, TokenService, UserService
from app.streaming.names import is_managed
from app.tenancy.access import accessible_sites

router = APIRouter()

ORIGINAL_URI = "X-Original-URI"


def no_content() -> Response:
    """Build an empty 204 response.

    Returns:
        Response with the no content status.
    """
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post("/login", response_model=SessionUser, dependencies=[Depends(limit_credentials)])
async def login(
    payload: LoginRequest,
    response: Response,
    service: UserService = Depends(get_user_service),
) -> SessionUser:
    """Sign in to the web app with a sign-in name or email address and a password, setting the session cookie.

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


@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT, response_class=Response)
async def logout() -> Response:
    """Sign out of the web app by clearing the session cookie.

    Returns:
        Empty response that clears the cookie.
    """
    response = no_content()
    clear_session_cookie(response)
    return response


@router.post(
    "/register",
    response_model=AccountRead,
    status_code=status.HTTP_201_CREATED,
    dependencies=[Depends(limit_mail)],
)
async def register(
    payload: AccountRegister, service: AccountService = Depends(get_public_account_service)
) -> AccountRead:
    """Create an account and mail the link that confirms its address.

    Args:
        payload: The new account.
        service: Account service.

    Returns:
        The account, not yet confirmed.
    """
    return await service.register(payload)


@router.post("/verify-email", response_model=AccountRead, dependencies=[Depends(limit_credentials)])
async def verify_email(
    payload: VerifyEmail, service: AccountService = Depends(get_public_account_service)
) -> AccountRead:
    """Confirm an email address with the token of its link.

    Args:
        payload: The token.
        service: Account service.

    Returns:
        The confirmed account.
    """
    return await service.verify(payload.token)


@router.post(
    "/verify-email/resend",
    status_code=status.HTTP_204_NO_CONTENT,
    response_class=Response,
    dependencies=[Depends(limit_mail)],
)
async def resend_verification(
    payload: EmailRequest, service: AccountService = Depends(get_public_account_service)
) -> Response:
    """Mail a new confirmation link; the answer is the same for every address.

    Args:
        payload: The address.
        service: Account service.

    Returns:
        Empty response.
    """
    await service.resend(payload.email)
    return no_content()


@router.post(
    "/password/forgot",
    status_code=status.HTTP_204_NO_CONTENT,
    response_class=Response,
    dependencies=[Depends(limit_mail)],
)
async def forgot_password(
    payload: EmailRequest, service: AccountService = Depends(get_public_account_service)
) -> Response:
    """Mail a password reset link; the answer is the same for every address.

    Args:
        payload: The address.
        service: Account service.

    Returns:
        Empty response.
    """
    await service.forgot(payload.email)
    return no_content()


@router.post(
    "/password/reset",
    status_code=status.HTTP_204_NO_CONTENT,
    response_class=Response,
    dependencies=[Depends(limit_credentials)],
)
async def reset_password(
    payload: PasswordReset, service: AccountService = Depends(get_public_account_service)
) -> Response:
    """Set a new password with the token of a reset link; every device session of the account ends.

    Args:
        payload: The token and the new password.
        service: Account service.

    Returns:
        Empty response.
    """
    await service.reset(payload.token, payload.password)
    return no_content()


@router.post("/password", status_code=status.HTTP_204_NO_CONTENT, response_class=Response)
async def change_password(payload: PasswordChange, service: AccountService = Depends(get_account_service)) -> Response:
    """Change the signed-in user's password; the user's other device sessions end.

    Args:
        payload: Current and new password.
        service: Account service.

    Returns:
        Empty response.
    """
    await service.change_password(payload.current_password, payload.new_password)
    return no_content()


@router.post("/token", response_model=TokenPair, dependencies=[Depends(limit_credentials)])
async def create_token(
    payload: TokenRequest,
    users: UserService = Depends(get_user_service),
    tokens: TokenService = Depends(get_token_service),
) -> TokenPair:
    """Sign in an app and open a device session with an access and a refresh token.

    Args:
        payload: Credentials and the device.
        users: User service.
        tokens: Token service.

    Returns:
        The token pair.
    """
    user = await users.authenticate(payload.email, payload.password)
    return await tokens.open(user, payload.device_name, payload.platform)


@router.post("/token/refresh", response_model=TokenPair, dependencies=[Depends(limit_credentials)])
async def refresh_token(payload: RefreshRequest, tokens: TokenService = Depends(get_token_service)) -> TokenPair:
    """Exchange a refresh token for a new pair; an already used token revokes its whole session.

    Args:
        payload: The refresh token.
        tokens: Token service.

    Returns:
        The new token pair.
    """
    return await tokens.refresh(payload.refresh_token)


@router.post("/token/revoke", status_code=status.HTTP_204_NO_CONTENT, response_class=Response)
async def revoke_token(tokens: TokenService = Depends(get_session_service)) -> Response:
    """Sign out the app: end the device session of the access token.

    Args:
        tokens: Token service.

    Returns:
        Empty response.
    """
    await tokens.revoke_current()
    return no_content()


@router.get("/sessions", response_model=SessionList)
async def list_sessions(tokens: TokenService = Depends(get_session_service)) -> SessionList:
    """List the live device sessions of the signed-in user.

    Args:
        tokens: Token service.

    Returns:
        The sessions.
    """
    return await tokens.list()


@router.delete("/sessions/{session}", status_code=status.HTTP_204_NO_CONTENT, response_class=Response)
async def revoke_session(session: UUID, tokens: TokenService = Depends(get_session_service)) -> Response:
    """End one device session of the signed-in user.

    Args:
        session: Public id of the session.
        tokens: Token service.

    Returns:
        Empty response.
    """
    await tokens.revoke(session)
    return no_content()


@router.get("/me", response_model=AccountRead)
async def get_account(service: AccountService = Depends(get_account_service)) -> AccountRead:
    """Return the signed-in user's account.

    Args:
        service: Account service.

    Returns:
        The account.
    """
    return await service.read()


@router.patch("/me", response_model=AccountRead)
async def update_account(payload: AccountUpdate, service: AccountService = Depends(get_account_service)) -> AccountRead:
    """Change the signed-in user's display name.

    Args:
        payload: The new name.
        service: Account service.

    Returns:
        The account.
    """
    return await service.update(payload.name)


@router.post("/me/delete", status_code=status.HTTP_204_NO_CONTENT, response_class=Response)
async def delete_account(payload: AccountDelete, service: AccountService = Depends(get_account_service)) -> Response:
    """Delete the signed-in account after checking its password.

    Args:
        payload: The password.
        service: Account service.

    Returns:
        Empty response that also clears the web session cookie.
    """
    await service.delete(payload.password)
    response = no_content()
    clear_session_cookie(response)
    return response


@router.get("/jwks", response_model=JwkSet)
async def get_jwks() -> JwkSet:
    """Return the public keys that verify access tokens.

    Returns:
        The key set.
    """
    return JwkSet.model_validate(jwks())


async def check_stream_access(request: Request, actor: UserContext, session: AsyncSession) -> None:
    """Refuse a proxied video request for a camera stream of a site the user may not reach.

    nginx passes the original address of the video request; its src parameter names the go2rtc stream, whose
    name starts with the camera id.

    Args:
        request: The verification subrequest.
        actor: Signed-in user.
        session: Database session.

    Raises:
        Forbidden: The stream belongs to a camera the user may not reach.
    """
    original = request.headers.get(ORIGINAL_URI)
    if not original:
        return
    names = parse_qs(urlsplit(original).query).get("src", [])
    for name in names:
        if not is_managed(name):
            continue
        camera_uuid = UUID(name.split("_", 1)[0])
        site_ids = [site.id for site, _, _ in await accessible_sites(session, actor.id)]
        allowed = await session.scalar(
            select(Camera.id).where(Camera.uuid == camera_uuid, Camera.site_id.in_(site_ids)).limit(1)
        )
        if allowed is None:
            raise Forbidden("camera_forbidden", "The camera is not at a site you may reach")


@router.api_route("/verify", methods=["GET", "HEAD"], status_code=status.HTTP_204_NO_CONTENT, include_in_schema=False)
async def verify(
    request: Request,
    actor: UserContext = Depends(get_current_user),
    session: AsyncSession = Depends(get_db),
) -> Response:
    """Answer nginx's subrequest with an empty success when the request may watch the camera it asks for.

    Args:
        request: The subrequest.
        actor: Signed-in user making the request.
        session: Database session.

    Returns:
        Empty response; the dependency rejects requests without a session.
    """
    await check_stream_access(request, actor, session)
    return no_content()
