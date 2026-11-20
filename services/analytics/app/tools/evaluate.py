"""Run one detector over a folder of still images through nvinfer and write its detections as JSON.

The images are named 00000.jpg, 00001.jpg and so on and already have the streammux size, so the detector sees them
exactly as it sees live frames. Usage::

    python -m app.tools.evaluate --detector rfdetr-medium --images /eval/images --output /eval/rfdetr-medium.json
"""

from __future__ import annotations

import argparse
import json
import time
from pathlib import Path

from app.detectors import detector, nvinfer_config


def parse_args() -> argparse.Namespace:
    """Parse the command line.

    Returns:
        The parsed arguments.
    """
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--detector", required=True)
    parser.add_argument("--images", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--models", default=Path("/models"), type=Path)
    parser.add_argument("--engines", default=Path("/engines"), type=Path)
    parser.add_argument("--batch", default=8, type=int)
    parser.add_argument("--threshold", default=0.2, type=float)
    parser.add_argument("--width", default=1920, type=int)
    parser.add_argument("--height", default=1080, type=int)
    return parser.parse_args()


def main() -> None:
    """Run the detector over every image and write the detections."""
    from pyservicemaker import BatchMetadataOperator, Pipeline, Probe

    args = parse_args()
    item = detector(args.detector)
    thresholds = {label: args.threshold for label in item.classes.values()}
    lowered = type(item)(**{**item.__dict__, "thresholds": thresholds})
    config = nvinfer_config(lowered, args.models, args.engines, args.batch, args.threshold)
    results: dict[int, list[dict]] = {}

    class Collector(BatchMetadataOperator):
        """Collect the detections of every frame."""

        def handle_metadata(self, batch_meta) -> None:
            """Store the objects of each frame in the batch.

            Args:
                batch_meta: Batch metadata from the inference element.
            """
            for frame in batch_meta.frame_items:
                objects = []
                for obj in frame.object_items:
                    rect = obj.rect_params
                    objects.append(
                        {
                            "label": item.classes.get(obj.class_id, str(obj.class_id)),
                            "confidence": round(float(obj.confidence), 4),
                            "box": [
                                round(rect.left / args.width, 5),
                                round(rect.top / args.height, 5),
                                round((rect.left + rect.width) / args.width, 5),
                                round((rect.top + rect.height) / args.height, 5),
                            ],
                        }
                    )
                results[int(frame.frame_number)] = objects

    pipeline = Pipeline("evaluate")
    pipeline.add(
        "multifilesrc",
        "source",
        {"location": str(args.images / "%05d.jpg"), "index": 0, "caps": "image/jpeg,framerate=(fraction)2/1"},
    )
    pipeline.add("jpegparse", "parse")
    pipeline.add("jpegdec", "decode")
    pipeline.add("videoconvert", "cpu_convert")
    pipeline.add("nvvideoconvert", "convert")
    pipeline.add("capsfilter", "caps", {"caps": "video/x-raw(memory:NVMM), format=NV12"})
    pipeline.add(
        "nvstreammux",
        "mux",
        {"batch-size": 1, "width": args.width, "height": args.height, "batched-push-timeout": 4000000},
    )
    pipeline.add("nvinfer", "infer", {"config-file-path": str(config), "batch-size": args.batch})
    pipeline.add("fakesink", "sink", {"sync": False})
    pipeline.link("source", "parse", "decode", "cpu_convert", "convert", "caps")
    pipeline.link(("caps", "mux"), ("", "sink_%u"))
    pipeline.link("mux", "infer", "sink")
    pipeline.attach("infer", Probe("collector", Collector()))
    started = time.monotonic()
    pipeline.start().wait()
    elapsed = time.monotonic() - started
    args.output.write_text(
        json.dumps(
            {"detector": item.name, "threshold": args.threshold, "seconds": round(elapsed, 1), "frames": results},
            indent=1,
        )
    )
    print(f"{item.name}: {len(results)} frames in {elapsed:.1f} s")


if __name__ == "__main__":
    main()
