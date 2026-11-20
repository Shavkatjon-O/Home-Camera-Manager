#!/bin/sh
# Generates the Dart API client from the platform's OpenAPI contract.
# Usage: scripts/generate-api.sh [path to openapi.json]
set -eu
cd "$(dirname "$0")/.."
contract="${1:-../../packages/contracts/openapi.json}"
rm -rf lib/core/network/api
dart run swagger_parser "$contract"
dart run build_runner build
