"""Start the connector agent: python -m connector_agent."""

import asyncio
import logging

from connector_agent.agent import Agent
from connector_agent.settings import load_settings


def main() -> None:
    """Configure logging and run the agent until it is stopped."""
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(name)s %(message)s")
    logging.getLogger("httpx").setLevel(logging.WARNING)
    asyncio.run(Agent(load_settings()).run())


if __name__ == "__main__":
    main()
