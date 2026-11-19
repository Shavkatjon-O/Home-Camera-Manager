"""Probe targets and the address used to reach a camera."""

from dataclasses import dataclass
from uuid import UUID

BRIDGED_DEVICE_PORT = 8800


@dataclass(frozen=True)
class Target:
    """One device or camera to probe.

    Attributes:
        kind: Target kind, a TargetKind value.
        uuid: Public id of the device or camera.
        host: Address to probe.
        port: TCP port to probe.
        parent_uuid: Public id of the device this target connects through, if any.
    """

    kind: str
    uuid: UUID
    host: str
    port: int
    parent_uuid: UUID | None = None


def camera_address(host: str, device_host: str | None, rtsp_port: int) -> tuple[str, int]:
    """Choose the host and port that show whether a camera is reachable.

    A bridged camera is probed on its device address and port 8800, because the bridge container answers even when
    the camera is gone.

    Args:
        host: Address the camera is streamed from.
        device_host: Address of the camera itself when it is bridged, otherwise empty.
        rtsp_port: RTSP port of the camera.

    Returns:
        The device address and port 8800 for a bridged camera, otherwise the host and RTSP port.
    """
    if device_host:
        return device_host, BRIDGED_DEVICE_PORT
    return host, rtsp_port


def depth_order(targets: list[Target]) -> list[Target]:
    """Sort targets so every target comes after the devices it connects through.

    Targets are ordered by how many parents lie above them. A parent loop is cut where it would repeat.

    Args:
        targets: Targets to order.

    Returns:
        The targets from the top of the topology downward.
    """
    parents = {target.uuid: target.parent_uuid for target in targets}

    def depth(target_uuid: UUID) -> int:
        """Count the parents above a target.

        Args:
            target_uuid: Public id of the target.

        Returns:
            Number of ancestors, stopping if a loop is found.
        """
        seen = {target_uuid}
        level = 0
        parent = parents.get(target_uuid)
        while parent is not None and parent not in seen:
            seen.add(parent)
            level += 1
            parent = parents.get(parent)
        return level

    return sorted(targets, key=lambda target: depth(target.uuid))
