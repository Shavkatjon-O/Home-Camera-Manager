#!/bin/sh
set -eu

usage() {
  echo "usage: scripts/download-secondary-models.sh"
  echo
  echo "Downloads the models of the secondary analytics stages into HC_ANALYTICS_MODELS_DIR (default analytics/models):"
  echo "person re-identification, body pose for falls, number plate detection and plate text recognition."
  echo "Every file is checked against its pinned checksum and each licence is printed."
}

case "${1:-}" in
  -h|--help) usage; exit 0 ;;
  "") ;;
  *) usage; exit 2 ;;
esac

root=$(cd "$(dirname "$0")/.." && pwd)
models=${HC_ANALYTICS_MODELS_DIR:-$root/analytics/models}
mkdir -p "$models"
models=$(cd "$models" && pwd)

ngc=https://api.ngc.nvidia.com/v2/models/nvidia/tao
openmmlab=https://download.openmmlab.com/mmpose/v1/projects/rtmposev1/onnx_sdk
rapidocr=https://www.modelscope.cn/models/RapidAI/RapidOCR/resolve/v3.10.0

checksum() {
  sha256sum "$1" | cut -d' ' -f1
}

fetch() {
  url=$1 target=$2 sum=$3
  mkdir -p "$(dirname "$target")"
  if [ -f "$target" ] && [ "$(checksum "$target")" = "$sum" ]; then
    echo "ok       $target"
    return
  fi
  echo "fetching $target"
  curl -fL --retry 3 --silent --show-error -o "$target.part" "$url"
  actual=$(checksum "$target.part")
  if [ "$actual" != "$sum" ]; then
    rm -f "$target.part"
    echo "checksum mismatch for $target: expected $sum, got $actual" >&2
    exit 1
  fi
  mv "$target.part" "$target"
  echo "ok       $target"
}

extract() {
  archive=$1 member=$2 target=$3 sum=$4
  if [ -f "$target" ] && [ "$(checksum "$target")" = "$sum" ]; then
    echo "ok       $target"
    return
  fi
  unzip -p "$archive" "$member" > "$target.part"
  actual=$(checksum "$target.part")
  if [ "$actual" != "$sum" ]; then
    rm -f "$target.part"
    echo "checksum mismatch for $target: expected $sum, got $actual" >&2
    exit 1
  fi
  mv "$target.part" "$target"
  echo "ok       $target"
}

fetch https://huggingface.co/mprib/osnet-ain-x1-0-msmt17-onnx/resolve/main/osnet_ain_x1_0_msmt17.onnx \
  "$models/osnet/v1/osnet_ain_x1_0_msmt17.onnx" \
  f11a8fa82c3980f13f563210ddf197346bbd8d1bd0dca364c4ad6c4e39794116
echo "licence  OSNet-AIN x1.0 code and weights: MIT (https://github.com/KaiyangZhou/deep-person-reid)"

pose=rtmpose-m_simcc-body7_pt-body7_420e-256x192-e48f03d0_20230504
fetch "$openmmlab/$pose.zip" "$models/rtmpose/v1/$pose.zip" \
  f7fbb6c5c11a1bb70f3d445e4ddec5d144ea89ad5649c081ef976f9b24a0b741
extract "$models/rtmpose/v1/$pose.zip" "20230831/rtmpose_onnx/$pose/end2end.onnx" \
  "$models/rtmpose/v1/rtmpose-m-body7-256x192.onnx" \
  5c0a4bf67953e6d2ac43ce15e77dc9d5d354ae18430a47d2c5963a7bc5683e3c
echo "licence  RTMPose code and weights: Apache License 2.0 (https://github.com/open-mmlab/mmpose)"

fetch "$ngc/lpdnet/versions/pruned_v2.2/files/LPDNet_usa_pruned_tao5.onnx" \
  "$models/lpdnet/v1/LPDNet_usa_pruned_tao5.onnx" \
  8174ff09e316ec9fcc74ff0947bc73536a6f25a33aae1c52e9effab8a91c7930
echo "licence  LPDNet: NVIDIA model card states commercial use, under the NVIDIA AI Enterprise EULA"

fetch "$rapidocr/onnx/PP-OCRv4/rec/en_PP-OCRv4_rec_mobile.onnx" \
  "$models/paddleocr/v1/en_PP-OCRv4_rec_mobile.onnx" \
  e8770c967605983d1570cdf5352041dfb68fa0c21664f49f47b155abd3e0e318
fetch "$rapidocr/paddle/PP-OCRv4/rec/en_PP-OCRv4_rec_mobile/en_dict.txt" \
  "$models/paddleocr/v1/en_dict.txt" \
  5662df9d2d03f0e8ca0d3b0649d6acbab904b6a14b3d3521463c71c37c668ce3
echo "licence  PaddleOCR PP-OCRv4 recognition, ONNX by RapidOCR: Apache License 2.0 (https://github.com/PaddlePaddle/PaddleOCR)"
