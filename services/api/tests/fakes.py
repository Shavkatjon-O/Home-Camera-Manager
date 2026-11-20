from uuid import uuid4

from app.auth.context import UserContext
from app.modules.tenancy.enums import Role
from app.modules.tenancy.services.access import SiteAccess


def site_access(role: Role = Role.OWNER, faces: bool = True) -> SiteAccess:
    return SiteAccess(
        user=UserContext(id=1, uuid=uuid4(), username="owner@example.com", session_id=1, session_uuid=uuid4()),
        organisation_id=1,
        organisation_uuid=uuid4(),
        site_id=1,
        site_uuid=uuid4(),
        site_name="Home",
        role=role,
        timezone="UTC",
        faces_enabled=faces,
    )
