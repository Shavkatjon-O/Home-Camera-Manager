import pytest

from app.core.config import settings
from app.core.mail import Mail, Mailer, invitation_mail, link, reset_mail, verify_mail


@pytest.fixture(autouse=True)
def public(monkeypatch):
    monkeypatch.setattr(settings, "public_url", "https://cams.example.org/")
    monkeypatch.setattr(settings, "smtp_host", "")


def test_link_joins_the_public_url_without_a_double_slash():
    assert link("/x") == "https://cams.example.org/x"


def test_verify_mail_carries_the_confirmation_link():
    mail = verify_mail("a@example.org", "Alice", "TOKEN123")
    assert "https://cams.example.org/verify-email/TOKEN123" in mail.body
    assert mail.to == "a@example.org"
    assert "Hello Alice," in mail.body


def test_verify_mail_greets_an_unnamed_account():
    assert verify_mail("a@example.org", None, "T").body.startswith("Hello,\n")


def test_reset_mail_carries_the_reset_link():
    mail = reset_mail("a@example.org", "RESET456")
    assert "https://cams.example.org/reset-password/RESET456" in mail.body


def test_invitation_mail_carries_the_invitation_link_and_names():
    mail = invitation_mail("a@example.org", "Acme", "Bob", "viewer", "INV789")
    assert "https://cams.example.org/invite/INV789" in mail.body
    assert "Bob" in mail.subject
    assert "Acme" in mail.subject
    assert "as viewer" in mail.body


async def test_send_without_a_server_records_the_mail():
    mailer = Mailer()
    mail = Mail(to="a@example.org", subject="Hi", body="Body")
    assert await mailer.send(mail) is True
    assert mailer.sent == [mail]


async def test_send_reports_a_failed_delivery(monkeypatch):
    monkeypatch.setattr(settings, "smtp_host", "smtp.invalid")
    mailer = Mailer()

    def refuse(mail):
        raise OSError("down")

    monkeypatch.setattr(mailer, "deliver", refuse)
    assert await mailer.send(Mail(to="a@example.org", subject="Hi", body="Body")) is False
    assert mailer.sent == []


def test_message_sets_sender_recipient_and_subject(monkeypatch):
    monkeypatch.setattr(settings, "mail_from", "Cams <cams@example.org>")
    message = Mailer().message(Mail(to="a@example.org", subject="Hello there", body="Body"))
    assert message["From"] == "Cams <cams@example.org>"
    assert message["To"] == "a@example.org"
    assert message["Subject"] == "Hello there"
    assert message.get_content().strip() == "Body"
