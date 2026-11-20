"""Builds the ffmpeg commands that compose the camera wall and single tiles for the TV."""

import re
from dataclasses import dataclass
from urllib.parse import quote
from uuid import UUID

from app.models import Camera
from app.streaming.names import MAIN, SUB, stream_name
from app.streaming.wall import WallCell, WallPlan

TV_WALL = "tv_wall"
TV_TILE_PREFIX = "tv_tile_"
TV_TILE_LIMIT = 16
TILE_PATTERN = re.compile(r"^tv_tile_(\d{1,2})$")

TV_RTSP_PORT = 8554
LOCAL_RTSP = "rtsp://127.0.0.1:8554"
INPUT_AGENT = "SmartSurveillanceComposer"

WALL_WIDTH = 1920
WALL_HEIGHT = 1080
WALL_FPS = 15

CANVAS_COLOR = "0x0b0b0b"
CANVAS_FONT = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
CANVAS_TEXT_COLOR = "0x6b6b6b"
CANVAS_TEXT = "Offline"
CANVAS_TEXT_RATIO = 14
CANVAS_TEXT_MIN = 16

WALL_BITRATE = "6M"
TILE_BITRATE = "4M"
FILTER_THREADS = "2"

GLOBAL_OPTIONS = ["-hide_banner", "-loglevel", "error", "-nostdin"]
INPUT_OPTIONS = [
    "-fflags",
    "nobuffer",
    "-flags",
    "low_delay",
    "-rtsp_transport",
    "tcp",
    "-timeout",
    "2000000",
    "-analyzeduration",
    "1000000",
    "-probesize",
    "1000000",
    "-user_agent",
    INPUT_AGENT,
]
WALLCLOCK = "setpts=(RTCTIME-RTCSTART)/(TB*1000000)"


@dataclass(frozen=True)
class TvCommand:
    """ffmpeg command of one TV stream.

    Attributes:
        args: ffmpeg arguments.
        inputs: Camera stream name read for each camera shown in the command.
    """

    args: list[str]
    inputs: dict[UUID, str]


@dataclass(frozen=True)
class Frame:
    """Rectangle of the wall canvas that shows one picture.

    Attributes:
        cell: Wall cell the rectangle belongs to.
        x: Left edge in pixels.
        y: Top edge in pixels.
        width: Width in pixels.
        height: Height in pixels.
    """

    cell: WallCell
    x: int
    y: int
    width: int
    height: int


def tile_name(index: int) -> str:
    """Build the TV stream name of a tile.

    Args:
        index: Cell index.

    Returns:
        The tile stream name.
    """
    return f"{TV_TILE_PREFIX}{index}"


def tile_index(name: str) -> int | None:
    """Read the cell index from a TV tile stream name.

    Args:
        name: TV stream name.

    Returns:
        The index, or None when the name is not a tile name or the index is at or above the tile limit.
    """
    match = TILE_PATTERN.match(name)
    if match is None:
        return None
    index = int(match.group(1))
    return index if index < TV_TILE_LIMIT else None


def tv_url(name: str, host: str, username: str, password: str) -> str:
    """Build the RTSP URL a TV uses to read a TV stream.

    Args:
        name: TV stream name.
        host: Host of the go2rtc RTSP port.
        username: Login name.
        password: Password, omitted from the URL when empty.

    Returns:
        The RTSP URL with percent-encoded credentials.
    """
    credentials = quote(username, safe="")
    if password:
        credentials = f"{credentials}:{quote(password, safe='')}"
    return f"rtsp://{credentials}@{host}:{TV_RTSP_PORT}/{name}"


def even(value: int) -> int:
    """Round a size down to an even number of at least 2.

    Args:
        value: Size in pixels.

    Returns:
        The even size.
    """
    return max(2, value - value % 2)


def wall_source(camera: Camera) -> str:
    """Choose the stream kind a camera contributes to the wall.

    Args:
        camera: Camera shown on the wall.

    Returns:
        The sub stream when the camera has one, otherwise the main stream.
    """
    return SUB if camera.sub_path else MAIN


def lens_crop(lens: int | None, lenses: int) -> str | None:
    """Build the crop filter that cuts one lens out of a stacked multi-lens picture.

    Args:
        lens: Lens index, or None for a whole picture.
        lenses: Number of lenses of the camera.

    Returns:
        The crop filter, or None when no crop is needed.
    """
    if lens is None or lenses <= 1:
        return None
    return f"crop=iw:ih/{lenses}:0:ih*{lens}/{lenses}"


def fit(width: int, height: int) -> str:
    """Build the filters that scale a picture into a rectangle, padding to keep its aspect ratio.

    Args:
        width: Rectangle width in pixels.
        height: Rectangle height in pixels.

    Returns:
        The filter chain.
    """
    return (
        f"scale={width}:{height}:force_original_aspect_ratio=decrease:force_divisible_by=2:flags=bilinear:out_range=limited,"
        f"pad={width}:{height}:(ow-iw)/2:(oh-ih)/2,setsar=1,format=yuv420p"
    )


def frame_chain(frame: Frame) -> str:
    """Build the filter chain that crops the lens and fits the picture into its rectangle.

    Args:
        frame: Rectangle to fill.

    Returns:
        The filter chain.
    """
    crop = lens_crop(frame.cell.item.lens, frame.cell.item.camera.lenses)
    return ",".join(part for part in (crop, fit(frame.width, frame.height)) if part)


