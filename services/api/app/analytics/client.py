"""Client of the analytics service's status endpoint, for live objects and fresh view pictures."""

import re

import httpx

from app.core.config import settings
from app.core.exceptions import NotFound, Unavailable

TIMEOUT_SECONDS = 10.0
REFERENCE_PATTERN = re.compile(r"^analytics/references/[0-9a-f-]{36}/\d+\.jpg$")


def headers() -> dict[str, str]:
    """Return the authorization header of the shared token.

    Returns:
        The headers.
    """
    return {"Authorization": f"Bearer {settings.analytics_token}"}


async def fetch(path: str, params: dict | None = None) -> httpx.Response:
    """Send one GET to the analytics service.

    Args:
        path: Path on the service.
        params: Query parameters.

    Returns:
        The response with status 200.

    Raises:
        NotFound: The service does not know the view.
        Unavailable: The service does not answer or fails.
    """
    try:
        async with httpx.AsyncClient(timeout=TIMEOUT_SECONDS) as client:
            response = await client.get(f"{settings.analytics_url.rstrip('/')}{path}", params=params, headers=headers())
    except httpx.HTTPError:
        raise Unavailable("analytics_unavailable", "The analytics service does not answer")
    if response.status_code == 404:
        raise NotFound("analytics_view_not_found", "The analytics service has no picture of this view yet")
    if response.status_code != 200:
        raise Unavailable("analytics_unavailable", f"The analytics service answered {response.status_code}")
    return response


async def live_objects(view_uuid: str) -> dict:
    """Return the tracked objects of a view's latest frame.

    Args:
        view_uuid: The view.

    Returns:
        The view id, the frame time and the objects.
    """
    return (await fetch(f"/views/{view_uuid}/objects")).json()


async def snapshot(view_uuid: str, reference: bool) -> tuple[bytes, str | None]:
    """Return a fresh picture of a view.

    Args:
        view_uuid: The view.
        reference: Ask the service to keep the picture as a zone reference.

    Returns:
        The JPEG and the reference path when one was kept.
    """
    response = await fetch(f"/views/{view_uuid}/snapshot.jpg", {"reference": "1"} if reference else None)
    kept = response.headers.get("X-Reference")
    return response.content, kept if kept and REFERENCE_PATTERN.match(kept) else None
