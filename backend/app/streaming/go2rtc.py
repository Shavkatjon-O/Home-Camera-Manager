import httpx

STREAMS_PATH = "/api/streams"

DEFAULT_TIMEOUT_SECONDS = 5.0


class Go2rtcError(Exception):
    pass


class Go2rtcClient:
    def __init__(self, base_url: str, timeout: float = DEFAULT_TIMEOUT_SECONDS):
        self.base_url = base_url.rstrip("/")
        self.timeout = timeout
        self.http: httpx.AsyncClient | None = None

    def client(self) -> httpx.AsyncClient:
        if self.http is None or self.http.is_closed:
            self.http = httpx.AsyncClient(base_url=self.base_url, timeout=self.timeout)
        return self.http

    async def close(self) -> None:
        if self.http is not None and not self.http.is_closed:
            await self.http.aclose()
        self.http = None

    async def request(self, method: str, params: list[tuple[str, str]] | None = None) -> httpx.Response:
        try:
            return await self.client().request(method, STREAMS_PATH, params=params)
        except httpx.HTTPError as exc:
            raise Go2rtcError(f"go2rtc does not answer ({type(exc).__name__})")

    async def streams(self) -> dict[str, list[str]]:
        response = await self.request("GET")
        if response.status_code != 200:
            raise Go2rtcError(f"go2rtc answered HTTP {response.status_code} to the stream list")
        try:
            data = response.json() or {}
        except ValueError:
            raise Go2rtcError("go2rtc answered the stream list with invalid JSON")
        result = {}
        for name, info in data.items():
            producers = (info or {}).get("producers") or []
            result[name] = [producer["url"] for producer in producers if producer.get("url")]
        return result

    async def put(self, name: str, sources: list[str]) -> None:
        params = [("name", name), *(("src", source) for source in sources)]
        response = await self.request("PUT", params)
        if response.is_success:
            return
        current = await self.streams()
        if current.get(name) == list(sources):
            return
        raise Go2rtcError(f"go2rtc refused the stream {name} with HTTP {response.status_code}")

    async def delete(self, name: str) -> None:
        response = await self.request("DELETE", [("src", name)])
        if response.is_success:
            return
        if name not in await self.streams():
            return
        raise Go2rtcError(f"go2rtc refused to remove the stream {name} with HTTP {response.status_code}")
