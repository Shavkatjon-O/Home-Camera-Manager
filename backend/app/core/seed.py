"""Creation of the first admin user from the settings."""

import logging

from sqlalchemy import select
from sqlalchemy.exc import IntegrityError

from app.core.config import settings
from app.core.database import async_session_maker
from app.core.security import hash_password
from app.models import User

logger = logging.getLogger(__name__)


async def seed_admin() -> None:
    """Create the admin user named in the settings unless that user already exists.

    Nothing is created when the admin username or password is empty, and a concurrent insert of
    the same user is ignored.
    """
    username = settings.admin_username.strip()
    if not username or not settings.admin_password:
        logger.info("HC_ADMIN_USERNAME or HC_ADMIN_PASSWORD is empty, no admin is seeded")
        return
    async with async_session_maker() as session:
        existing = await session.scalar(select(User.id).where(User.username == username).limit(1))
        if existing is not None:
            return
        session.add(User(username=username, password_hash=hash_password(settings.admin_password)))
        try:
            await session.commit()
        except IntegrityError:
            await session.rollback()
            return
        logger.info("Seeded the admin user %s", username)
