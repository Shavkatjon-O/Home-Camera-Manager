"""In-memory sliding-window rate limiter."""

import time
from collections import deque
from collections.abc import Callable

PRUNE_ABOVE = 1024


class RateLimiter:
    """Allow at most a number of hits per key within a sliding time window.

    Attributes:
        limit: Hits allowed per key within one window.
        window: Window length in seconds.
        clock: Function returning the current time in seconds.
        hits: Times of the recent hits for each key, oldest first.
    """

    def __init__(self, limit: int, window_seconds: float, clock: Callable[[], float] = time.monotonic):
        """Create the limiter.

        Args:
            limit: Hits allowed per key within one window.
            window_seconds: Window length in seconds.
            clock: Function returning the current time in seconds.
        """
        self.limit = limit
        self.window = window_seconds
        self.clock = clock
        self.hits: dict[str, deque[float]] = {}

    def expire(self, hits: deque[float], now: float) -> None:
        """Drop the hits that have left the window.

        Args:
            hits: Hit times of one key, oldest first.
            now: Current time in seconds.
        """
        while hits and now - hits[0] >= self.window:
            hits.popleft()

    def prune(self, now: float) -> None:
        """Forget keys with no hits left in the window once too many keys are tracked.

        Args:
            now: Current time in seconds.
        """
        if len(self.hits) <= PRUNE_ABOVE:
            return
        for key in list(self.hits):
            self.expire(self.hits[key], now)
            if not self.hits[key]:
                del self.hits[key]

    def allow(self, key: str) -> bool:
        """Record a hit for a key if the key is still under its limit.

        Args:
            key: Identity being limited, such as a client address.

        Returns:
            True when the hit was allowed and recorded, False when the key is over its limit.
        """
        now = self.clock()
        self.prune(now)
        hits = self.hits.setdefault(key, deque())
        self.expire(hits, now)
        if len(hits) >= self.limit:
            return False
        hits.append(now)
        return True
