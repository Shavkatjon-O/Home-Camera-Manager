#!/bin/sh
#
# Copies the sample videos the simulated cameras loop out of the DeepStream image into tools/devkit/samples, which
# git ignores, so the videos never enter the repository. Existing copies are kept.

set -eu

ROOT=$(cd "$(dirname "$0")/.." && pwd)
IMAGE=${DEVKIT_SAMPLES_IMAGE:-nvcr.io/nvidia/deepstream:9.1-samples-multiarch}
OUT=$ROOT/tools/devkit/samples
FILES="sample_1080p_h264.mp4 sample_qHD.mp4 sample_cam5.mp4 sample_cam6.mp4 sample_office.mp4 sample_720p.mp4"

mkdir -p "$OUT"
missing=""
for file in $FILES; do
  [ -s "$OUT/$file" ] || missing="$missing $file"
done
if [ -z "$missing" ]; then
  echo "devkit-samples: every sample video is in $OUT"
  exit 0
fi

container=$(docker create "$IMAGE")
trap 'docker rm -f "$container" >/dev/null' EXIT
for file in $missing; do
  docker cp "$container:/opt/nvidia/deepstream/deepstream/samples/streams/$file" "$OUT/$file"
done
echo "devkit-samples: copied$missing into $OUT"
