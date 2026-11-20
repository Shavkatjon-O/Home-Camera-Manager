"""Plain data describing the pipeline to build, passed from the service to the pipeline process."""

from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class ViewPlan:
    """One view fed into the batch.

    Attributes:
        index: Pad index on the stream muxer, which is the frame's source id.
        view: View id.
        lens: 0 for the whole frame, otherwise the lens band counted from 1 at the top.
        lenses: Number of lens bands in the camera frame.
        fps: Analysis rate.
    """

    index: int
    view: str
    lens: int
    lenses: int
    fps: float


@dataclass(frozen=True)
class SourcePlan:
    """One camera stream decoded once and split into its views.

    Attributes:
        camera: Camera id.
        uri: RTSP URI including credentials; it is never logged.
        width: Frame width, needed to crop lens bands, 0 when unknown.
        height: Frame height, 0 when unknown.
        views: Views cut from this stream.
    """

    camera: str
    uri: str
    width: int
    height: int
    views: tuple[ViewPlan, ...]


@dataclass(frozen=True)
class PipelinePlan:
    """The whole pipeline.

    Attributes:
        sources: Camera streams.
        detector: Name of the shared detector.
        models_dir: Model layer mount.
        engines_dir: Writable engine cache.
        workspace_mb: TensorRT builder workspace limit.
        threshold: Detection threshold for labels the detector sets none for.
        tracker_config: nvtracker low level configuration file.
        labels: Network class id to canonical label.
        width: Stream muxer frame width.
        height: Stream muxer frame height.
        tracker_width: Frame width the tracker works at.
        tracker_height: Frame height the tracker works at.
        engine_batch: Largest batch the engine accepts.
        reconnect_seconds: Seconds without data before a source reconnects.
        faces: Muxer pads of the views the face stage runs on.
    """

    sources: tuple[SourcePlan, ...]
    detector: str
    models_dir: str
    engines_dir: str
    workspace_mb: int
    threshold: float
    tracker_config: str
    labels: dict[int, str]
    width: int = 1920
    height: int = 1080
    tracker_width: int = 960
    tracker_height: int = 544
    engine_batch: int = 8
    reconnect_seconds: int = 10
    faces: tuple[int, ...] = ()

    @property
    def views(self) -> list[ViewPlan]:
        """list[ViewPlan]: Every view in pad order."""
        return sorted((view for source in self.sources for view in source.views), key=lambda item: item.index)

    @property
    def max_fps(self) -> float:
        """float: The highest analysis rate of any view."""
        return max((view.fps for view in self.views), default=1.0)


def lens_crop(width: int, height: int, lens: int, lenses: int) -> str:
    """Return the nvvideoconvert crop of a lens band.

    Args:
        width: Frame width.
        height: Frame height.
        lens: Lens band counted from 1 at the top.
        lenses: Number of bands stacked in the frame.

    Returns:
        The crop as left:top:width:height.
    """
    band = height // lenses
    return f"0:{band * (lens - 1)}:{width}:{band}"


def fraction(fps: float) -> str:
    """Express a frame rate as a GStreamer fraction.

    Args:
        fps: Frames per second, such as 7.5.

    Returns:
        The fraction, such as 15/2.
    """
    tenths = round(fps * 10)
    for denominator in (1, 2, 5, 10):
        if tenths * denominator % 10 == 0:
            return f"{tenths * denominator // 10}/{denominator}"
    return f"{tenths}/10"
