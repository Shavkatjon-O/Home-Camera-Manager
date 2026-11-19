"""The DeepStream pipeline, run in its own process.

Each camera stream is decoded once on NVDEC. A single-lens camera feeds the stream muxer directly; a multi-lens
camera goes through a tee and one cropping nvvideoconvert per lens, so every lens is its own source in the batch and
the tracker never mixes objects across lenses. Each view's branch drops frames down to its analysis rate and ends
in a leaky queue, so a stalled camera never holds up the others, and nvurisrcbin reconnects lost streams on its own.
The batch runs through the shared detector and the NvDCF tracker, and a probe after the tracker sends every frame's
tracked objects to the service process.

The service runs this module in a child process, so a crash in native code takes down only the pipeline, which the
service then restarts.
"""

from __future__ import annotations

import logging
import multiprocessing
import queue
import time

from app.pipeline.plan import PipelinePlan, ViewPlan, lens_crop

logger = logging.getLogger(__name__)

TRACKER_LIBRARY = "/opt/nvidia/deepstream/deepstream/lib/libnvds_nvmultiobjecttracker.so"
UNTRACKED = 0xFFFFFFFFFFFFFFFF
RTP_OVER_TCP = 4
QUEUE_BUFFERS = 2
LEAK_OLDEST = 2


def build_pipeline(plan: PipelinePlan, infer_config: str, outbox: multiprocessing.Queue):
    """Build the pipeline for a plan.

    Args:
        plan: What to build.
        infer_config: nvinfer configuration file of the detector.
        outbox: Queue that receives the tracked objects of every batch.

    Returns:
        The pyservicemaker pipeline, ready to start.
    """
    from pyservicemaker import BatchMetadataOperator, Pipeline, Probe

    views = plan.views
    pipeline = Pipeline("analytics")
    pipeline.add(
        "nvstreammux",
        "mux",
        {
            "batch-size": len(views),
            "width": plan.width,
            "height": plan.height,
            "live-source": True,
            "attach-sys-ts": True,
            "batched-push-timeout": int(1_000_000 / plan.max_fps),
        },
    )

    def branch(view: ViewPlan, upstream: str, upstream_pad: str, width: int, height: int) -> None:
        names = [f"queue{view.index}"]
        pipeline.add("queue", names[0], {"leaky": LEAK_OLDEST, "max-size-buffers": QUEUE_BUFFERS})
        pipeline.link((upstream, names[0]), (upstream_pad, ""))
        if view.lens:
            band = height // view.lenses
            pipeline.add(
                "nvvideoconvert", f"crop{view.index}", {"src-crop": lens_crop(width, height, view.lens, view.lenses)}
            )
            pipeline.add(
                "capsfilter",
                f"cropcaps{view.index}",
                {"caps": f"video/x-raw(memory:NVMM), width={width}, height={band}"},
            )
            names += [f"crop{view.index}", f"cropcaps{view.index}"]
        pipeline.add("videorate", f"rate{view.index}", {"drop-only": True, "max-rate": max(1, round(view.fps))})
        names.append(f"rate{view.index}")
        pipeline.link(*names)
        pipeline.link((names[-1], "mux"), ("", f"sink_{view.index}"))

    for number, source in enumerate(plan.sources):
        name = f"source{number}"
        pipeline.add(
            "nvurisrcbin",
            name,
            {
                "uri": source.uri,
                "rtsp-reconnect-interval": plan.reconnect_seconds,
                "init-rtsp-reconnect-interval": plan.reconnect_seconds,
                "rtsp-reconnect-attempts": -1,
                "select-rtp-protocol": RTP_OVER_TCP,
                "latency": 200,
                "disable-audio": True,
                "num-extra-surfaces": 4,
            },
        )
        if len(source.views) == 1 and source.views[0].lens == 0:
            branch(source.views[0], name, "", source.width, source.height)
            continue
        tee = f"tee{number}"
        pipeline.add("tee", tee)
        pipeline.link((name, tee), ("", ""))
        for view in source.views:
            branch(view, tee, "src_%u", source.width, source.height)

    pipeline.add("nvinfer", "detector", {"config-file-path": infer_config, "batch-size": plan.engine_batch})
    pipeline.add(
        "nvtracker",
        "tracker",
        {
            "ll-lib-file": TRACKER_LIBRARY,
            "ll-config-file": plan.tracker_config,
            "tracker-width": plan.tracker_width,
            "tracker-height": plan.tracker_height,
        },
    )
    pipeline.add("fakesink", "sink", {"sync": False, "async": False})
    pipeline.link("mux", "detector", "tracker", "sink")

    labels = dict(plan.labels)
    scale_x, scale_y = 1.0 / plan.width, 1.0 / plan.height
    dropped = [0]

    class Collector(BatchMetadataOperator):
        """Send the tracked objects of every frame to the service process."""

        def handle_metadata(self, batch_meta) -> None:
            """Convert one batch to plain tuples and queue it.

            Args:
                batch_meta: Batch metadata after the tracker.
            """
            received = time.time()
            frames = []
            for frame in batch_meta.frame_items:
                objects = []
                for item in frame.object_items:
                    label = labels.get(item.class_id)
                    if label is None or item.object_id == UNTRACKED:
                        continue
                    rect = item.rect_params
                    left, top = rect.left * scale_x, rect.top * scale_y
                    objects.append(
                        (
                            int(item.object_id),
                            label,
                            round(max(float(item.confidence), float(item.tracker_confidence)), 3),
                            round(left, 4),
                            round(top, 4),
                            round(left + rect.width * scale_x, 4),
                            round(top + rect.height * scale_y, 4),
                        )
                    )
                frames.append((int(frame.pad_index), int(frame.frame_number), int(frame.ntp_timestamp), objects))
            try:
                outbox.put_nowait(("frames", received, frames, dropped[0]))
            except queue.Full:
                dropped[0] += 1

    pipeline.attach("tracker", Probe("collector", Collector()))
    return pipeline


def run(plan: PipelinePlan, outbox: multiprocessing.Queue) -> None:
    """Build and run the pipeline until it stops; the entry point of the pipeline process.

    Args:
        plan: What to build.
        outbox: Queue for tracked objects and lifecycle messages.
    """
    from pathlib import Path

    from app.detectors import detector, nvinfer_config

    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s pipeline %(message)s")
    try:
        item = detector(plan.detector)
        outbox.put(("preparing", time.time(), f"Preparing the {item.name} engine"))
        config = nvinfer_config(
            item,
            Path(plan.models_dir),
            Path(plan.engines_dir),
            plan.engine_batch,
            plan.threshold,
            workspace_mb=plan.workspace_mb,
        )
        pipeline = build_pipeline(plan, str(config), outbox)
    except Exception as exc:
        outbox.put(("failed", time.time(), f"Building the pipeline failed: {exc}"))
        raise

    def on_message(message) -> None:
        kind = type(message).__name__
        if kind == "StateTransitionMessage" and getattr(message, "origin", "") == "analytics":
            outbox.put(("state", time.time(), str(message.new_state)))
        elif kind == "EOSMessage":
            outbox.put(("eos", time.time(), "The pipeline reached the end of its streams"))

    outbox.put(("starting", time.time(), len(plan.views)))
    pipeline.start(on_message)
    pipeline.wait()
    outbox.put(("stopped", time.time(), "The pipeline stopped"))
