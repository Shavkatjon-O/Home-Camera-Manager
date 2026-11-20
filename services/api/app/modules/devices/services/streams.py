"""Access to proxied video: a camera's go2rtc streams are open only to members of its site."""

from urllib.parse import parse_qs, urlsplit
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.core.exceptions import Forbidden
from app.models import Camera
from app.modules.tenancy.services.access import accessible_sites
from app.streaming.names import is_managed

__all__ = ["StreamAccessService"]


class StreamAccessService:
    """Checks that a signed-in user may watch the camera stream a proxied video request names.

    Attributes:
        session: Database session.
        actor: Signed-in user.
    """

    def __init__(self, session: AsyncSession, actor: UserContext):
        """Bind the service to a session and a user.

        Args:
            session: Database session.
            actor: Signed-in user.
        """
        self.session = session
        self.actor = actor

    async def check(self, original_uri: str | None) -> None:
        """Refuse a video request for a camera of a site the user may not reach.

        nginx passes the original address of the video request; its src parameter names the go2rtc stream, whose
        name starts with the camera id.

        Args:
            original_uri: The proxied request's path and query, if nginx passed it.

        Raises:
            Forbidden: The stream belongs to a camera the user may not reach.
        """
        if not original_uri:
            return
        names = [name for name in parse_qs(urlsplit(original_uri).query).get("src", []) if is_managed(name)]
        if not names:
            return
        site_ids = [site.id for site, _, _ in await accessible_sites(self.session, self.actor.id)]
        for name in names:
            camera_uuid = UUID(name.split("_", 1)[0])
            allowed = await self.session.scalar(
                select(Camera.id).where(Camera.uuid == camera_uuid, Camera.site_id.in_(site_ids)).limit(1)
            )
            if allowed is None:
                raise Forbidden("camera_forbidden", "The camera is not at a site you may reach")
