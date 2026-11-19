from datetime import datetime
from uuid import UUID

from fastapi import APIRouter, Depends, Query, Response, status

from app.modules.control.deps import get_control_service
from app.modules.control.schemas import (
    AudioRead,
    DeviceRead,
    EncoderUpdate,
    ExtrasRead,
    ImageRead,
    ImageSettings,
    LightRequest,
    MotionRead,
    MotionUpdate,
    PresetName,
    PresetsRead,
    RecordingsRead,
    ReplayCreate,
    ReplayRead,
    SirenRequest,
    VideoRead,
)
from app.modules.control.services import CameraControlService

router = APIRouter()


def no_content() -> Response:
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.get("/{uuid}/device", response_model=DeviceRead)
async def get_device(uuid: UUID, service: CameraControlService = Depends(get_control_service)) -> DeviceRead:
    return await service.device(uuid)


@router.post("/{uuid}/device/sync-time", response_model=DeviceRead)
async def sync_time(uuid: UUID, service: CameraControlService = Depends(get_control_service)) -> DeviceRead:
    return await service.sync_time(uuid)


@router.post("/{uuid}/device/reboot", status_code=status.HTTP_204_NO_CONTENT)
async def reboot(uuid: UUID, service: CameraControlService = Depends(get_control_service)) -> Response:
    await service.reboot(uuid)
    return no_content()


@router.get("/{uuid}/video", response_model=VideoRead)
async def get_video(uuid: UUID, service: CameraControlService = Depends(get_control_service)) -> VideoRead:
    return await service.video(uuid)


@router.put("/{uuid}/video/{token}", response_model=VideoRead)
async def update_video(
    uuid: UUID,
    token: str,
    payload: EncoderUpdate,
    service: CameraControlService = Depends(get_control_service),
) -> VideoRead:
    return await service.update_video(uuid, token, payload)


@router.get("/{uuid}/image", response_model=ImageRead)
async def get_image(uuid: UUID, service: CameraControlService = Depends(get_control_service)) -> ImageRead:
    return await service.image(uuid)


@router.patch("/{uuid}/image", response_model=ImageRead)
async def update_image(
    uuid: UUID,
    payload: ImageSettings,
    service: CameraControlService = Depends(get_control_service),
) -> ImageRead:
    return await service.update_image(uuid, payload)


@router.get("/{uuid}/motion", response_model=MotionRead)
async def get_motion(uuid: UUID, service: CameraControlService = Depends(get_control_service)) -> MotionRead:
    return await service.motion(uuid)


@router.patch("/{uuid}/motion", response_model=MotionRead)
async def update_motion(
    uuid: UUID,
    payload: MotionUpdate,
    service: CameraControlService = Depends(get_control_service),
) -> MotionRead:
    return await service.update_motion(uuid, payload)


@router.get("/{uuid}/presets", response_model=PresetsRead)
async def list_presets(uuid: UUID, service: CameraControlService = Depends(get_control_service)) -> PresetsRead:
    return await service.presets(uuid)


@router.post("/{uuid}/presets", response_model=PresetsRead, status_code=status.HTTP_201_CREATED)
async def create_preset(
    uuid: UUID,
    payload: PresetName,
    service: CameraControlService = Depends(get_control_service),
) -> PresetsRead:
    return await service.create_preset(uuid, payload.name)


@router.patch("/{uuid}/presets/{token}", response_model=PresetsRead)
async def rename_preset(
    uuid: UUID,
    token: str,
    payload: PresetName,
    service: CameraControlService = Depends(get_control_service),
) -> PresetsRead:
    return await service.rename_preset(uuid, token, payload.name)


@router.delete("/{uuid}/presets/{token}", response_model=PresetsRead)
async def remove_preset(
    uuid: UUID,
    token: str,
    service: CameraControlService = Depends(get_control_service),
) -> PresetsRead:
    return await service.remove_preset(uuid, token)


@router.post("/{uuid}/presets/{token}/goto", status_code=status.HTTP_204_NO_CONTENT)
async def goto_preset(
    uuid: UUID,
    token: str,
    service: CameraControlService = Depends(get_control_service),
) -> Response:
    await service.goto_preset(uuid, token)
    return no_content()


@router.post("/{uuid}/home/goto", status_code=status.HTTP_204_NO_CONTENT)
async def goto_home(uuid: UUID, service: CameraControlService = Depends(get_control_service)) -> Response:
    await service.goto_home(uuid)
    return no_content()


@router.post("/{uuid}/home/set", status_code=status.HTTP_204_NO_CONTENT)
async def set_home(uuid: UUID, service: CameraControlService = Depends(get_control_service)) -> Response:
    await service.set_home(uuid)
    return no_content()


@router.get("/{uuid}/recordings", response_model=RecordingsRead)
async def list_recordings(
    uuid: UUID,
    start: datetime | None = Query(None, alias="from"),
    end: datetime | None = Query(None, alias="to"),
    service: CameraControlService = Depends(get_control_service),
) -> RecordingsRead:
    return await service.recordings(uuid, start, end)


@router.get("/{uuid}/replay", response_model=ReplayRead)
async def replay_status(uuid: UUID, service: CameraControlService = Depends(get_control_service)) -> ReplayRead:
    return await service.replay_status(uuid)


@router.post("/{uuid}/replay", response_model=ReplayRead)
async def start_replay(
    uuid: UUID,
    payload: ReplayCreate,
    service: CameraControlService = Depends(get_control_service),
) -> ReplayRead:
    return await service.start_replay(uuid, payload.start, payload.session)


@router.delete("/{uuid}/replay", status_code=status.HTTP_204_NO_CONTENT)
async def stop_replay(
    uuid: UUID,
    session: str | None = Query(None, max_length=64),
    service: CameraControlService = Depends(get_control_service),
) -> Response:
    await service.stop_replay(uuid, session)
    return no_content()


@router.get("/{uuid}/extras", response_model=ExtrasRead)
async def get_extras(uuid: UUID, service: CameraControlService = Depends(get_control_service)) -> ExtrasRead:
    return await service.extras(uuid)


@router.post("/{uuid}/extras/light", status_code=status.HTTP_204_NO_CONTENT)
async def set_light(
    uuid: UUID,
    payload: LightRequest,
    service: CameraControlService = Depends(get_control_service),
) -> Response:
    await service.light(uuid, payload.mode)
    return no_content()


@router.post("/{uuid}/extras/siren", status_code=status.HTTP_204_NO_CONTENT)
async def set_siren(
    uuid: UUID,
    payload: SirenRequest,
    service: CameraControlService = Depends(get_control_service),
) -> Response:
    await service.siren(uuid, payload.seconds)
    return no_content()


@router.get("/{uuid}/audio", response_model=AudioRead)
async def get_audio(uuid: UUID, service: CameraControlService = Depends(get_control_service)) -> AudioRead:
    return await service.audio(uuid)
