"""Schemas of sign-in, accounts, tokens and device sessions."""

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field, field_validator

__all__ = [
    "AccountDelete",
    "AccountRead",
    "AccountRegister",
    "AccountUpdate",
    "EmailRequest",
    "Jwk",
    "JwkSet",
    "LoginRequest",
    "PasswordChange",
    "PasswordReset",
    "RefreshRequest",
    "SessionList",
    "SessionRead",
    "SessionUser",
    "TokenPair",
    "TokenRequest",
    "VerifyEmail",
    "clean_email",
]

PASSWORD_MIN = 8
PASSWORD_MAX = 72
EMAIL_MAX = 255


def clean_email(value: str) -> str:
    """Trim and lowercase an email address and check its shape.

    Args:
        value: Raw address.

    Returns:
        The address in lower case.

    Raises:
        ValueError: The address has no local part and domain.
    """
    value = value.strip().lower()
    local, separator, domain = value.rpartition("@")
    if not separator or not local or "." not in domain or " " in value:
        raise ValueError("must be an email address")
    return value


class LoginRequest(BaseModel):
    """Credentials sent to sign in to the web app.

    Attributes:
        username: Sign-in name or email address.
        password: Account password.
    """

    username: str = Field(min_length=1, max_length=EMAIL_MAX)
    password: str = Field(min_length=1, max_length=256)


class SessionUser(BaseModel):
    """Public identity of the signed-in user.

    Attributes:
        uuid: Public id of the user.
        username: Sign-in name.
    """

    model_config = ConfigDict(from_attributes=True)

    uuid: UUID
    username: str


class AccountRead(BaseModel):
    """The signed-in user's account.

    Attributes:
        uuid: Public id of the user.
        username: Sign-in name.
        email: Email address, if the account has one.
        name: Display name, if given.
        email_verified: Whether the email address is confirmed.
        created_at: When the account was created.
    """

    uuid: UUID
    username: str
    email: str | None
    name: str | None
    email_verified: bool
    created_at: datetime


class AccountRegister(BaseModel):
    """Request to create an account.

    Attributes:
        email: Email address; a confirmation link is mailed to it.
        password: Password of 8 to 72 characters.
        name: Display name.
    """

    email: str = Field(min_length=3, max_length=EMAIL_MAX)
    password: str = Field(min_length=PASSWORD_MIN, max_length=PASSWORD_MAX)
    name: str | None = Field(default=None, max_length=100)

    @field_validator("email")
    @classmethod
    def normalize_email(cls, value: str) -> str:
        """Lowercase the address and check its shape.

        Args:
            value: Raw address.

        Returns:
            The cleaned address.
        """
        return clean_email(value)

    @field_validator("name")
    @classmethod
    def strip_name(cls, value: str | None) -> str | None:
        """Trim the name and turn a blank one into None.

        Args:
            value: Raw name.

        Returns:
            The trimmed name, or None.
        """
        if value is None:
            return None
        return value.strip() or None


class AccountUpdate(BaseModel):
    """Request to change the account's profile.

    Attributes:
        name: New display name; an empty string removes it.
    """

    name: str | None = Field(default=None, max_length=100)


class AccountDelete(BaseModel):
    """Request to delete the signed-in account.

    Attributes:
        password: Current password, to confirm.
    """

    password: str = Field(min_length=1, max_length=256)


class EmailRequest(BaseModel):
    """Request naming an email address, to resend a confirmation or to reset a password.

    Attributes:
        email: The address.
    """

    email: str = Field(min_length=3, max_length=EMAIL_MAX)

    @field_validator("email")
    @classmethod
    def normalize_email(cls, value: str) -> str:
        """Lowercase the address and check its shape.

        Args:
            value: Raw address.

        Returns:
            The cleaned address.
        """
        return clean_email(value)


class VerifyEmail(BaseModel):
    """Request to confirm an email address.

    Attributes:
        token: Token from the confirmation link.
    """

    token: str = Field(min_length=16, max_length=128)


class PasswordReset(BaseModel):
    """Request to set a new password with a reset token.

    Attributes:
        token: Token from the reset link.
        password: New password.
    """

    token: str = Field(min_length=16, max_length=128)
    password: str = Field(min_length=PASSWORD_MIN, max_length=PASSWORD_MAX)


class PasswordChange(BaseModel):
    """Request to change the password of the signed-in account.

    Attributes:
        current_password: Current password.
        new_password: New password.
    """

    current_password: str = Field(min_length=1, max_length=256)
    new_password: str = Field(min_length=PASSWORD_MIN, max_length=PASSWORD_MAX)


class TokenRequest(BaseModel):
    """Request of an app to sign in and open a device session.

    Attributes:
        email: Email address, or the sign-in name of an account without one.
        password: Password.
        device_name: Name of the device, shown in the session list.
        platform: Platform of the app, such as android or ios.
    """

    email: str = Field(min_length=1, max_length=EMAIL_MAX)
    password: str = Field(min_length=1, max_length=256)
    device_name: str = Field(default="Phone", min_length=1, max_length=100)
    platform: str = Field(default="android", min_length=1, max_length=20)


class RefreshRequest(BaseModel):
    """Request to exchange a refresh token for a new token pair.

    Attributes:
        refresh_token: The refresh token.
    """

    refresh_token: str = Field(min_length=16, max_length=128)


class SessionRead(BaseModel):
    """A device session.

    Attributes:
        uuid: Public id of the session.
        name: Device name.
        platform: App platform.
        created_at: When the session was opened.
        last_used_at: When it last refreshed its tokens.
        expires_at: Absolute end of the session.
        current: Whether the request was made with this session.
    """

    uuid: UUID
    name: str
    platform: str
    created_at: datetime
    last_used_at: datetime
    expires_at: datetime
    current: bool


class SessionList(BaseModel):
    """The live device sessions of the account.

    Attributes:
        items: Sessions, newest first.
    """

    items: list[SessionRead]


class TokenPair(BaseModel):
    """Tokens of a device session.

    Attributes:
        access_token: ES256 access token for the Authorization header.
        token_type: Always Bearer.
        expires_in: Seconds the access token is valid.
        refresh_token: Single-use refresh token; each refresh returns a new one.
        refresh_expires_in: Seconds the refresh token stays valid unused.
        session: The device session.
    """

    access_token: str
    token_type: str = "Bearer"
    expires_in: int
    refresh_token: str
    refresh_expires_in: int
    session: SessionRead


class Jwk(BaseModel):
    """Public key of the access token signature.

    Attributes:
        kty: Key type, EC.
        crv: Curve, P-256.
        x: X coordinate as base64url.
        y: Y coordinate as base64url.
        kid: Key id.
        use: Key use, sig.
        alg: Algorithm, ES256.
    """

    kty: str
    crv: str
    x: str
    y: str
    kid: str
    use: str
    alg: str


class JwkSet(BaseModel):
    """Keys that verify access tokens.

    Attributes:
        keys: The keys.
    """

    keys: list[Jwk]
