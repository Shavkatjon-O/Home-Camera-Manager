from uuid import UUID

from app.models import Camera
from app.streaming.tv import (
    INPUT_AGENT,
    TV_WALL,
    stream_command,
    stream_sources,
    tile_index,
    tile_name,
    tv_url,
)
from app.streaming.wall import wall_plan

GATE = Camera(uuid=UUID(int=1), name="Gate", lenses=1, sub_path="/sub", ptz_enabled=False)
YARD = Camera(uuid=UUID(int=2), name="Yard", lenses=2, sub_path=None, ptz_enabled=True)

GATE_SUB = f"{GATE.uuid.hex}_sub"
GATE_MAIN = f"{GATE.uuid.hex}_main"
YARD_MAIN = f"{YARD.uuid.hex}_main"


def option(args: list[str], name: str) -> str:
    return args[args.index(name) + 1]


def inputs(args: list[str]) -> list[str]:
    return [args[position + 1] for position, value in enumerate(args) if value == "-i"]


def test_tile_names_and_limits():
    assert tile_name(3) == "tv_tile_3"
    assert tile_index("tv_tile_3") == 3
    assert tile_index("tv_tile_15") == 15
    assert tile_index("tv_tile_16") is None
    assert tile_index("tv_tile_") is None
    assert tile_index("tv_wall") is None


def test_tv_url_quotes_credentials():
    assert tv_url("tv_wall", "192.168.1.219", "tv", "p@ss:w/d") == "rtsp://tv:p%40ss%3Aw%2Fd@192.168.1.219:8554/tv_wall"
    assert tv_url("tv_tile_0", "h", "tv", "") == "rtsp://tv@h:8554/tv_tile_0"


def test_sources_use_sub_streams_on_the_wall_and_main_streams_on_tiles():
    plan = wall_plan([GATE, YARD])
    assert stream_sources(plan, TV_WALL) == {GATE.uuid: GATE_SUB, YARD.uuid: YARD_MAIN}
    assert stream_sources(plan, "tv_tile_0") == {GATE.uuid: GATE_MAIN}
    assert stream_sources(plan, "tv_tile_3") == {YARD.uuid: YARD_MAIN}
    assert stream_sources(plan, "tv_tile_1") is None
    assert stream_sources(plan, "other") is None
    assert stream_sources(wall_plan([]), TV_WALL) is None


def test_wall_overlays_every_lens_on_a_canvas():
    command = stream_command(wall_plan([GATE, YARD]), TV_WALL)
    args = command.args
    assert command.inputs == {GATE.uuid: GATE_SUB, YARD.uuid: YARD_MAIN}
    sources = inputs(args)
    assert sources[0].startswith("color=c=0x0b0b0b:s=1920x1080:r=15,drawtext=")
    assert sources[0].count("text=Offline") == 3
    assert sources[1:] == [f"rtsp://127.0.0.1:8554/{GATE_SUB}?video", f"rtsp://127.0.0.1:8554/{YARD_MAIN}?video"]
    assert args[args.index("-i") - 1] == "lavfi"
    assert option(args, "-user_agent") == INPUT_AGENT
    graph = option(args, "-filter_complex")
    assert "[2:v]setpts=(RTCTIME-RTCSTART)/(TB*1000000),split=2[s2_0][s2_1]" in graph
    assert "[s2_0]crop=iw:ih/2:0:ih*0/2,scale=960:540:" in graph
    assert "[s2_1]crop=iw:ih/2:0:ih*1/2,scale=960:540:" in graph
    assert "[0:v][t0]overlay=x=0:y=0:eof_action=pass:repeatlast=0[c0]" in graph
    assert "[c0][t2]overlay=x=960:y=0:eof_action=pass:repeatlast=0[c1]" in graph
    assert graph.endswith("[c1][t3]overlay=x=960:y=540:eof_action=pass:repeatlast=0[out]")
    assert option(args, "-c:v") == "h264_nvenc"
    assert option(args, "-b:v") == "6M"
    assert option(args, "-preset") == "p1"
    assert option(args, "-tune") == "ull"
    assert args[-2:] == ["-f", "rtsp"]


def test_offline_cameras_leave_their_cells_on_the_canvas():
    command = stream_command(wall_plan([GATE, YARD]), TV_WALL, {YARD.uuid})
    assert command.inputs == {GATE.uuid: GATE_SUB}
    assert len(inputs(command.args)) == 2
    graph = option(command.args, "-filter_complex")
    assert "[1:v]" in graph and "[2:v]" not in graph
    assert graph.endswith("[0:v][t0]overlay=x=0:y=0:eof_action=pass:repeatlast=0[out]")


def test_wall_without_live_cameras_is_the_canvas():
    command = stream_command(wall_plan([GATE]), TV_WALL, {GATE.uuid})
    assert command.inputs == {}
    assert option(command.args, "-filter_complex") == "[0:v]null[out]"


def test_tile_reads_the_main_stream_and_crops_its_lens():
    plan = wall_plan([GATE, YARD])
    command = stream_command(plan, "tv_tile_3")
    assert inputs(command.args)[1:] == [f"rtsp://127.0.0.1:8554/{YARD_MAIN}?video"]
    graph = option(command.args, "-filter_complex")
    assert graph.startswith("[1:v]setpts=(RTCTIME-RTCSTART)/(TB*1000000),crop=iw:ih/2:0:ih*1/2,scale=1920:1080:")
    assert graph.endswith("[0:v][t3]overlay=x=0:y=0:eof_action=pass:repeatlast=0[out]")
    assert option(command.args, "-b:v") == "4M"
    assert inputs(command.args)[0].count("text=Offline") == 1


def test_arguments_survive_newline_splitting():
    plan = wall_plan([GATE, YARD])
    for name in (TV_WALL, "tv_tile_0", "tv_tile_2", "tv_tile_3"):
        args = stream_command(plan, name).args
        assert all(arg and "\n" not in arg and " " not in arg for arg in args)
