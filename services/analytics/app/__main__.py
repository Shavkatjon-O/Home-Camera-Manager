"""Entry point: python -m app."""

from __future__ import annotations

import logging
import signal

from app.service import Service
from app.settings import Settings


def main() -> None:
    """Configure logging and run the service until it receives SIGTERM or SIGINT."""
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(name)s %(message)s")
    service = Service(Settings())

    def stop(signum, frame) -> None:
        """Ask the service to stop.

        Args:
            signum: Signal number.
            frame: Interrupted stack frame.
        """
        service.stopping.set()

    signal.signal(signal.SIGTERM, stop)
    signal.signal(signal.SIGINT, stop)
    service.run()


if __name__ == "__main__":
    main()
