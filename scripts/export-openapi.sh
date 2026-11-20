#!/bin/sh
#
# Writes the API's OpenAPI document to packages/contracts/openapi.json, or to the path given as the first
# argument, by importing the API in a throwaway container.

set -eu

ROOT=$(cd "$(dirname "$0")/.." && pwd)
OUT=${1:-$ROOT/packages/contracts/openapi.json}

docker run --rm -i --memory=2g -u "$(id -u):$(id -g)" \
  -e HOME=/tmp -e UV_PROJECT_ENVIRONMENT=/tmp/venv -e UV_CACHE_DIR=/tmp/uv-cache -e PYTHONDONTWRITEBYTECODE=1 \
  -e SSS_SECRET_KEY=openapi-export -e PYTHONPATH=/repo/packages/camera-adapters \
  -v "$ROOT:/repo:ro" -w /repo/services/api \
  ghcr.io/astral-sh/uv:python3.13-bookworm-slim \
  sh -c 'uv sync --frozen --quiet && uv run --frozen --quiet python -' > "$OUT.tmp" <<'PY'
import json

from app.main import app

print(json.dumps(app.openapi(), indent=2, ensure_ascii=True))
PY

mv "$OUT.tmp" "$OUT"
echo "Wrote $OUT"
