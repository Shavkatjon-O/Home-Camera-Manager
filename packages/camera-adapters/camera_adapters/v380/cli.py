"""Command line of the V380 client: stream for go2rtc, probe, discover and control."""

import argparse
import asyncio
import contextlib
import json
import logging
import os
import signal
import sys
from dataclasses import asdict
from pathlib import Path

from camera_adapters.v380.client import Camera, Session, first_key_frame
from camera_adapters.v380.control import DEFAULT_DIRECTORY, ControlServer, send, socket_path
from camera_adapters.v380.discovery import discover
from camera_adapters.v380.errors import V380Error
from camera_adapters.v380.pipe import AnnexBPipe
from camera_adapters.v380.records import DEFAULT_PORT, Stream
from camera_adapters.v380.streamer import Streamer

__all__ = ["main", "parser", "password"]

logger = logging.getLogger("camera_adapters.v380")

PASSWORD_ENV = "SSS_V380_PASSWORD"
PROBE_SECONDS = 10.0


def password(args: argparse.Namespace) -> str:
    """Resolve the camera password from the command line, a file or the environment.

    Args:
        args: Parsed arguments.

    Returns:
        The password.

    Raises:
        SystemExit: No password is given.
    """
    if args.password is not None:
        return args.password
    if args.password_file:
        return Path(args.password_file).read_text().rstrip("\r\n")
    value = os.environ.get(args.password_env or PASSWORD_ENV)
    if value is None:
        raise SystemExit(f"Give the camera password with --password, --password-file or {args.password_env}")
    return value


def camera_arguments(command: argparse.ArgumentParser) -> None:
    """Add the arguments that reach and log in to a camera.

    Args:
        command: The subcommand parser.
    """
    command.add_argument("--host", required=True, help="camera address")
    command.add_argument("--port", type=int, default=DEFAULT_PORT, help="camera TCP port")
    command.add_argument("--device-id", type=int, required=True, help="device id from the camera label")
    command.add_argument("--username", default="admin", help="camera user name")
    command.add_argument("--password", help="camera password; prefer --password-env or --password-file")
    command.add_argument("--password-file", help="file holding the camera password")
    command.add_argument("--password-env", default=PASSWORD_ENV, help="environment variable holding the password")
    command.add_argument("--stream", choices=("main", "sub"), default="main", help="stream to receive")
    command.add_argument("--sound", action="store_true", help="ask the camera for audio")


def parser() -> argparse.ArgumentParser:
    """Build the argument parser.

    Returns:
        The parser.
    """
    root = argparse.ArgumentParser(prog="python -m camera_adapters.v380", description=__doc__)
    root.add_argument("--verbose", action="store_true", help="log every session event")
    commands = root.add_subparsers(dest="command", required=True)
    stream = commands.add_parser("stream", help="write the camera's video as Annex-B to standard output")
    camera_arguments(stream)
    stream.add_argument("--low-latency", action="store_true", help="rewrite the reorder declaration of key frames")
    stream.add_argument("--control-dir", default=DEFAULT_DIRECTORY, help="directory of the control socket")
    stream.add_argument("--no-control", action="store_true", help="serve no control socket")
    stream.add_argument("--broadcast", action="append", default=[], help="directed broadcast address for discovery")
    probe = commands.add_parser("probe", help="log in, wait for a key frame and print the session facts")
    camera_arguments(probe)
    found = commands.add_parser("discover", help="search the LAN and print the cameras that answer")
    found.add_argument("--broadcast", action="append", default=[], help="directed broadcast address")
    control = commands.add_parser("control", help="send a command through a stream process's control socket")
    control.add_argument("--device-id", required=True, help="device id of the camera")
    control.add_argument("--stream", choices=("main", "sub"), default="main", help="stream of the process")
    control.add_argument("--control-dir", default=DEFAULT_DIRECTORY, help="directory of the control socket")
    control.add_argument("action", choices=("ptz", "light", "siren", "picture", "flip", "facts"))
    control.add_argument("value", nargs="?", help="move, mode or siren seconds")
    return root


