"""Client of the analytics service's face enrollment endpoint."""

import logging

import httpx
from pydantic import ValidationError

from app.core.exceptions import BadGateway, Unavailable
from app.modules.people.photos import UNREADABLE, PhotoRejected
from app.modules.people.schemas import DetectedFace, EmbedResponse

logger = logging.getLogger(__name__)

EMBED_PATH = "/identity/embed"
EMBED_TIMEOUT_SECONDS = 30.0


class AnalyticsClient:
    """Send photos to the analytics service and read back the faces it finds.

    Attributes:
        base_url: Base URL of the analytics service, without a trailing slash.
        token: Bearer token the analytics service expects.
        timeout: Seconds to wait for an answer.
        transport: Transport to send requests through instead of the network, if any.
    """

    def __init__(
        self,
        base_url: str,
        token: str,
        timeout: float = EMBED_TIMEOUT_SECONDS,
        transport: httpx.AsyncBaseTransport | None = None,
    ):
        """Bind the client to the analytics service.

        Args:
            base_url: Base URL of the analytics service.
            token: Bearer token the analytics service expects.
            timeout: Seconds to wait for an answer.
            transport: Transport to send requests through instead of the network, if any.
        """
        self.base_url = (base_url or "").rstrip("/")
        self.token = token or ""
        self.timeout = timeout
        self.transport = transport

    async def embed(self, content: bytes, content_type: str) -> list[DetectedFace]:
        """Find the faces of a photo and compute their embeddings.

        Args:
            content: Image bytes.
            content_type: Content type of the image.

        Returns:
            The faces found, largest first.

        Raises:
            PhotoRejected: When the analytics service cannot decode the image.
            Unavailable: When the service is not configured, does not answer or has not loaded its face models.
            BadGateway: When the service refuses the token or sends an answer that cannot be read.
        """
        if not self.base_url:
            raise Unavailable("analytics_not_configured", "The analytics service address is not configured")
        headers = {"Authorization": f"Bearer {self.token}", "Content-Type": content_type}
        try:
            async with httpx.AsyncClient(timeout=self.timeout, transport=self.transport) as http:
                response = await http.post(f"{self.base_url}{EMBED_PATH}", content=content, headers=headers)
        except httpx.HTTPError as exc:
            logger.warning("The analytics enrollment request failed: %s", type(exc).__name__)
            raise Unavailable(
                "analytics_unavailable", "The analytics service does not answer; check that it is running"
            ) from exc
        if response.status_code == 400:
            raise PhotoRejected(UNREADABLE)
        if response.status_code == 401:
            raise BadGateway("analytics_refused", "The analytics service refused the backend's token")
        if response.status_code == 503:
            raise Unavailable("face_models_unavailable", "The face models are not loaded yet; try again shortly")
        if response.status_code != 200:
            raise BadGateway("analytics_failed", f"The analytics service answered HTTP {response.status_code}")
        try:
            return EmbedResponse.model_validate_json(response.content).faces
        except ValidationError as exc:
            logger.warning("The analytics enrollment answer could not be read: %s", exc.error_count())
            raise BadGateway("analytics_bad_answer", "The analytics service sent an answer that could not be read")
