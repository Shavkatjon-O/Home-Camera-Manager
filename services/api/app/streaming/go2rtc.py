"""Client for the go2rtc stream API."""

import httpx

STREAMS_PATH = "/api/streams"
WEBRTC_PATH = "/api/webrtc"
SDP_TYPE = "application/sdp"

DEFAULT_TIMEOUT_SECONDS = 5.0


class Go2rtcError(Exception):
    """Error raised when go2rtc does not answer or refuses a request."""

    pass


class Go2rtcClient:
    """Async client for the go2rtc stream list, registration and probing.

    Attributes:
        base_url: Base URL of the go2rtc API without a trailing slash.
        timeout: Default request timeout in seconds.
        http: Shared HTTP client, created on first use and recreated once closed.
    """

    def __init__(self, base_url: str, timeout: float = DEFAULT_TIMEOUT_SECONDS):
        """Bind the client to a go2rtc instance.

        Args:
            base_url: Base URL of the go2rtc API.
            timeout: Default request timeout in seconds.
        """
        self.base_url = base_url.rstrip("/")
        self.timeout = timeout
        self.http: httpx.AsyncClient | None = None

    def client(self) -> httpx.AsyncClient:
        """Return the shared HTTP client, creating it when it is missing or closed.

        Returns:
            The client bound to the go2rtc API address.
        """
        if self.http is None or self.http.is_closed:
            self.http = httpx.AsyncClient(base_url=self.base_url, timeout=self.timeout)
        return self.http

    async def close(self) -> None:
        """Close the shared HTTP client if it is open."""
        if self.http is not None and not self.http.is_closed:
            await self.http.aclose()
        self.http = None

    async def request(self, method: str, params: list[tuple[str, str]] | None = None) -> httpx.Response:
        """Send a request to the go2rtc stream endpoint.

        Args:
            method: HTTP method.
            params: Query parameters as name and value pairs.

        Returns:
            The response, whatever its status.

        Raises:
            Go2rtcError: When go2rtc cannot be reached.
        """
        try:
            return await self.client().request(method, STREAMS_PATH, params=params)
        except httpx.HTTPError as exc:
            raise Go2rtcError(f"go2rtc does not answer ({type(exc).__name__})")

    async def snapshot(self) -> dict[str, dict]:
        """Fetch the full stream list with producers and consumers.

        Returns:
            The go2rtc info of every stream, keyed by stream name, with an empty dict for a stream without info.

        Raises:
            Go2rtcError: When go2rtc answers with a status other than 200 or with invalid JSON.
        """
        response = await self.request("GET")
        if response.status_code != 200:
            raise Go2rtcError(f"go2rtc answered HTTP {response.status_code} to the stream list")
        try:
            data = response.json() or {}
        except ValueError:
            raise Go2rtcError("go2rtc answered the stream list with invalid JSON")
        return {name: info or {} for name, info in data.items()}

    async def streams(self) -> dict[str, list[str]]:
        """List the source URLs of every stream.

        Returns:
            The producer URLs of each stream, keyed by stream name.
        """
        result = {}
        for name, info in (await self.snapshot()).items():
            producers = info.get("producers") or []
            result[name] = [producer["url"] for producer in producers if producer.get("url")]
        return result

    async def consumer_agents(self) -> dict[str, list[str]]:
        """List the user agents of the consumers of every stream.

        Returns:
            The user agent of each consumer per stream, keyed by stream name, with an empty string for a missing agent.
        """
        result = {}
        for name, info in (await self.snapshot()).items():
            consumers = info.get("consumers") or []
            result[name] = [consumer.get("user_agent") or "" for consumer in consumers]
        return result

    async def received(self) -> dict[str, int | None]:
        """Sum the bytes received from the producers of every stream.

        Returns:
            The total of received bytes per stream, or None when no producer has received anything.
        """
        result = {}
        for name, info in (await self.snapshot()).items():
            counts = [producer["bytes_recv"] for producer in info.get("producers") or [] if producer.get("bytes_recv")]
            result[name] = sum(counts) if counts else None
        return result

    async def probe(self, name: str, timeout: float) -> bool:
        """Check whether a stream delivers video.

        Asks go2rtc to connect to the stream and looks for a video media in its producers.

        Args:
            name: Stream name.
            timeout: Request timeout in seconds.

        Returns:
            True when a producer offers a video media, False on any failure.
        """
        try:
            response = await self.client().get(STREAMS_PATH, params=[("src", name), ("video", "")], timeout=timeout)
        except httpx.HTTPError:
            return False
        if response.status_code != 200:
            return False
        try:
            data = response.json() or {}
        except ValueError:
            return False
        for producer in data.get("producers") or []:
            if any(str(media).startswith("video") for media in producer.get("medias") or []):
                return True
        return False

    async def put(self, name: str, sources: list[str]) -> None:
        """Register a stream with the given sources.

        A refused request is accepted when the stream already exists with exactly these sources.

        Args:
            name: Stream name.
            sources: Source URLs of the stream.

        Raises:
            Go2rtcError: When go2rtc refuses the stream and it does not exist with these sources.
        """
        params = [("name", name), *(("src", source) for source in sources)]
        response = await self.request("PUT", params)
        if response.is_success:
            return
        current = await self.streams()
        if current.get(name) == list(sources):
            return
        raise Go2rtcError(f"go2rtc refused the stream {name} with HTTP {response.status_code}")

    async def delete(self, name: str) -> None:
        """Remove a stream.

        A refused request is accepted when the stream no longer exists.

        Args:
            name: Stream name.

        Raises:
            Go2rtcError: When go2rtc refuses to remove a stream that still exists.
        """
        response = await self.request("DELETE", [("src", name)])
        if response.is_success:
            return
        if name not in await self.streams():
            return
        raise Go2rtcError(f"go2rtc refused to remove the stream {name} with HTTP {response.status_code}")

    async def webrtc(self, name: str, offer: str, timeout: float = 15.0) -> str:
        """Exchange a WebRTC offer for go2rtc's answer on a stream.

        Args:
            name: Stream name.
            offer: SDP offer of the viewer.
            timeout: Request timeout in seconds; go2rtc connects to the source before it answers.

        Returns:
            The SDP answer.

        Raises:
            Go2rtcError: When go2rtc cannot be reached or refuses the offer.
        """
        try:
            response = await self.client().post(
                WEBRTC_PATH,
                params=[("src", name)],
                content=offer.encode(),
                headers={"Content-Type": SDP_TYPE},
                timeout=timeout,
            )
        except httpx.HTTPError as exc:
            raise Go2rtcError(f"go2rtc does not answer ({type(exc).__name__})")
        if not response.is_success:
            raise Go2rtcError(f"go2rtc refused the offer for {name} with HTTP {response.status_code}")
        if "json" in response.headers.get("content-type", ""):
            try:
                return str((response.json() or {}).get("sdp") or "")
            except ValueError:
                raise Go2rtcError("go2rtc answered the offer with invalid JSON")
        return response.text
