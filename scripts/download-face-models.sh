#!/bin/sh
set -eu

usage() {
  echo "usage: scripts/download-face-models.sh [--keep-archive]"
  echo
  echo "Downloads the InsightFace antelopev2 pack from the InsightFace model zoo release, checks the archive and"
  echo "the two models the face stage uses against their pinned checksums, extracts them into"
  echo "SSS_ANALYTICS_FACE_MODELS_DIR (default analytics/models/face) and prints their licence."
  echo "--keep-archive keeps the downloaded zip next to the models."
}

case "${1:-}" in
  -h|--help) usage; exit 0 ;;
  --keep-archive) keep=1 ;;
  "") keep=0 ;;
  *) usage; exit 2 ;;
esac

root=$(cd "$(dirname "$0")/.." && pwd)
models=${SSS_ANALYTICS_FACE_MODELS_DIR:-$root/analytics/models/face}
mkdir -p "$models"
models=$(cd "$models" && pwd)

archive_url=https://github.com/deepinsight/insightface/releases/download/model-zoo/antelopev2.zip
archive_sum=8e182f14fc6e80b3bfa375b33eb6cff7ee05d8ef7633e738d1c89021dcf0c5c5
detector=scrfd_10g_bnkps.onnx
detector_sum=5838f7fe053675b1c7a08b633df49e7af5495cee0493c7dcf6697200b85b5b91
embedder=glintr100.onnx
embedder_sum=4ab1d6435d639628a6f3e5008dd4f929edf4c4124b1a7169e1048f9fef534cdf

checksum() {
  sha256sum "$1" | cut -d' ' -f1
}

verified() {
  [ -f "$1" ] && [ "$(checksum "$1")" = "$2" ]
}

if verified "$models/$detector" "$detector_sum" && verified "$models/$embedder" "$embedder_sum"; then
  echo "ok       $models/$detector"
  echo "ok       $models/$embedder"
else
  archive=$models/antelopev2.zip
  if ! verified "$archive" "$archive_sum"; then
    echo "fetching $archive_url"
    curl -fL --retry 3 --silent --show-error -o "$archive.part" "$archive_url"
    actual=$(checksum "$archive.part")
    if [ "$actual" != "$archive_sum" ]; then
      rm -f "$archive.part"
      echo "checksum mismatch for antelopev2.zip: expected $archive_sum, got $actual" >&2
      exit 1
    fi
    mv "$archive.part" "$archive"
  fi
  python3 - "$archive" "$models" "$detector" "$embedder" <<'PY'
import shutil
import sys
import zipfile
from pathlib import Path

archive, target, wanted = sys.argv[1], Path(sys.argv[2]), set(sys.argv[3:])
with zipfile.ZipFile(archive) as pack:
    for member in pack.infolist():
        name = Path(member.filename).name
        if name in wanted:
            with pack.open(member) as source, open(target / f"{name}.part", "wb") as copy:
                shutil.copyfileobj(source, copy)
            (target / f"{name}.part").replace(target / name)
            wanted.discard(name)
if wanted:
    sys.exit(f"antelopev2.zip lacks {', '.join(sorted(wanted))}")
PY
  for pair in "$detector:$detector_sum" "$embedder:$embedder_sum"; do
    file=${pair%%:*}
    sum=${pair#*:}
    if ! verified "$models/$file" "$sum"; then
      echo "checksum mismatch for $file after extraction" >&2
      exit 1
    fi
    chmod 0644 "$models/$file"
    echo "ok       $models/$file"
  done
  if [ "$keep" = 0 ]; then
    rm -f "$archive"
  fi
fi

echo "licence  InsightFace antelopev2 (SCRFD 10G and glintr100): the InsightFace model zoo publishes these weights"
echo "         for non-commercial research use only (https://github.com/deepinsight/insightface/tree/master/model_zoo)"
