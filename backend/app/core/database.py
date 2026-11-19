"""Async database engine, session factory and declarative base."""

import json
from collections.abc import AsyncGenerator
from datetime import date, datetime
from decimal import Decimal
from enum import Enum
from uuid import UUID

from sqlalchemy import MetaData, text
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import DeclarativeBase

from app.core.config import settings

naming_convention = {
    "ix": "ix_%(column_0_label)s",
    "uq": "uq_%(table_name)s_%(column_0_name)s",
    "ck": "ck_%(table_name)s_%(constraint_name)s",
    "fk": "fk_%(table_name)s_%(column_0_name)s_%(referred_table_name)s",
    "pk": "pk_%(table_name)s",
}


class Base(DeclarativeBase):
    """Declarative base whose metadata names constraints and indexes predictably.

    Attributes:
        metadata: Metadata carrying the constraint naming convention.
    """

    metadata = MetaData(naming_convention=naming_convention)


def json_default(value):
    """Convert a value the json module cannot encode into one it can.

    Args:
        value: Value found while encoding a JSON column.

    Returns:
        ISO text for dates and times, text for UUIDs, a float for decimals, the value of an enum
        member and a list for sets.

    Raises:
        TypeError: The value has no JSON form.
    """
    if isinstance(value, (datetime, date)):
        return value.isoformat()
    if isinstance(value, UUID):
        return str(value)
    if isinstance(value, Decimal):
        return float(value)
    if isinstance(value, Enum):
        return value.value
    if isinstance(value, (set, frozenset)):
        return list(value)
    raise TypeError(f"Object of type {type(value).__name__} is not JSON serializable")


def json_serializer(value) -> str:
    """Encode a JSON column value, converting types the json module does not know.

    Args:
        value: Value stored in a JSON column.

    Returns:
        The JSON text.
    """
    return json.dumps(value, default=json_default)


async_engine = create_async_engine(
    settings.database_url,
    pool_pre_ping=True,
    pool_size=10,
    max_overflow=20,
    json_serializer=json_serializer,
)

async_session_maker = async_sessionmaker(
    bind=async_engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autoflush=False,
)


async def verify_db_connection() -> None:
    """Run a trivial query to prove the database is reachable."""
    async with async_engine.connect() as connection:
        await connection.execute(text("SELECT 1"))


async def get_db() -> AsyncGenerator[AsyncSession]:
    """Open a database session for one request.

    Yields:
        Session that closes when the request ends.
    """
    async with async_session_maker() as session:
        yield session
