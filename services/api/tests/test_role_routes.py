from uuid import uuid4

import httpx
import pytest
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

from app.api.v1_routers import v1_routers
from app.core.database import get_db
from app.core.exceptions import ServiceError
from app.modules.investigation import deps as people_deps
from app.modules.investigation.schemas import PersonList
from app.modules.tenancy.deps import get_site_access
from app.modules.tenancy.enums import Role
from tests.fakes import site_access

UUID = uuid4()

OPERATOR_ROUTES = [
    ("PUT", "/api/v1/analytics/settings"),
    ("POST", f"/api/v1/cameras/{UUID}/ptz/move"),
    ("POST", f"/api/v1/events/{UUID}/acknowledge"),
]

ADMIN_ROUTES = [
    ("POST", "/api/v1/cameras"),
    ("PATCH", f"/api/v1/analytics/views/{UUID}"),
    ("POST", "/api/v1/connectors/claim"),
]


class FakePeople:
    async def list_page(self, page, page_size):
        return PersonList(items=[], total=0, page=page, page_size=page_size)


class FakeSession:
    async def scalar(self, statement):
        return None


def build(role):
    application = FastAPI()

    @application.exception_handler(ServiceError)
    async def service_error(request: Request, exc: ServiceError) -> JSONResponse:
        return JSONResponse(status_code=exc.status_code, content={"detail": {"code": exc.code, "message": exc.message}})

    application.include_router(v1_routers, prefix="/api/v1")
    application.dependency_overrides[get_site_access] = lambda: site_access(role=role)
    application.dependency_overrides[get_db] = FakeSession
    application.dependency_overrides[people_deps.get_person_service] = FakePeople
    return application


@pytest.fixture
def client_for():
    async def make(role):
        transport = httpx.ASGITransport(app=build(role))
        return httpx.AsyncClient(transport=transport, base_url="http://backend")

    return make


@pytest.mark.parametrize("method,path", OPERATOR_ROUTES + ADMIN_ROUTES + [("GET", "/api/v1/people")])
async def test_viewer_is_refused_with_role_required(client_for, method, path):
    http = await client_for(Role.VIEWER)
    async with http:
        answer = await http.request(method, path, json={})
    assert answer.status_code == 403
    assert answer.json()["detail"]["code"] == "role_required"


@pytest.mark.parametrize("method,path", ADMIN_ROUTES + [("GET", "/api/v1/people")])
async def test_operator_is_refused_on_admin_routes(client_for, method, path):
    http = await client_for(Role.OPERATOR)
    async with http:
        answer = await http.request(method, path, json={})
    assert answer.status_code == 403
    assert answer.json()["detail"]["code"] == "role_required"
    assert "admin" in answer.json()["detail"]["message"]


@pytest.mark.parametrize("method,path", OPERATOR_ROUTES)
async def test_operator_passes_the_role_check_of_operator_routes(client_for, method, path):
    http = await client_for(Role.OPERATOR)
    async with http:
        answer = await http.request(method, path, json={"unknown": True})
    assert answer.status_code in (404, 422)


@pytest.mark.parametrize("role", [Role.ADMIN, Role.OWNER])
@pytest.mark.parametrize("method,path", OPERATOR_ROUTES + ADMIN_ROUTES)
async def test_admin_and_owner_pass_every_role_check(client_for, role, method, path):
    http = await client_for(role)
    async with http:
        answer = await http.request(method, path, json={"unknown": True})
    assert answer.status_code in (404, 422)


@pytest.mark.parametrize("role", [Role.ADMIN, Role.OWNER])
async def test_admin_lists_people_through_the_fake_service(client_for, role):
    http = await client_for(role)
    async with http:
        answer = await http.get("/api/v1/people")
    assert answer.status_code == 200
    assert answer.json()["total"] == 0
