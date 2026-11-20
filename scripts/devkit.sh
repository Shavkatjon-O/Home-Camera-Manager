#!/bin/sh
#
# Runs the development kit: the compose project smart-surveillance-dev from docker-compose.yml with the
# docker-compose.dev.yml overlay and the gitignored .env.dev, with the simulated site of the devkit profile.
# Commands:
#   init: create .env.dev from .env.dev.example with generated secrets and copy the sample videos
#   up: build and start the kit in the background
#   seed: create the demo organisation, its sites, members, cameras, analytics settings and history
#   anything else: passed to docker compose, as in scripts/devkit.sh logs -f backend

set -eu

ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"

compose() {
  COMPOSE_PROFILES=${COMPOSE_PROFILES:-devkit} docker compose -p smart-surveillance-dev --env-file .env.dev \
    -f docker-compose.yml -f docker-compose.dev.yml "$@"
}

secret() {
  head -c 24 /dev/urandom | od -An -tx1 | tr -d ' \n'
}

fill() {
  key=$1
  value=$2
  if grep -q "^$key=$" .env.dev; then
    sed -i "s|^$key=$|$key=$value|" .env.dev
  fi
}

init() {
  if [ ! -f .env.dev ]; then
    cp .env.dev.example .env.dev
    chmod 600 .env.dev
  fi
  fill SSS_SECRET_KEY "$(secret)"
  fill SSS_TV_RTSP_PASSWORD "$(secret)"
  fill SSS_ANALYTICS_TOKEN "$(secret)"
  fill SSS_DEV_CAMERA_PASSWORD "$(secret)"
  fill SSS_DEMO_PASSWORD "$(secret)"
  fill SSS_TELEGRAM_WEBHOOK_SECRET "$(secret)"
  sh scripts/devkit-samples.sh
}

if [ ! -f .env.dev ] && [ "${1:-}" != "init" ]; then
  echo "devkit: run scripts/devkit.sh init first" >&2
  exit 1
fi

case "${1:-}" in
  init)
    init
    ;;
  up)
    shift
    compose up -d --build --wait "$@"
    ;;
  seed)
    shift
    compose exec -T backend python -m app.devkit.seed "$@"
    ;;
  *)
    compose "$@"
    ;;
esac
