import httpx

API_PORT = 8080
TIMEOUT_SECONDS = 5.0

LIGHT_MODES = ("on", "off", "auto")


class BridgeError(Exception):
    pass


class BridgeClient:
    def __init__(self, host: str, port: int = API_PORT, timeout: float = TIMEOUT_SECONDS):
        self.base_url = f"http://{host}:{port}"
        self.timeout = timeout

    async def available(self) -> bool:
        try:
            async with httpx.AsyncClient(timeout=self.timeout) as http:
                response = await http.get(f"{self.base_url}/api/status")
        except httpx.HTTPError:
            return False
        if response.status_code != 200:
            return False
        try:
            return (response.json() or {}).get("status") == "running"
        except ValueError:
            return False

    async def post(self, path: str, params: dict | None = None) -> None:
        try:
            async with httpx.AsyncClient(timeout=self.timeout) as http:
                response = await http.post(f"{self.base_url}{path}", params=params)
        except httpx.HTTPError:
            raise BridgeError("The camera bridge does not answer")
        if response.status_code == 503:
            raise BridgeError("The bridge has no live connection to the camera")
        if response.status_code == 404:
            raise BridgeError("The camera bridge does not offer this command")
        if not response.is_success:
            raise BridgeError(f"The camera bridge answered HTTP {response.status_code}")

    async def light(self, mode: str) -> None:
        if mode not in LIGHT_MODES:
            raise BridgeError(f"Unknown light mode {mode}")
        await self.post(f"/api/light/{mode}")

    async def siren(self, seconds: int | None) -> None:
        if seconds:
            await self.post("/api/siren/on", {"seconds": str(seconds)})
        else:
            await self.post("/api/siren/off")
