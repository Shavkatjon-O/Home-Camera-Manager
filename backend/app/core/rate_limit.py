import time
from collections import deque
from collections.abc import Callable

PRUNE_ABOVE = 1024


class RateLimiter:
    def __init__(self, limit: int, window_seconds: float, clock: Callable[[], float] = time.monotonic):
        self.limit = limit
        self.window = window_seconds
        self.clock = clock
        self.hits: dict[str, deque[float]] = {}

    def expire(self, hits: deque[float], now: float) -> None:
        while hits and now - hits[0] >= self.window:
            hits.popleft()

    def prune(self, now: float) -> None:
        if len(self.hits) <= PRUNE_ABOVE:
            return
        for key in list(self.hits):
            self.expire(self.hits[key], now)
            if not self.hits[key]:
                del self.hits[key]

    def allow(self, key: str) -> bool:
        now = self.clock()
        self.prune(now)
        hits = self.hits.setdefault(key, deque())
        self.expire(hits, now)
        if len(hits) >= self.limit:
            return False
        hits.append(now)
        return True
