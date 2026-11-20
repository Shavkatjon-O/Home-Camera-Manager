import httpx
import pytest

from connector_agent.backend import DEVICE_GRANT, BackendClient, BackendError, GrantPending, Revoked


def client(handler, token=None):
    return BackendClient("http://backend", token, transport=httpx.MockTransport(handler))


async def test_calls_carry_the_token_under_the_connector_prefix():
    seen = []

    def handler(request):
        seen.append((request.url.path, request.headers.get("authorization")))
        return httpx.Response(200, json={"discovery_requested": False, "config_version": "v"})

    await client(handler, "secret").heartbeat({"cameras": []})
    assert seen == [("/api/v1/connector/heartbeat", "Bearer secret")]


async def test_a_refused_token_is_revoked_and_other_failures_are_errors():
    with pytest.raises(Revoked):
        await client(lambda request: httpx.Response(401)).config()
    with pytest.raises(BackendError):
        await client(lambda request: httpx.Response(500)).config()

    def broken(request):
        raise httpx.ConnectError("down")

    with pytest.raises(BackendError):
        await client(broken).config()


async def test_the_token_poll_reads_rfc_8628_errors():
    def handler(request):
        assert DEVICE_GRANT in request.content.decode()
        return httpx.Response(400, json={"error": "slow_down", "interval": 10})

    with pytest.raises(GrantPending) as caught:
        await client(handler).token_for("d" * 32)
    assert caught.value.error == "slow_down" and caught.value.interval == 10