def canvas(frames: list[Frame]) -> str:
    """Build the lavfi source of the base canvas, with an offline label centred in every rectangle.

    Args:
        frames: Rectangles on the canvas.

    Returns:
        The lavfi filter graph of the canvas.
    """
    parts = [f"color=c={CANVAS_COLOR}:s={WALL_WIDTH}x{WALL_HEIGHT}:r={WALL_FPS}"]
    for frame in frames:
        size = max(CANVAS_TEXT_MIN, frame.height // CANVAS_TEXT_RATIO)
        center_x = frame.x + frame.width // 2
        center_y = frame.y + frame.height // 2
        parts.append(
            f"drawtext=fontfile={CANVAS_FONT}:fontsize={size}:fontcolor={CANVAS_TEXT_COLOR}:text={CANVAS_TEXT}"
            f":x={center_x}-tw/2:y={center_y}-th/2"
        )
    parts.append("format=yuv420p")
    return ",".join(parts)


def encoder_options(bitrate: str) -> list[str]:
    """Build the video encoder and RTSP output options.

    Args:
        bitrate: Constant video bitrate.

    Returns:
        The ffmpeg options.
    """
    return [
        "-an",
        "-c:v",
        "h264_nvenc",
        "-preset",
        "p1",
        "-tune",
        "ull",
        "-delay",
        "0",
        "-zerolatency",
        "1",
        "-g",
        "30",
        "-bf",
        "0",
        "-rc",
        "cbr",
        "-b:v",
        bitrate,
        "-profile:v",
        "high",
        "-rtsp_transport",
        "tcp",
        "-f",
        "rtsp",
    ]


def compose(frames: list[Frame], sources: dict[UUID, str], offline: set[UUID], bitrate: str) -> TvCommand:
    """Build the ffmpeg command that overlays camera pictures on the canvas.

    Each camera is opened once even when it fills several rectangles. Cameras that are offline are not opened and
    their rectangles keep the canvas label.

    Args:
        frames: Rectangles to fill.
        sources: Camera stream name of each camera.
        offline: Cameras to leave out.
        bitrate: Constant video bitrate of the output.

    Returns:
        The command and the camera streams it reads.
    """
    args = [*GLOBAL_OPTIONS, "-re", "-f", "lavfi", "-i", canvas(frames)]
    numbers: dict[UUID, int] = {}
    inputs: dict[UUID, str] = {}
    for frame in frames:
        camera_uuid = frame.cell.item.camera.uuid
        if camera_uuid in offline or camera_uuid in numbers:
            continue
        numbers[camera_uuid] = len(numbers) + 1
        inputs[camera_uuid] = sources[camera_uuid]
        args.extend([*INPUT_OPTIONS, "-i", f"{LOCAL_RTSP}/{sources[camera_uuid]}?video"])
    chains = []
    live = [frame for frame in frames if frame.cell.item.camera.uuid in numbers]
    for camera_uuid, number in numbers.items():
        own = [frame for frame in live if frame.cell.item.camera.uuid == camera_uuid]
        if len(own) == 1:
            chains.append(f"[{number}:v]{WALLCLOCK},{frame_chain(own[0])}[t{own[0].cell.index}]")
            continue
        branches = "".join(f"[s{number}_{part}]" for part in range(len(own)))
        chains.append(f"[{number}:v]{WALLCLOCK},split={len(own)}{branches}")
        for part, frame in enumerate(own):
            chains.append(f"[s{number}_{part}]{frame_chain(frame)}[t{frame.cell.index}]")
    base = "0:v"
    for step, frame in enumerate(live):
        target = "out" if step == len(live) - 1 else f"c{step}"
        chains.append(
            f"[{base}][t{frame.cell.index}]overlay=x={frame.x}:y={frame.y}:eof_action=pass:repeatlast=0[{target}]"
        )
        base = target
    if not live:
        chains.append("[0:v]null[out]")
    args.extend(
        [
            "-filter_complex_threads",
            FILTER_THREADS,
            "-filter_complex",
            ";".join(chains),
            "-map",
            "[out]",
            *encoder_options(bitrate),
        ]
    )
    return TvCommand(args=args, inputs=inputs)


def wall_frames(plan: WallPlan) -> list[Frame]:
    """Place the cells of a plan on the wall canvas.

    Args:
        plan: Wall plan.

    Returns:
        One rectangle per cell, in equal even sized grid cells.
    """
    width = even(WALL_WIDTH // plan.cols)
    height = even(WALL_HEIGHT // plan.rows)
    return [Frame(cell, cell.col * width, cell.row * height, width, height) for cell in plan.cells]


def stream_sources(plan: WallPlan, name: str) -> dict[UUID, str] | None:
    """Find the camera streams a TV stream shows.

    Args:
        plan: Wall plan.
        name: TV stream name.

    Returns:
        The camera stream name of each camera, or None when the name is unknown or shows no camera. The wall uses the
        sub stream where there is one and a tile uses the main stream.
    """
    if name == TV_WALL:
        if not plan.cells:
            return None
        return {
            cell.item.camera.uuid: stream_name(cell.item.camera.uuid, wall_source(cell.item.camera))
            for cell in plan.cells
        }
    index = tile_index(name)
    cell = plan.cell(index) if index is not None else None
    if cell is None:
        return None
    return {cell.item.camera.uuid: stream_name(cell.item.camera.uuid, MAIN)}


def stream_command(plan: WallPlan, name: str, offline: set[UUID] | None = None) -> TvCommand | None:
    """Build the ffmpeg command of a TV stream.

    Args:
        plan: Wall plan.
        name: TV stream name.
        offline: Cameras to leave out, if any.

    Returns:
        The command, or None when the name is unknown or shows no camera.
    """
    sources = stream_sources(plan, name)
    if sources is None:
        return None
    if name == TV_WALL:
        return compose(wall_frames(plan), sources, offline or set(), WALL_BITRATE)
    cell = plan.cell(tile_index(name))
    frame = Frame(cell, 0, 0, WALL_WIDTH, WALL_HEIGHT)
    return compose([frame], sources, offline or set(), TILE_BITRATE)
