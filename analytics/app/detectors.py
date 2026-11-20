"""Primary detectors the pipeline can run and the nvinfer configuration each one needs.

A detector names its weights by file inside the model folder, so the same definition works on any host that mounts
the model layer. TensorRT engines are built on first start into the engine cache folder by app.engines.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path

COCO_NAMES = {
    1: "person",
    2: "bicycle",
    3: "car",
    4: "motorcycle",
    6: "bus",
    8: "truck",
    16: "bird",
    17: "cat",
    18: "dog",
    27: "backpack",
    31: "handbag",
    33: "suitcase",
}

LABELS = (
    "person",
    "bicycle",
    "car",
    "motorcycle",
    "bus",
    "truck",
    "bird",
    "cat",
    "dog",
    "backpack",
    "handbag",
    "suitcase",
)

PARSER_LIBRARY = "/opt/analytics/lib/libnvds_rfdetr_parser.so"
DISABLED_THRESHOLD = 1.1


@dataclass(frozen=True)
class Detector:
    """A primary detector and how nvinfer runs it.

    Attributes:
        name: Stable identifier used in configuration, engine file names and the status endpoint.
        family: Folder of the model family inside the model root, such as rf-detr.
        onnx: ONNX file name inside the family folder.
        width: Network input width in pixels.
        height: Network input height in pixels.
        num_classes: Number of classes the network outputs.
        classes: Network class id to canonical label for every class the pipeline keeps.
        thresholds: Detection threshold per canonical label.
        parser: Custom bbox parser function, or None for the built-in DetectNet parser.
        cluster_mode: nvinfer cluster mode, 2 for NMS.
        nms_iou: IoU threshold of the NMS step.
        precision: Engine precision, fp16 or fp32.
        licence: Licence of the weights, printed by the status endpoint.
    """

    name: str
    family: str
    onnx: str
    width: int
    height: int
    num_classes: int
    classes: dict[int, str]
    thresholds: dict[str, float] = field(default_factory=dict)
    parser: str | None = None
    cluster_mode: int = 2
    nms_iou: float = 0.5
    precision: str = "fp16"
    licence: str = ""

    def model_path(self, model_root: Path) -> Path:
        """Return the ONNX file of this detector inside the model root.

        Args:
            model_root: Folder holding one sub folder per model family.

        Returns:
            The absolute ONNX path.
        """
        return model_root / self.family / "v1" / self.onnx

    def threshold(self, label: str, default: float) -> float:
        """Return the detection threshold for a canonical label.

        Args:
            label: Canonical label such as person.
            default: Threshold used when the detector sets none for the label.

        Returns:
            The threshold in the range 0 to 1.
        """
        return self.thresholds.get(label, default)


RF_DETR_CLASSES = {class_id: name for class_id, name in COCO_NAMES.items()}

DETECTORS: dict[str, Detector] = {
    "rfdetr-nano": Detector(
        name="rfdetr-nano",
        family="rf-detr",
        onnx="rf-detr-nano-384x672.onnx",
        width=672,
        height=384,
        num_classes=91,
        classes=RF_DETR_CLASSES,
        thresholds={"person": 0.4},
        parser="NvDsInferParseRfDetr",
        nms_iou=0.5,
        licence="Apache-2.0",
    ),
    "rfdetr-small": Detector(
        name="rfdetr-small",
        family="rf-detr",
        onnx="rf-detr-small-512x896.onnx",
        width=896,
        height=512,
        num_classes=91,
        classes=RF_DETR_CLASSES,
        thresholds={"person": 0.4},
        parser="NvDsInferParseRfDetr",
        nms_iou=0.5,
        licence="Apache-2.0",
    ),
    "rfdetr-medium": Detector(
        name="rfdetr-medium",
        family="rf-detr",
        onnx="rf-detr-medium-576x1024.onnx",
        width=1024,
        height=576,
        num_classes=91,
        classes=RF_DETR_CLASSES,
        thresholds={"person": 0.45},
        parser="NvDsInferParseRfDetr",
        nms_iou=0.5,
        licence="Apache-2.0",
    ),
    "rfdetr-large": Detector(
        name="rfdetr-large",
        family="rf-detr",
        onnx="rf-detr-large-2026-704x1248.onnx",
        width=1248,
        height=704,
        num_classes=91,
        classes=RF_DETR_CLASSES,
        thresholds={"person": 0.4},
        parser="NvDsInferParseRfDetr",
        nms_iou=0.5,
        licence="Apache-2.0",
    ),
    "peoplenet": Detector(
        name="peoplenet",
        family="peoplenet",
        onnx="resnet34_peoplenet.onnx",
        width=960,
        height=544,
        num_classes=3,
        classes={0: "person"},
        thresholds={"person": 0.4},
        licence="NVIDIA Open Model License",
    ),
    "trafficcamnet": Detector(
        name="trafficcamnet",
        family="trafficcamnet",
        onnx="resnet18_trafficcamnet_pruned.onnx",
        width=960,
        height=544,
        num_classes=4,
        classes={0: "car", 1: "bicycle", 2: "person"},
        thresholds={"person": 0.4, "car": 0.4, "bicycle": 0.4},
        licence="NVIDIA Open Model License",
    ),
}


def detector(name: str) -> Detector:
    """Look up a detector by name.

    Args:
        name: Detector name such as rfdetr-medium.

    Returns:
        The detector definition.

    Raises:
        KeyError: If no detector has that name.
    """
    try:
        return DETECTORS[name]
    except KeyError:
        raise KeyError(f"Unknown detector {name!r}, known: {', '.join(sorted(DETECTORS))}") from None


def labels_file_lines(item: Detector) -> list[str]:
    """Return one label per network class for the nvinfer label file.

    Args:
        item: The detector.

    Returns:
        Labels in class id order, with classes the pipeline drops named by their id.
    """
    return [item.classes.get(class_id, f"class{class_id}") for class_id in range(item.num_classes)]


def nvinfer_config(
    item: Detector,
    model_root: Path,
    engine_dir: Path,
    batch_size: int,
    default_threshold: float,
    unique_id: int = 1,
    workspace_mb: int = 1024,
) -> Path:
    """Write the nvinfer configuration for a detector and return its path.

    The engine is built into the cache folder first when the cache has none for this host, so nvinfer only ever
    deserializes it.

    Args:
        item: The detector.
        model_root: Folder holding one sub folder per model family.
        engine_dir: Writable cache folder for engines and generated files.
        batch_size: Maximum batch the engine is built for.
        default_threshold: Threshold for kept labels the detector sets none for.
        unique_id: nvinfer unique component id.
        workspace_mb: TensorRT builder workspace limit in MiB, which bounds GPU memory while an engine builds.

    Returns:
        Path of the written configuration file.

    Raises:
        FileNotFoundError: If the ONNX file is missing from the model folder.
    """
    from app.engines import ensure_engine

    source = item.model_path(model_root)
    if not source.is_file():
        raise FileNotFoundError(f"Model file {source} is missing, run the model download script")
    folder = engine_dir / item.name
    folder.mkdir(parents=True, exist_ok=True)
    engine = ensure_engine(source, engine_dir, item.name, batch_size, item.precision, workspace_mb)
    labels = folder / "labels.txt"
    labels.write_text("\n".join(labels_file_lines(item)) + "\n")
    lines = [
        "[property]",
        "gpu-id=0",
        f"onnx-file={source}",
        f"model-engine-file={engine}",
        f"labelfile-path={labels}",
        f"batch-size={batch_size}",
        "network-mode=2",
        "network-type=0",
        "process-mode=1",
        "model-color-format=0",
        "net-scale-factor=0.00392156862745098",
        "offsets=0;0;0",
        "maintain-aspect-ratio=0",
        "scaling-compute-hw=1",
        "scaling-filter=1",
        f"num-detected-classes={item.num_classes}",
        f"cluster-mode={item.cluster_mode}",
        f"gie-unique-id={unique_id}",
        f"workspace-size={workspace_mb}",
    ]
    if item.parser:
        lines.append(f"parse-bbox-func-name={item.parser}")
        lines.append(f"custom-lib-path={PARSER_LIBRARY}")
    lines += [
        "",
        "[class-attrs-all]",
        f"pre-cluster-threshold={DISABLED_THRESHOLD}",
        f"nms-iou-threshold={item.nms_iou}",
        "topk=100",
    ]
    for class_id, label in sorted(item.classes.items()):
        lines += [
            "",
            f"[class-attrs-{class_id}]",
            f"pre-cluster-threshold={item.threshold(label, default_threshold)}",
            f"nms-iou-threshold={item.nms_iou}",
            "topk=100",
        ]
    path = folder / "nvinfer.txt"
    path.write_text("\n".join(lines) + "\n")
    return path