def camera(args: argparse.Namespace) -> Camera:
    """Build the camera from the arguments.

    Args:
        args: Parsed arguments.

    Returns:
        The camera.
    """
    return Camera(
        host=args.host, device_id=args.device_id, password=password(args), username=args.username, port=args.port
    )


async def stream(args: argparse.Namespace) -> int:
    """Stream video to standard output until stopped or the reader goes away.

    Args:
        args: Parsed arguments.

    Returns:
        The exit status.
    """
    output = AnnexBPipe(sys.stdout.fileno())
    await output.open()
    streamer = Streamer(
        camera(args),
        output,
        stream=Stream.MAIN if args.stream == "main" else Stream.SUB,
        sound=args.sound,
        low_latency=args.low_latency,
        broadcasts=tuple(args.broadcast),
    )
    server = None
    if not args.no_control:
        server = ControlServer(socket_path(args.control_dir, args.device_id, args.stream), streamer.command)
        try:
            await server.start()
        except OSError as exc:
            logger.error("No control socket: %s", exc)
            server = None
    loop = asyncio.get_running_loop()
    for number in (signal.SIGTERM, signal.SIGINT):
        with contextlib.suppress(NotImplementedError):
            loop.add_signal_handler(number, streamer.stop)
    task = asyncio.create_task(streamer.run())
    stopped = asyncio.create_task(streamer.stopping.wait())
    status = 0
    try:
        await asyncio.wait({task, stopped}, return_when=asyncio.FIRST_COMPLETED)
        if not task.done():
            await asyncio.wait_for(asyncio.shield(task), 5.0)
        task.result()
    except (BrokenPipeError, ConnectionResetError):
        logger.info("The output reader went away")
    except TimeoutError:
        task.cancel()
        await asyncio.gather(task, return_exceptions=True)
    finally:
        stopped.cancel()
        if server is not None:
            await server.stop()
        output.close()
    return status


async def probe(args: argparse.Namespace) -> int:
    """Open one session, wait for its first key frame and print the facts.

    Args:
        args: Parsed arguments.

    Returns:
        0 on success, 1 on failure.
    """
    session = Session(camera(args), Stream.MAIN if args.stream == "main" else Stream.SUB, args.sound)
    try:
        async with session:
            await first_key_frame(session, PROBE_SECONDS)
    except V380Error as exc:
        print(json.dumps({"ok": False, "code": exc.code, "error": exc.message}))
        return 1
    print(json.dumps({"ok": True, "facts": asdict(session.facts)}))
    return 0


async def search(args: argparse.Namespace) -> int:
    """Print the cameras that answer a search.

    Args:
        args: Parsed arguments.

    Returns:
        0.
    """
    for found in await discover(tuple(args.broadcast)):
        print(json.dumps(asdict(found)))
    return 0


async def control(args: argparse.Namespace) -> int:
    """Send one command to a stream process.

    Args:
        args: Parsed arguments.

    Returns:
        0 when the command was carried out, 1 otherwise.
    """
    request: dict = {"command": args.action}
    if args.action == "ptz":
        request["move"] = args.value
    elif args.action in ("light", "picture"):
        request["mode"] = args.value
    elif args.action == "siren":
        request["seconds"] = float(args.value or 0)
    try:
        answer = await send(socket_path(args.control_dir, args.device_id, args.stream), request)
    except OSError as exc:
        print(json.dumps({"ok": False, "error": str(exc)}))
        return 1
    print(json.dumps(answer))
    return 0 if answer.get("ok") else 1


def main(argv: list[str] | None = None) -> int:
    """Run a command.

    Args:
        argv: Arguments without the program name, sys.argv when omitted.

    Returns:
        The exit status.
    """
    args = parser().parse_args(argv)
    logging.basicConfig(
        level=logging.DEBUG if args.verbose else logging.INFO,
        stream=sys.stderr,
        format="%(asctime)s %(levelname)s %(name)s %(message)s",
    )
    commands = {"stream": stream, "probe": probe, "discover": search, "control": control}
    return asyncio.run(commands[args.command](args))
