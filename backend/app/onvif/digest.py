import base64
import hashlib
import os
from datetime import UTC, datetime
from xml.sax.saxutils import escape

WSSE_NAMESPACE = "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"
WSU_NAMESPACE = "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"
PASSWORD_DIGEST_TYPE = (
    "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordDigest"
)
NONCE_ENCODING = "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary"

NONCE_BYTES = 16


def password_digest(nonce: bytes, created: str, password: str) -> str:
    digest = hashlib.sha1(nonce + created.encode() + password.encode()).digest()
    return base64.b64encode(digest).decode()


def format_created(moment: datetime) -> str:
    return moment.astimezone(UTC).strftime("%Y-%m-%dT%H:%M:%SZ")


def security_header(username: str, password: str, created: datetime, nonce: bytes | None = None) -> str:
    nonce = nonce if nonce is not None else os.urandom(NONCE_BYTES)
    stamp = format_created(created)
    digest = password_digest(nonce, stamp, password)
    encoded_nonce = base64.b64encode(nonce).decode()
    return (
        f'<wsse:Security s:mustUnderstand="1" xmlns:wsse="{WSSE_NAMESPACE}" xmlns:wsu="{WSU_NAMESPACE}">'
        "<wsse:UsernameToken>"
        f"<wsse:Username>{escape(username)}</wsse:Username>"
        f'<wsse:Password Type="{PASSWORD_DIGEST_TYPE}">{digest}</wsse:Password>'
        f'<wsse:Nonce EncodingType="{NONCE_ENCODING}">{encoded_nonce}</wsse:Nonce>'
        f"<wsu:Created>{stamp}</wsu:Created>"
        "</wsse:UsernameToken>"
        "</wsse:Security>"
    )
