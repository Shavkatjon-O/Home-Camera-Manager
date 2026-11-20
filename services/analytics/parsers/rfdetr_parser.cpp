// Custom bounding box parser of the RF-DETR detector for the DeepStream nvinfer plugin.
//
// RF-DETR outputs one box and one set of class logits for each of a fixed number of queries. The parser turns every
// query whose best class passes its pre-cluster threshold into a detection in network input pixels.

#include <algorithm>
#include <cmath>
#include <cstring>
#include <vector>

#include "nvdsinfer_custom_impl.h"

namespace {

// Looks up an output layer of the network by name.
//
// Args:
//   layers: Output layers of the network.
//   name: Name of the wanted layer.
//
// Returns:
//   The layer, or nullptr when no layer has that name.
const NvDsInferLayerInfo *find_layer(const std::vector<NvDsInferLayerInfo> &layers, const char *name) {
  for (const auto &layer : layers) {
    if (layer.layerName != nullptr && std::strcmp(layer.layerName, name) == 0) {
      return &layer;
    }
  }
  return nullptr;
}

// Maps a logit to a probability, clamping the input so that exp cannot overflow.
//
// Args:
//   value: Raw logit.
//
// Returns:
//   The logistic function of the value, between 0 and 1.
float sigmoid(float value) {
  return 1.0f / (1.0f + std::exp(-std::clamp(value, -88.0f, 88.0f)));
}

}

// Parses the RF-DETR output layers into detections.
//
// Reads the "dets" layer, with one center-based box (cx, cy, w, h normalised to 0..1) per query, and the "labels"
// layer, with one logit per class and query. For each query it takes the class with the highest sigmoid score that
// passes that class's pre-cluster threshold, converts the box to clamped corner pixels of the network input and drops
// boxes smaller than one pixel.
//
// Args:
//   outputLayersInfo: Output layers of the network, which must hold float "dets" and "labels".
//   networkInfo: Width and height of the network input.
//   detectionParams: Number of configured classes and the pre-cluster threshold of each class.
//   objectList: Receives the detections.
//
// Returns:
//   true when the layers were found and parsed, false when a layer is missing or not float.
extern "C" bool NvDsInferParseRfDetr(std::vector<NvDsInferLayerInfo> const &outputLayersInfo,
                                     NvDsInferNetworkInfo const &networkInfo,
                                     NvDsInferParseDetectionParams const &detectionParams,
                                     std::vector<NvDsInferObjectDetectionInfo> &objectList) {
  const NvDsInferLayerInfo *boxes = find_layer(outputLayersInfo, "dets");
  const NvDsInferLayerInfo *logits = find_layer(outputLayersInfo, "labels");
  if (boxes == nullptr || logits == nullptr || boxes->dataType != FLOAT || logits->dataType != FLOAT) {
    return false;
  }
  const int queries = static_cast<int>(boxes->inferDims.d[0]);
  const int classes = static_cast<int>(logits->inferDims.d[1]);
  const int configured = std::min<int>(classes, static_cast<int>(detectionParams.numClassesConfigured));
  const auto *box = static_cast<const float *>(boxes->buffer);
  const auto *logit = static_cast<const float *>(logits->buffer);
  const float width = static_cast<float>(networkInfo.width);
  const float height = static_cast<float>(networkInfo.height);

  for (int query = 0; query < queries; ++query) {
    int best_class = -1;
    float best_score = 0.0f;
    for (int cls = 0; cls < configured; ++cls) {
      const float threshold = detectionParams.perClassPreclusterThreshold[cls];
      if (threshold > 1.0f) {
        continue;
      }
      const float score = sigmoid(logit[query * classes + cls]);
      if (score >= threshold && score > best_score) {
        best_score = score;
        best_class = cls;
      }
    }
    if (best_class < 0) {
      continue;
    }
    const float *row = box + query * 4;
    const float left = std::clamp((row[0] - row[2] * 0.5f) * width, 0.0f, width - 1.0f);
    const float top = std::clamp((row[1] - row[3] * 0.5f) * height, 0.0f, height - 1.0f);
    const float right = std::clamp((row[0] + row[2] * 0.5f) * width, 0.0f, width - 1.0f);
    const float bottom = std::clamp((row[1] + row[3] * 0.5f) * height, 0.0f, height - 1.0f);
    if (right - left < 1.0f || bottom - top < 1.0f) {
      continue;
    }
    NvDsInferObjectDetectionInfo object{};
    object.classId = static_cast<unsigned int>(best_class);
    object.detectionConfidence = best_score;
    object.left = left;
    object.top = top;
    object.width = right - left;
    object.height = bottom - top;
    objectList.push_back(object);
  }
  return true;
}

// Verifies at compile time that the parser matches the signature nvinfer expects.
CHECK_CUSTOM_PARSE_FUNC_PROTOTYPE(NvDsInferParseRfDetr);
