"""The go2rtc exec source that runs the V380 client and reads its Annex-B video from standard output."""

import os
import shlex
import sys
from pathlib import Path

from camera_adapters.v380.control import DEFAULT_DIRECTORY

__all__ = ["CONTROL_DIRECTORY_ENV", "control_directory", "exec_source", "password_file"]

CONTROL_DIRECTORY_ENV = "SSS_V380_CONTROL_DIR"
KILL_OPTIONS = "#killsignal=15#killtimeout=5"


def control_directory() -> str:
    """Return the directory of the control sockets and password files.

    Returns:
        SSS_V380_CONTROL_DIR, or /tmp/sss-v380 when it is unset.
    """
    return os.environ.get(CONTROL_DIRECTORY_ENV) or DEFAULT_DIRECTORY


def password_file(directory: str, device_id: int | str, password: str) -> Path:
    """Write a camera password to a file only its owner can read, for the stream process to read.

    Args:
        directory: Directory of the file.
        device_id: Device id of the camera.
        password: The password.

    Returns:
        The file path.
    """
    folder = Path(directory)
    folder.mkdir(parents=True, exist_ok=True, mode=0o700)
    path = folder / f"{device_id}.password"
    descriptor = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
    with os.fdopen(descriptor, "w") as handle:
        handle.write(password)
    return path


def exec_source(
    host: str,
    device_id: int | str,
    password: str,
    stream: str = "main",
    port: int = 8800,
    username: str = "admin",
    directory: str | None = None,
    python: str | None = None,
) -> str:
    """Build the go2rtc exec source of a camera stream.

    go2rtc starts the stream process when a consumer arrives and stops it with SIGTERM when the last one leaves;
    the process then stops a running move before it closes the session. The password goes into a file rather than
    onto the command line, which go2rtc shows in its stream list.

    Args:
        host: Camera address.
        device_id: Device id.
        password: Camera password.
        stream: main or sub.
        port: Camera TCP port.
        username: Camera user name.
        directory: Directory of the control socket and password file, control_directory() when omitted.
        python: Python interpreter that has camera_adapters, the current one when omitted.

    Returns:
        The source, starting with exec:.
    """
    directory = directory or control_directory()
    secret = password_file(directory, device_id, password)
    arguments = [
        python or sys.executable,
        "-m",
        "camera_adapters.v380",
        "stream",
        "--host",
        host,
        "--port",
        str(port),
        "--device-id",
        str(device_id),
        "--username",
        username,
        "--password-file",
        str(secret),
        "--stream",
        stream,
        "--control-dir",
        directory,
    ]
    return "exec:" + shlex.join(arguments) + KILL_OPTIONS
