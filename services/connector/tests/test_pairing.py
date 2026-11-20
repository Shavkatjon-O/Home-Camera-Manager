from connector_agent.backend import BackendError, GrantPending
from connector_agent.pairing import pair, qr_svg, qr_text

TOKEN = {
    "access_token": "token",
    "connector": "c",
    "site": "s",
    "organisation": "o",
    "agent_key": "key",
    "stream_username": "central",
    "stream_password": "stream",
    "heartbeat_interval": 20,
}


class Backend:
    def __init__(self, polls):
        self.polls = list(polls)
        self.codes = 0

    async def device_code(self, name, version):
        self.codes += 1
        if self.codes == 1:
            raise BackendError("down")
        return {
            "device_code": f"device-{self.codes}",
            "user_code": "BCDF-GHJK",
            "verification_uri": "https://app.example/pair",
            "verification_uri_complete": "https://app.example/pair?code=BCDF-GHJK",
            "interval": 5,
        }

    async def token_for(self, device_code):
        result = self.polls.pop(0)
        if isinstance(result, Exception):
            raise result
        return result


async def test_pairing_retries_slows_down_reopens_and_returns_the_credentials():
    waits = []
    shown = []

    async def sleep(seconds):
        waits.append(seconds)

    backend = Backend(
        [
            GrantPending("authorization_pending"),
            GrantPending("slow_down"),
            GrantPending("expired_token"),
            GrantPending("authorization_pending"),
            TOKEN,
        ]
    )
    pairing = await pair(backend, "Connector", "0.1.0", shown.append, sleep)
    assert pairing.token == "token" and pairing.heartbeat_interval == 20
    assert backend.codes == 3
    assert waits == [10, 5, 5, 10, 5, 5]
    assert shown[-1] is None and shown[0]["user_code"] == "BCDF-GHJK"


def test_the_pairing_link_draws_as_ascii_and_svg():
    text = qr_text("https://app.example/pair?code=BCDF-GHJK")
    assert set(text) <= {"#", " ", "\n"} and len(text.splitlines()) > 20
    assert qr_svg("https://app.example/pair").startswith("<?xml")
