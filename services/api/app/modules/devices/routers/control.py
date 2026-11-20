"""HTTP endpoints for controlling cameras: device, video, image, motion, PTZ presets, recordings and extras."""

from datetime import datetime
from uuid import UUID

from fastapi import APIRouter, Depends, Query, Response, status

from app.modules.devices.deps import get_control_service
from app.modules.devices.schemas import (
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
from app.modules.devices.services import CameraControlService
from app.modules.operations.deps import audited
from app.modules.operations.enums import AuditAction
from app.modules.tenancy.deps import require_admin, require_operator

router = APIRouter()


def no_content() -> Response:
    """Build an empty 204 response.

    Returns:
        Response with no body.
    """
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.get("/{uuid}/device", response_model=DeviceRead)
async def get_camera_device(uuid: UUID, service: CameraControlService = Depends(get_control_service)) -> DeviceRead:
    """Return the camera's ONVIF device details and clock.

    Args:
        uuid: Public id of the camera.
        service: Camera control service for the request.

    Returns:
        Device information, or the reason it is unavailable.
    """
    return await service.device(uuid)


@router.post(
    "/{uuid}/device/sync-time",
    dependencies=[Depends(audited(AuditAction.CAMERA_CONTROL, "camera")), Depends(require_admin)],
    response_model=DeviceRead,
)
async def sync_camera_time(uuid: UUID, service: CameraControlService = Depends(get_control_service)) -> DeviceRead:
    """Set the camera's clock to this server's time.

    Args:
        uuid: Public id of the camera.
        service: Camera control service for the request.

    Returns:
        Device information read after the clock change.
    """
    return await service.sync_time(uuid)


@router.post(
    "/{uuid}/device/reboot",
    dependencies=[Depends(audited(AuditAction.CAMERA_CONTROL, "camera")), Depends(require_admin)],
    status_code=status.HTTP_204_NO_CONTENT,
)
async def reboot_camera(uuid: UUID, service: CameraControlService = Depends(get_control_service)) -> Response:
    """Reboot the camera.

    Args:
        uuid: Public id of the camera.
        service: Camera control service for the request.

    Returns:
        Empty 204 response.
    """
    await service.reboot(uuid)
    return no_content()


@router.get("/{uuid}/video", response_model=VideoRead)
async def get_video_settings(uuid: UUID, service: CameraControlService = Depends(get_control_service)) -> VideoRead:
    """Return the camera's video encoders and the options each offers.

    Args:
        uuid: Public id of the camera.
        service: Camera control service for the request.

    Returns:
        Encoder settings, or the reason they are unavailable.
    """
    return await service.video(uuid)


@router.put(
    "/{uuid}/video/{token}",
    dependencies=[Depends(audited(AuditAction.CAMERA_CONTROL, "camera")), Depends(require_admin)],
    response_model=VideoRead,
)
async def update_video_encoder(
    uuid: UUID,
    token: str,
    payload: EncoderUpdate,
    service: CameraControlService = Depends(get_control_service),
) -> VideoRead:
    """Change the settings of one video encoder.

    Args:
        uuid: Public id of the camera.
        token: ONVIF token of the encoder.
        payload: Encoder values to change.
        service: Camera control service for the request.

    Returns:
        Encoder settings read after the change.
    """
    return await service.update_video(uuid, token, payload)


@router.get("/{uuid}/image", response_model=ImageRead)
async def get_image_settings(uuid: UUID, service: CameraControlService = Depends(get_control_service)) -> ImageRead:
    """Return the camera's imaging settings and the options it offers.

    Args:
        uuid: Public id of the camera.
        service: Camera control service for the request.

    Returns:
        Imaging settings, or the reason they are unavailable.
    """
    return await service.image(uuid)


@router.patch(
    "/{uuid}/image",
    dependencies=[Depends(audited(AuditAction.CAMERA_CONTROL, "camera")), Depends(require_admin)],
    response_model=ImageRead,
)
async def update_image_settings(
    uuid: UUID,
    payload: ImageSettings,
    service: CameraControlService = Depends(get_control_service),
) -> ImageRead:
    """Change the camera's imaging settings.

    Args:
        uuid: Public id of the camera.
        payload: Imaging values to change.
        service: Camera control service for the request.

    Returns:
        Imaging settings read after the change.
    """
    return await service.update_image(uuid, payload)


@router.get("/{uuid}/motion", response_model=MotionRead)
async def get_motion_settings(uuid: UUID, service: CameraControlService = Depends(get_control_service)) -> MotionRead:
    """Return the camera's motion detection setup.

    Args:
        uuid: Public id of the camera.
        service: Camera control service for the request.

    Returns:
        Motion detection setup, or the reason it is unavailable.
    """
    return await service.motion(uuid)


@router.patch(
    "/{uuid}/motion",
    dependencies=[Depends(audited(AuditAction.CAMERA_CONTROL, "camera")), Depends(require_admin)],
    response_model=MotionRead,
)
async def update_motion_settings(
    uuid: UUID,
    payload: MotionUpdate,
    service: CameraControlService = Depends(get_control_service),
) -> MotionRead:
    """Change the camera's motion sensitivity or switch detection on or off.

    Args:
        uuid: Public id of the camera.
        payload: Motion values to change.
        service: Camera control service for the request.

    Returns:
        Motion detection setup read after the change.
    """
    return await service.update_motion(uuid, payload)


@router.get("/{uuid}/presets", response_model=PresetsRead)
async def list_presets(uuid: UUID, service: CameraControlService = Depends(get_control_service)) -> PresetsRead:
    """List the camera's PTZ presets.

    Args:
        uuid: Public id of the camera.
        service: Camera control service for the request.

    Returns:
        Presets, or the reason they are unavailable.
    """
    return await service.presets(uuid)


@router.post(
    "/{uuid}/presets",
    dependencies=[Depends(audited(AuditAction.CAMERA_CONTROL, "camera")), Depends(require_admin)],
    response_model=PresetsRead,
    status_code=status.HTTP_201_CREATED,
)
async def create_preset(
    uuid: UUID,
    payload: PresetName,
    service: CameraControlService = Depends(get_control_service),
) -> PresetsRead:
    """Save the camera's current position as a new PTZ preset.

    Args:
        uuid: Public id of the camera.
        payload: Name of the preset.
        service: Camera control service for the request.

    Returns:
        Presets read after the change.
    """
    return await service.create_preset(uuid, payload.name)


@router.patch(
    "/{uuid}/presets/{token}",
    dependencies=[Depends(audited(AuditAction.CAMERA_CONTROL, "camera")), Depends(require_admin)],
    response_model=PresetsRead,
)
async def rename_preset(
    uuid: UUID,
    token: str,
    payload: PresetName,
    service: CameraControlService = Depends(get_control_service),
) -> PresetsRead:
    """Rename a PTZ preset.

    Args:
        uuid: Public id of the camera.
        token: ONVIF token of the preset.
        payload: New name of the preset.
        service: Camera control service for the request.

    Returns:
        Presets read after the change.
    """
    return await service.rename_preset(uuid, token, payload.name)


@router.delete(
    "/{uuid}/presets/{token}",
    dependencies=[Depends(audited(AuditAction.CAMERA_CONTROL, "camera")), Depends(require_admin)],
    response_model=PresetsRead,
)
async def remove_preset(
    uuid: UUID,
    token: str,
    service: CameraControlService = Depends(get_control_service),
) -> PresetsRead:
    """Delete a PTZ preset.

    Args:
        uuid: Public id of the camera.
        token: ONVIF token of the preset.
        service: Camera control service for the request.

    Returns:
        Presets read after the change.
    """
    return await service.remove_preset(uuid, token)


@router.post(
    "/{uuid}/presets/{token}/goto", dependencies=[Depends(require_operator)], status_code=status.HTTP_204_NO_CONTENT
)
async def goto_preset(
    uuid: UUID,
    token: str,
    service: CameraControlService = Depends(get_control_service),
) -> Response:
    """Move the camera to a PTZ preset.

    Args:
        uuid: Public id of the camera.
        token: ONVIF token of the preset.
        service: Camera control service for the request.

    Returns:
        Empty 204 response.
    """
    await service.goto_preset(uuid, token)
    return no_content()


@router.post("/{uuid}/home/goto", dependencies=[Depends(require_operator)], status_code=status.HTTP_204_NO_CONTENT)
async def goto_home(uuid: UUID, service: CameraControlService = Depends(get_control_service)) -> Response:
    """Move the camera to its PTZ home position.

    Args:
        uuid: Public id of the camera.
        service: Camera control service for the request.

    Returns:
        Empty 204 response.
    """
    await service.goto_home(uuid)
    return no_content()


@router.post(
    "/{uuid}/home/set",
    dependencies=[Depends(audited(AuditAction.CAMERA_CONTROL, "camera")), Depends(require_admin)],
    status_code=status.HTTP_204_NO_CONTENT,
)
async def set_home(uuid: UUID, service: CameraControlService = Depends(get_control_service)) -> Response:
    """Store the camera's current position as its PTZ home position.

    Args:
        uuid: Public id of the camera.
        service: Camera control service for the request.

    Returns:
        Empty 204 response.
    """
    await service.set_home(uuid)
    return no_content()


@router.get("/{uuid}/recordings", dependencies=[Depends(require_operator)], response_model=RecordingsRead)
async def list_recordings(
    uuid: UUID,
    start: datetime | None = Query(None, alias="from"),
    end: datetime | None = Query(None, alias="to"),
    service: CameraControlService = Depends(get_control_service),
) -> RecordingsRead:
    """Summarise the recordings on the camera's SD card and list the segments in a time range.

    Args:
        uuid: Public id of the camera.
        start: Start of the range, passed as the from query parameter.
        end: End of the range, passed as the to query parameter.
        service: Camera control service for the request.

    Returns:
        Recording summary and segments, or the reason they are unavailable.
    """
    return await service.recordings(uuid, start, end)


@router.get("/{uuid}/replay", dependencies=[Depends(require_operator)], response_model=ReplayRead)
async def replay_status(uuid: UUID, service: CameraControlService = Depends(get_control_service)) -> ReplayRead:
    """Return the state of the camera's SD card playback session.

    Args:
        uuid: Public id of the camera.
        service: Camera control service for the request.

    Returns:
        Whether a playback session is active and which one.
    """
    return await service.replay_status(uuid)


@router.post("/{uuid}/replay", dependencies=[Depends(require_operator)], response_model=ReplayRead)
async def start_replay(
    uuid: UUID,
    payload: ReplayCreate,
    service: CameraControlService = Depends(get_control_service),
) -> ReplayRead:
    """Start SD card playback from a point in time.

    Args:
        uuid: Public id of the camera.
        payload: Start time and optional session id.
        service: Camera control service for the request.

    Returns:
        The playback session that was opened.
    """
    return await service.start_replay(uuid, payload.start, payload.session)


@router.delete("/{uuid}/replay", dependencies=[Depends(require_operator)], status_code=status.HTTP_204_NO_CONTENT)
async def stop_replay(
    uuid: UUID,
    session: str | None = Query(None, max_length=64),
    service: CameraControlService = Depends(get_control_service),
) -> Response:
    """Stop the camera's SD card playback session.

    Args:
        uuid: Public id of the camera.
        session: Id of the session to stop; when given, a different current session is left running.
        service: Camera control service for the request.

    Returns:
        Empty 204 response.
    """
    await service.stop_replay(uuid, session)
    return no_content()


@router.get("/{uuid}/extras", response_model=ExtrasRead)
async def get_camera_extras(uuid: UUID, service: CameraControlService = Depends(get_control_service)) -> ExtrasRead:
    """Report whether the camera has a light and a siren behind a V380 bridge.

    Args:
        uuid: Public id of the camera.
        service: Camera control service for the request.

    Returns:
        Whether the light and siren can be controlled.
    """
    return await service.extras(uuid)


@router.post(
    "/{uuid}/extras/light",
    dependencies=[Depends(audited(AuditAction.CAMERA_CONTROL, "camera")), Depends(require_operator)],
    status_code=status.HTTP_204_NO_CONTENT,
)
async def set_light(
    uuid: UUID,
    payload: LightRequest,
    service: CameraControlService = Depends(get_control_service),
) -> Response:
    """Set the light mode through the V380 bridge.

    Args:
        uuid: Public id of the camera.
        payload: Light mode to set.
        service: Camera control service for the request.

    Returns:
        Empty 204 response.
    """
    await service.light(uuid, payload.mode)
    return no_content()


@router.post(
    "/{uuid}/extras/siren",
    dependencies=[Depends(audited(AuditAction.CAMERA_CONTROL, "camera")), Depends(require_operator)],
    status_code=status.HTTP_204_NO_CONTENT,
)
async def set_siren(
    uuid: UUID,
    payload: SirenRequest,
    service: CameraControlService = Depends(get_control_service),
) -> Response:
    """Sound or silence the siren through the V380 bridge.

    Args:
        uuid: Public id of the camera.
        payload: Number of seconds to sound the siren, where 0 turns it off.
        service: Camera control service for the request.

    Returns:
        Empty 204 response.
    """
    await service.siren(uuid, payload.seconds)
    return no_content()


@router.get("/{uuid}/audio", response_model=AudioRead)
async def get_camera_audio(uuid: UUID, service: CameraControlService = Depends(get_control_service)) -> AudioRead:
    """Report whether the camera stream carries audio the browser player can play.

    Args:
        uuid: Public id of the camera.
        service: Camera control service for the request.

    Returns:
        Audio support, with the codec or the reason it is unavailable.
    """
    return await service.audio(uuid)
