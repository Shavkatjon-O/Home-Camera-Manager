FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PYTHON_DOWNLOADS=never \
    UV_PROJECT_ENVIRONMENT=/opt/venv \
    PATH="/opt/venv/bin:${PATH}" \
    PYTHONPATH=/opt/connector

WORKDIR /app

COPY backend/pyproject.toml backend/uv.lock ./
RUN uv sync --frozen --no-dev --no-install-project

COPY backend/alembic.ini ./
COPY backend/migrations ./migrations
COPY backend/app ./app
COPY connector/adapters /opt/connector/adapters
COPY connector/catalog /opt/connector/catalog

RUN groupadd --system --gid 10001 cameras \
    && useradd --system --uid 10001 --gid cameras --no-create-home --shell /usr/sbin/nologin cameras \
    && mkdir -p /data/events \
    && chown cameras:cameras /data/events

USER cameras

EXPOSE 8000

CMD ["sh", "-c", "alembic upgrade head && exec uvicorn app.main:app --host 0.0.0.0 --port 8000 --proxy-headers --forwarded-allow-ips '*'"]
