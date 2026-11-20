FROM alexxit/go2rtc:1.9.14 AS go2rtc

FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim AS build

ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PYTHON_DOWNLOADS=never \
    UV_PROJECT_ENVIRONMENT=/opt/venv

WORKDIR /workspace

COPY pyproject.toml uv.lock ./
COPY services/api/pyproject.toml services/api/
COPY packages/camera-adapters packages/camera-adapters
COPY services/connector services/connector
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev --no-editable --package smart-surveillance-connector

FROM python:3.13.11-slim-bookworm

ARG REVISION=unknown
LABEL org.opencontainers.image.title="smart-surveillance-connector" \
      org.opencontainers.image.description="Connector agent: pairs with the backend and serves a site's cameras" \
      org.opencontainers.image.source="https://github.com/Shavkatjon-O/Smart-Surveillance-System" \
      org.opencontainers.image.revision="${REVISION}"

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/opt/venv/bin:${PATH}" \
    SSS_CONNECTOR_GO2RTC_BINARY=/usr/local/bin/go2rtc \
    SSS_CONNECTOR_STATE_DIR=/data

COPY --from=go2rtc /usr/local/bin/go2rtc /usr/local/bin/go2rtc
COPY --from=build /opt/venv /opt/venv

RUN groupadd --system --gid 10001 connector \
    && useradd --system --uid 10001 --gid connector --no-create-home --shell /usr/sbin/nologin connector \
    && mkdir -p /data \
    && chown connector:connector /data

USER connector

VOLUME ["/data"]

EXPOSE 8780 8554

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
    CMD ["python", "-c", "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8780/health', timeout=4)"]

CMD ["python", "-m", "connector_agent"]
