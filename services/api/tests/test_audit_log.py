from uuid import uuid4

import httpx
from fastapi import Depends, FastAPI, Request
from fastapi.responses import JSONResponse

from app.core.exceptions import NotFound, ServiceError
from app.modules.identity.deps import get_current_user
from app.modules.operations import deps as operations_deps
from app.modules.operations.deps import audited, audited_account, path_uuid
from app.modules.operations.enums import AuditAction
from app.modules.operations.services.audit import record_audit
from app.modules.tenancy.deps import get_site_access
from tests.fakes import site_access


class Session:
    def __init__(self):
        self.added = []

    def add(self, item):
        self.added.append(item)


async def test_a_record_keeps_the_actor_and_what_was_done():
    session = Session()
    access = site_access()
    target = uuid4()
    record = await record_audit(
        session,
        AuditAction.CAMERA_DELETE,
        actor=access.user,
        organisation_id=1,
        site_id=1,
        target_kind="camera",
        target_uuid=target,
        details={"path": "/api/v1/cameras/x"},
        ip="127.0.0.1",
    )
    assert session.added == [record]
    assert (record.actor_id, record.actor, record.action) == (1, "owner@example.com", "camera_delete")
    assert (record.organisation_id, record.site_id, record.target_uuid) == (1, 1, target)


def application(written):
    app = FastAPI()

    @app.exception_handler(ServiceError)
    async def failure(request: Request, exc: ServiceError) -> JSONResponse:
        return JSONResponse(status_code=exc.status_code, content={"code": exc.code})

    @app.delete("/cameras/{uuid}", dependencies=[Depends(audited(AuditAction.CAMERA_DELETE, "camera"))])
    async def delete_camera(uuid: str, fail: bool = False):
        if fail:
            raise NotFound("camera_not_found", "No such camera")
        return {"ok": True}

    @app.post(
        "/organisations/{organisation}/members/{member}",
        dependencies=[Depends(audited_account(AuditAction.MEMBER_UPDATE, "member", target="member"))],
    )
    async def update_member(organisation: str, member: str):
        return {"ok": True}

    async def write(action, **facts):
        written.append((action, facts))

    app.dependency_overrides[get_site_access] = site_access
    app.dependency_overrides[get_current_user] = lambda: site_access().user
    operations_deps.write_audit = write
    return app


async def test_routes_are_audited_only_when_they_succeed(monkeypatch):
    written = []
    original = operations_deps.write_audit
    try:
        app = application(written)
        camera = uuid4()
        async with httpx.AsyncClient(transport=httpx.ASGITransport(app=app), base_url="http://api") as http:
            assert (await http.delete(f"/cameras/{camera}?fail=true")).status_code == 404
            assert written == []
            assert (await http.delete(f"/cameras/{camera}")).status_code == 200
            organisation, member = uuid4(), uuid4()
            assert (await http.post(f"/organisations/{organisation}/members/{member}")).status_code == 200
    finally:
        operations_deps.write_audit = original
    (first, facts), (second, account) = written
    assert first == AuditAction.CAMERA_DELETE and facts["target_uuid"] == camera
    assert facts["organisation_id"] == 1 and facts["details"] == {"method": "DELETE", "path": f"/cameras/{camera}"}
    assert second == AuditAction.MEMBER_UPDATE
    assert account["organisation_uuid"] == organisation and account["target_uuid"] == member


def test_path_ids_that_are_not_ids_are_ignored():
    class Fake:
        path_params = {"uuid": "not-an-id", "organisation": str(uuid4())}

    assert path_uuid(Fake(), "uuid") is None and path_uuid(Fake(), None) is None
    assert path_uuid(Fake(), "organisation") is not None
