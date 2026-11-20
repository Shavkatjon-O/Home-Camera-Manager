"""Outgoing mail: account confirmation, password reset and invitations over SMTP."""

import asyncio
import logging
import smtplib
import ssl
from dataclasses import dataclass
from email.message import EmailMessage
from email.utils import make_msgid

from app.core.config import settings

__all__ = ["Mail", "Mailer", "invitation_mail", "link", "mailer", "reset_mail", "verify_mail"]

logger = logging.getLogger(__name__)

SMTP_TIMEOUT_SECONDS = 15.0
PRODUCT = "Smart Surveillance"


@dataclass(frozen=True)
class Mail:
    """One message to send.

    Attributes:
        to: Recipient address.
        subject: Subject line.
        body: Plain text body.
    """

    to: str
    subject: str
    body: str


def link(path: str) -> str:
    """Build a link into the apps under the public address.

    Args:
        path: Path starting with a slash.

    Returns:
        The absolute link.
    """
    return f"{settings.public_url.rstrip('/')}{path}"


def verify_mail(to: str, name: str | None, token: str) -> Mail:
    """Build the message that confirms an email address.

    Args:
        to: Recipient.
        name: Name of the account, if any.
        token: Confirmation token.

    Returns:
        The message.
    """
    greeting = f"Hello {name}," if name else "Hello,"
    body = (
        f"{greeting}\n\n"
        f"Confirm the email address of your {PRODUCT} account by opening this link:\n\n"
        f"{link(f'/verify-email/{token}')}\n\n"
        f"Or enter this code in the app: {token}\n\n"
        f"The link is valid for {settings.verify_token_hours} hours. If you did not create an account, ignore "
        "this message.\n"
    )
    return Mail(to=to, subject=f"Confirm your {PRODUCT} account", body=body)


def reset_mail(to: str, token: str) -> Mail:
    """Build the message that resets a password.

    Args:
        to: Recipient.
        token: Reset token.

    Returns:
        The message.
    """
    body = (
        "Hello,\n\n"
        f"Someone asked to reset the password of your {PRODUCT} account. Choose a new password here:\n\n"
        f"{link(f'/reset-password/{token}')}\n\n"
        f"Or enter this code in the app: {token}\n\n"
        f"The link is valid for {settings.reset_token_minutes} minutes. If it was not you, ignore this message; "
        "your password stays as it is.\n"
    )
    return Mail(to=to, subject=f"Reset your {PRODUCT} password", body=body)


def invitation_mail(to: str, organisation: str, inviter: str, role: str, token: str) -> Mail:
    """Build the message that invites someone into an organisation.

    Args:
        to: Recipient.
        organisation: Name of the organisation.
        inviter: Name of the member who invites.
        role: Role the invitee receives.
        token: Invitation token.

    Returns:
        The message.
    """
    body = (
        "Hello,\n\n"
        f"{inviter} invites you to {organisation} on {PRODUCT} as {role}. Open this link in the app to accept:\n\n"
        f"{link(f'/invite/{token}')}\n\n"
        f"The invitation is valid for {settings.invitation_days} days and can be used once.\n"
    )
    return Mail(to=to, subject=f"{inviter} invites you to {organisation}", body=body)


class Mailer:
    """Sends mail through the configured SMTP server, or logs it when none is configured.

    Attributes:
        sent: Messages logged instead of sent, kept for tests.
    """

    def __init__(self):
        """Create the mailer."""
        self.sent: list[Mail] = []

    def message(self, mail: Mail) -> EmailMessage:
        """Build the MIME message of a mail.

        Args:
            mail: The mail.

        Returns:
            The message with sender, recipient, subject and a message id.
        """
        message = EmailMessage()
        message["From"] = settings.mail_from
        message["To"] = mail.to
        message["Subject"] = mail.subject
        message["Message-ID"] = make_msgid(domain="smart-surveillance")
        message.set_content(mail.body)
        return message

    def deliver(self, mail: Mail) -> None:
        """Send a mail over SMTP, blocking until the server accepted it.

        Args:
            mail: The mail.

        Raises:
            smtplib.SMTPException: The server refused the mail.
            OSError: The server cannot be reached.
        """
        message = self.message(mail)
        if settings.smtp_ssl:
            server = smtplib.SMTP_SSL(
                settings.smtp_host,
                settings.smtp_port,
                timeout=SMTP_TIMEOUT_SECONDS,
                context=ssl.create_default_context(),
            )
        else:
            server = smtplib.SMTP(settings.smtp_host, settings.smtp_port, timeout=SMTP_TIMEOUT_SECONDS)
        with server:
            if settings.smtp_starttls and not settings.smtp_ssl:
                server.starttls(context=ssl.create_default_context())
            if settings.smtp_username:
                server.login(settings.smtp_username, settings.smtp_password)
            server.send_message(message)

    async def send(self, mail: Mail) -> bool:
        """Send a mail without blocking the event loop.

        Args:
            mail: The mail.

        Returns:
            True when the server accepted it or no server is configured, False when sending failed, which is
            logged; the caller's action stands either way.
        """
        if not settings.smtp_host:
            self.sent.append(mail)
            logger.info("No SMTP server is set; mail to %s with subject %r was not sent", mail.to, mail.subject)
            return True
        try:
            await asyncio.to_thread(self.deliver, mail)
        except (smtplib.SMTPException, OSError) as exc:
            logger.warning("Sending mail to %s failed: %s", mail.to, exc)
            return False
        return True


mailer = Mailer()
