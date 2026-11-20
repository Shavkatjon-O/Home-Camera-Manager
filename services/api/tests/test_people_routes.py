from datetime import UTC, datetime
from types import SimpleNamespace
from uuid import uuid4

import httpx
import pytest
from fastapi import APIRouter, FastAPI, Request
from fastapi.responses import JSONResponse
from fastapi.security import HTTPAuthorizationCredentials

from app.core.exceptions import ServiceError, Unauthorized
from app.modules.investigation import deps
from app.modules.investigation.routers import people_internal_router, people_router
from app.modules.investigation.schemas import ClusterList, FaceResultAck, Gallery, PersonRead
from app.modules.tenancy.deps import get_site_access
from tests.fakes import site_access

NOW = datetime(2026, 11, 20, 5, 0, tzinfo=UTC)
PERSON = uuid4()


def person_read(uuid) -> PersonRead:
    return PersonRead(
        uuid=uuid,
        name="Alice",
        notes=None,
        color="#4f8cff",
        sample_count=0,
        upload_count=0,
        samples=[],
        last_seen_at=None,
        sightings=[],
        created_at=NOW,
        updated_at=NOW,
    )


class FakeClusters:
    async def list_page(self, page, page_size):
        return ClusterList(items=[], total=0, page=page, page_size=page_size)


class FakePeople:
    async def detail(self, uuid):
        return person_read(uuid)


class FakeSamples:
    def __init__(self, path):
        self.path = path

    async def crop(self, uuid):
        return self.path


class FakeGallery:
    async def build(self):
        return Gallery(version="0123456789abcdef", people=[], clusters=[])


class FakeFaces:
    async def store(self, payload):
        return FaceResultAck(event=payload.id, sample=uuid4(), cluster_number=None)


@pytest.fixture
async def client(tmp_path, monkeypatch):
    monkeypatch.setattr(deps, "settings", SimpleNamespace(analytics_token="secret"))
    crop = tmp_path / "crop.jpg"
    crop.write_bytes(b"\xff\xd8\xff\xe0")
    application = FastAPI()

    @application.exception_handler(ServiceError)
    async def service_error(request: Request, exc: ServiceError) -> JSONResponse:
        return JSONResponse(status_code=exc.status_code, content={"detail": {"code": exc.code}})

    v1 = APIRouter()
    v1.include_router(people_router, prefix="/people")
    application.include_router(v1, prefix="/api/v1")
    application.include_router(people_internal_router, prefix="/internal/people")
    application.dependency_overrides[get_site_access] = site_access
    application.dependency_overrides[deps.get_cluster_service] = FakeClusters
    application.dependency_overrides[deps.get_person_service] = FakePeople
    application.dependency_overrides[deps.get_sample_service] = lambda: FakeSamples(crop)
    application.dependency_overrides[deps.get_gallery_service] = FakeGallery
    application.dependency_overrides[deps.get_face_result_service] = FakeFaces
    transport = httpx.ASGITransport(app=application)
    async with httpx.AsyncClient(transport=transport, base_url="http://backend") as http:
        yield http


async def test_cluster_and_sample_routes_are_not_taken_for_a_person(client):
    clusters = await client.get("/api/v1/people/clusters")
    assert clusters.status_code == 200
    assert clusters.json()["total"] == 0
    crop = await client.get(f"/api/v1/people/samples/{uuid4()}/crop")
    assert crop.status_code == 200
    assert crop.headers["content-type"] == "image/jpeg"
    person = await client.get(f"/api/v1/people/{PERSON}")
    assert person.status_code == 200
    assert person.json()["uuid"] == str(PERSON)


async def test_internal_routes_need_the_analytics_token(client):
    assert (await client.get("/internal/people/gallery")).status_code == 401
    wrong = await client.get("/internal/people/gallery", headers={"Authorization": "Bearer nope"})
    assert wrong.status_code == 401
    assert wrong.json()["detail"]["code"] == "invalid_analytics_token"
    right = await client.get("/internal/people/gallery", headers={"Authorization": "Bearer secret"})
    assert right.status_code == 200
    assert right.json()["version"] == "0123456789abcdef"
    refused = await client.post("/internal/people/faces", json={})
    assert refused.status_code == 401


async def test_a_face_result_is_accepted_with_the_token(client):
    face = str(uuid4())
    body = {
        "id": face,
        "action": "open",
        "camera": str(uuid4()),
        "started_at": 1763600000.25,
        "seen_at": 1763600001.5,
        "status": "unknown",
        "cluster_new": True,
        "embedding": "AAAA" * 682 + "AAA=",
        "quality": 0.7,
    }
    answer = await client.post("/internal/people/faces", json=body, headers={"Authorization": "Bearer secret"})
    assert answer.status_code == 200
    assert answer.json()["event"] == face


def test_the_token_check_compares_in_constant_time_and_refuses_an_empty_setting():
    deps.check_analytics_token("secret", "secret")
    for sent, expected in [("nope", "secret"), (None, "secret"), ("", ""), ("secret", ""), ("anything", None)]:
        with pytest.raises(Unauthorized):
            deps.check_analytics_token(sent, expected)


async def test_the_dependency_reads_the_configured_token(monkeypatch):
    monkeypatch.setattr(deps, "settings", SimpleNamespace(analytics_token="secret"))
    await deps.require_analytics_token(HTTPAuthorizationCredentials(scheme="Bearer", credentials="secret"))
    with pytest.raises(Unauthorized):
        await deps.require_analytics_token(None)
    monkeypatch.setattr(deps, "settings", SimpleNamespace(analytics_token=""))
    with pytest.raises(Unauthorized):
        await deps.require_analytics_token(HTTPAuthorizationCredentials(scheme="Bearer", credentials=""))
