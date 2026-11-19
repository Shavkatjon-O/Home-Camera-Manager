from dataclasses import dataclass
from uuid import UUID

BRIDGED_DEVICE_PORT = 8800


@dataclass(frozen=True)
class Target:
    kind: str
    uuid: UUID
    host: str
    port: int
    parent_uuid: UUID | None = None


def camera_address(host: str, device_host: str | None, rtsp_port: int) -> tuple[str, int]:
    if device_host:
        return device_host, BRIDGED_DEVICE_PORT
    return host, rtsp_port


def depth_order(targets: list[Target]) -> list[Target]:
    parents = {target.uuid: target.parent_uuid for target in targets}

    def depth(target_uuid: UUID) -> int:
        seen = {target_uuid}
        level = 0
        parent = parents.get(target_uuid)
        while parent is not None and parent not in seen:
            seen.add(parent)
            level += 1
            parent = parents.get(parent)
        return level

    return sorted(targets, key=lambda target: depth(target.uuid))
