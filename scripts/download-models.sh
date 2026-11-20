#!/bin/sh
set -eu

usage() {
  echo "usage: scripts/download-models.sh [--all]"
  echo
  echo "Downloads the analytics detector into SSS_ANALYTICS_MODELS_DIR (default services/analytics/models),"
  echo "checks every file against its pinned checksum, exports the ONNX model and prints each licence."
  echo "--all also fetches the candidates the detector was chosen from, to repeat the measurement."
}

case "${1:-}" in
  -h|--help) usage; exit 0 ;;
  --all) all=1 ;;
  "") all=0 ;;
  *) usage; exit 2 ;;
esac

root=$(cd "$(dirname "$0")/.." && pwd)
models=${SSS_ANALYTICS_MODELS_DIR:-$root/services/analytics/models}
mkdir -p "$models"
models=$(cd "$models" && pwd)

rfdetr_version=1.12.1
onnx_version=1.23.2
export_image=pytorch/pytorch:2.8.0-cuda12.8-cudnn9-runtime
ngc=https://api.ngc.nvidia.com/v2/models/nvidia/tao

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

export_rfdetr() {
  variant=$1 height=$2 width=$3 weights=$4 sum=$5
  folder=$models/rf-detr/v1
  target=$folder/rf-detr-$variant-${height}x$width.onnx
  if [ -f "$target" ]; then
    echo "ok       $target"
    return
  fi
  echo "exporting $target with rfdetr $rfdetr_version in $export_image"
  docker run --rm -i --memory=12g --cpus=8 -u "$(id -u):$(id -g)" -e HOME=/tmp -e PYTHONUSERBASE=/tmp/py \
    -v "$folder:/weights" -w /tmp "$export_image" sh -c \
    "pip install --user --quiet --no-warn-script-location rfdetr==$rfdetr_version onnx==$onnx_version \
     && prlimit --as=48000000000 -- python - $variant $height $width /weights/$weights /weights" <<'PY'
import sys
from pathlib import Path

import numpy as np
import onnx
import rfdetr
from onnx import helper, numpy_helper

variants = {
    "nano": rfdetr.RFDETRNano,
    "small": rfdetr.RFDETRSmall,
    "medium": rfdetr.RFDETRMedium,
    "large-2026": rfdetr.RFDETRLarge,
}
variant, height, width, weights, out_dir = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), sys.argv[4], sys.argv[5]
model = variants[variant](pretrain_weights=weights)
path = Path(
    model.export(
        output_dir=out_dir,
        shape=(height, width),
        dynamic_batch=True,
        batch_size=1,
        opset_version=17,
        output_name=f"rf-detr-{variant}-{height}x{width}",
        verbose=False,
    )
)
exported = onnx.load(str(path))
graph = exported.graph
name = graph.input[0].name
for node in graph.node:
    for index, value in enumerate(node.input):
        if value == name:
            node.input[index] = "normalized_input"
mean = numpy_helper.from_array(np.array([0.485, 0.456, 0.406], np.float32).reshape(1, 3, 1, 1), "imagenet_mean")
std = numpy_helper.from_array(np.array([0.229, 0.224, 0.225], np.float32).reshape(1, 3, 1, 1), "imagenet_std")
graph.initializer.extend([mean, std])
graph.node.insert(0, helper.make_node("Div", ["centered_input", "imagenet_std"], ["normalized_input"]))
graph.node.insert(0, helper.make_node("Sub", [name, "imagenet_mean"], ["centered_input"]))
for output in graph.output:
    fixed = [300, 4] if output.name == "dets" else [300, 91]
    for dim, value in zip(output.type.tensor_type.shape.dim[1:], fixed):
        dim.ClearField("dim_param")
        dim.dim_value = value
onnx.checker.check_model(exported)
onnx.save(exported, str(path))
PY
  actual=$(checksum "$target")
  if [ "$actual" = "$sum" ]; then
    echo "ok       $target"
  else
    echo "note     $target differs from the reference export ($actual), check the detector before use"
  fi
}

rfdetr() {
  variant=$1 url=$2 weights_sum=$3 height=$4 width=$5 onnx_sum=$6
  fetch "$url" "$models/rf-detr/v1/rf-detr-$variant.pth" "$weights_sum"
  export_rfdetr "$variant" "$height" "$width" "rf-detr-$variant.pth" "$onnx_sum"
}

rfdetr medium https://repo.roboflow.com/rfdetr/medium_coco/checkpoint_best_regular.pth \
  749ff6071828aaffac63e204c4f4135ed3d6cdae4d702e086c360edc3b5768c8 576 1024 \
  db8523f2bd18e2254391592ef49246cd1da219688c5ecf606de9533a763ea863
echo "licence  RF-DETR code and weights: Apache License 2.0 (https://github.com/roboflow/rf-detr)"

if [ "$all" = 1 ]; then
  rfdetr nano https://repo.roboflow.com/rfdetr/nano_coco/checkpoint_best_regular.pth \
    d8d6b9ee57d4d0ed2b1f305163624712a0532cb7bce0c747317984fc5457440d 384 672 \
    4f28e140c3ee64bf57b7726db39b95afe3607a22e541a7ee81731297d6ec6d51
  rfdetr small https://repo.roboflow.com/rfdetr/small_coco/checkpoint_best_regular.pth \
    d81979a9213a2109345158ce9232668df4c1ae52e9b8db3f2ec0a8cbad959b33 512 896 \
    c9f0428f2e3f325e9b11a179a115f698e26db95239ac15175f65f53e1de37ea6
  rfdetr large-2026 https://repo.roboflow.com/rfdetr/rf-detr-large-2026.pth \
    0f4e20e19a99c0f8a62b5685f57f6c8b5c371c59081feda6752a0561a79ccf38 704 1248 \
    5a588ade90e1b27615116fb454e7018e2f9b816a69dcd6dc16c6267a749f5ac4
  people=$ngc/peoplenet/versions/deployable_quantized_onnx_v2.6.3/files
  fetch "$people/resnet34_peoplenet.onnx" "$models/peoplenet/v1/resnet34_peoplenet.onnx" \
    a6aa31618f8476261807b5ba26b9841c684708c66a5f0be460a25a972f8ee7ad
  fetch "$people/labels.txt" "$models/peoplenet/v1/labels.txt" \
    4b704bf9460d3990a6579f7a61134ad275e119d69c9da4ffe2ac1c4c472bb4bf
  echo "licence  PeopleNet: NVIDIA Open Model License"
  traffic=$ngc/trafficcamnet/versions/pruned_onnx_v1.0.4/files
  fetch "$traffic/resnet18_trafficcamnet_pruned.onnx" "$models/trafficcamnet/v1/resnet18_trafficcamnet_pruned.onnx" \
    d92f97bd840b68850a33c83e480fc6bd83b3097ff4cb517e0ea12671046bab7d
  fetch "$traffic/labels.txt" "$models/trafficcamnet/v1/labels.txt" \
    b8fc01e784d4b3e2f0c9daf5c96da4c41afe0895b3143cb4243c631aea8851a2
  echo "licence  TrafficCamNet: NVIDIA Open Model License"
fi
