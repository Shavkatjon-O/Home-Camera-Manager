import logging
from contextlib import asynccontextmanager

from fastapi import APIRouter, FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from sqlalchemy.exc import SQLAlchemyError
from starlette.exceptions import HTTPException as StarletteHTTPException

from app.api.v1_routers import v1_routers
from app.camera_events.engine import camera_events
from app.core.config import APP_NAME, APP_VERSION
from app.core.database import async_engine, verify_db_connection
from app.core.exceptions import ServiceError, Unavailable
from app.core.logging import setup_logging
from app.core.security import require_secret_key
from app.core.seed import seed_admin
from app.health.prober import health_prober
from app.modules.tv.routers import tv_internal_router
from app.streaming.supervisor import supervisor

setup_logging()
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(application: FastAPI):
    require_secret_key()
    await verify_db_connection()
    await seed_admin()
    await supervisor.start()
    await health_prober.start()
    await camera_events.start()
    logger.info("%s %s started", APP_NAME, APP_VERSION)
    yield
    await camera_events.stop()
    await health_prober.stop()
    await supervisor.stop()
    await async_engine.dispose()


app = FastAPI(title=APP_NAME, version=APP_VERSION, lifespan=lifespan)


def error_body(code: str, message: str) -> dict:
    return {"detail": {"code": code, "message": message}}


@app.exception_handler(ServiceError)
async def service_error_handler(request: Request, exc: ServiceError) -> JSONResponse:
    return JSONResponse(status_code=exc.status_code, content=error_body(exc.code, exc.message))


@app.exception_handler(StarletteHTTPException)
async def http_error_handler(request: Request, exc: StarletteHTTPException) -> JSONResponse:
    code = {404: "not_found", 405: "method_not_allowed"}.get(exc.status_code, f"http_{exc.status_code}")
    message = exc.detail if isinstance(exc.detail, str) else "Request failed"
    return JSONResponse(status_code=exc.status_code, content=error_body(code, message), headers=exc.headers)


@app.exception_handler(RequestValidationError)
async def validation_error_handler(request: Request, exc: RequestValidationError) -> JSONResponse:
    parts = []
    for error in exc.errors():
        location = ".".join(str(part) for part in error.get("loc", ()) if part not in ("body", "query", "path"))
        parts.append(f"{location}: {error.get('msg')}" if location else str(error.get("msg")))
    return JSONResponse(status_code=422, content=error_body("validation_error", "; ".join(parts)))


@app.exception_handler(Exception)
async def unexpected_error_handler(request: Request, exc: Exception) -> JSONResponse:
    logger.exception("Unhandled error on %s %s", request.method, request.url.path)
    return JSONResponse(status_code=500, content=error_body("internal_error", "Something went wrong"))


async def health_status() -> dict:
    try:
        await verify_db_connection()
    except (SQLAlchemyError, OSError) as exc:
        logger.warning("Health check failed: %s", exc)
        raise Unavailable("database_unavailable", "The database does not answer")
    return {"status": "ok"}


health_router = APIRouter()


@health_router.get("/health", tags=["health"])
async def health() -> dict:
    return await health_status()


@app.get("/", tags=["health"])
async def root() -> dict:
    return {"service": APP_NAME, "version": APP_VERSION}


app.include_router(health_router)
app.include_router(health_router, prefix="/api/v1")
app.include_router(v1_routers, prefix="/api/v1")
app.include_router(tv_internal_router, prefix="/internal/tv", include_in_schema=False)
