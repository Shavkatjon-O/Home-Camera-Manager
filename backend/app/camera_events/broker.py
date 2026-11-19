import asyncio
from contextlib import contextmanager

QUEUE_SIZE = 200


class EventBroker:
    def __init__(self):
        self.queues: set[asyncio.Queue] = set()

    @contextmanager
    def subscribe(self):
        queue: asyncio.Queue = asyncio.Queue(maxsize=QUEUE_SIZE)
        self.queues.add(queue)
        try:
            yield queue
        finally:
            self.queues.discard(queue)

    def publish(self, kind: str, payload: dict) -> None:
        message = {"type": kind, "data": payload}
        for queue in list(self.queues):
            if queue.full():
                while not queue.empty():
                    queue.get_nowait()
                queue.put_nowait({"type": "overflow", "data": {}})
                continue
            queue.put_nowait(message)

    @property
    def listeners(self) -> int:
        return len(self.queues)
