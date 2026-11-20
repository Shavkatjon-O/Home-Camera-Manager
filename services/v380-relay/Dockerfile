FROM alexxit/go2rtc:1.9.14 AS go2rtc

FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim AS build

ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PYTHON_DOWNLOADS=never \
    UV_PROJECT_ENVIRONMENT=/opt/venv

WORKDIR /workspace

COPY pyproject.toml uv.lock ./
COPY services/api/pyproject.toml services/api/
COPY services/connector/pyproject.toml services/connector/
COPY packages/camera-adapters packages/camera-adapters
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev --no-editable --package camera-adapters

FROM python:3.13.11-slim-bookworm

ARG REVISION=unknown
LABEL org.opencontainers.image.title="smart-surveillance-v380-relay" \
      org.opencontainers.image.description="V380 relay: serves one V380 camera over RTSP and takes its controls" \
      org.opencontainers.image.source="https://github.com/Shavkatjon-O/Smart-Surveillance-System" \
      org.opencontainers.image.revision="${REVISION}"

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/opt/venv/bin:${PATH}" \
    SSS_V380_GO2RTC=/usr/local/bin/go2rtc \
    SSS_V380_CONTROL_DIR=/tmp/sss-v380

COPY --from=go2rtc /usr/local/bin/go2rtc /usr/local/bin/go2rtc
COPY --from=build /opt/venv /opt/venv

RUN groupadd --system --gid 10001 relay \
    && useradd --system --uid 10001 --gid relay --no-create-home --shell /usr/sbin/nologin relay

USER relay

EXPOSE 8554 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
    CMD ["python", "-c", "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8080/api/status', timeout=4)"]

CMD ["python", "-m", "camera_adapters.v380", "relay"]
