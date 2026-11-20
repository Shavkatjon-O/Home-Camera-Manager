#!/bin/sh
#
# Writes the NvDCF tracker configuration from the copy in the DeepStream base image, changing only the values the
# analytics service sets. Fails when the base file is missing or differs from the pinned release, so a new base
# image is reviewed before its tracker settings are used. Arguments: base file, output file and, for tests, the
# checksum to expect instead of the pinned one.

set -eu

BASE=${1:-/opt/nvidia/deepstream/deepstream/samples/configs/deepstream-app/config_tracker_NvDCF_perf.yml}
OUT=${2:-/opt/analytics/configs/tracker.yml}
PINNED=${3:-383002ab8628203a6921616adf46c371e261b9a76509943e4b61657f9102e86c}

if [ ! -f "$BASE" ]; then
  echo "tracker-config: the base tracker configuration $BASE is missing" >&2
  exit 1
fi

if [ "$(sha256sum "$BASE" | cut -d ' ' -f 1)" != "$PINNED" ]; then
  echo "tracker-config: $BASE differs from the pinned release; review it and update PINNED" >&2
  exit 1
fi

set_value() {
  key=$1
  from=$2
  to=$3
  count=$(grep -cE "^  $key: $from( |\$)" "$OUT" || true)
  if [ "$count" != "1" ]; then
    echo "tracker-config: expected one $key: $from in $BASE, found $count" >&2
    exit 1
  fi
  sed -i -E "s/^(  $key: )$from( |\$)/\1$to\2/" "$OUT"
}

mkdir -p "$(dirname "$OUT")"
cp "$BASE" "$OUT"

set_value maxTargetsPerStream 150 60
set_value probationAge 2 3
set_value maxShadowTrackingAge 51 30
