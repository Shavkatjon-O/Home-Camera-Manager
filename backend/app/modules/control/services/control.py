"""Camera control service: ONVIF settings, PTZ presets, SD card recordings and replay, and the V380 bridge."""

import asyncio
from dataclasses import dataclass
from datetime import UTC, datetime, timedelta
from urllib.parse import quote, urlsplit, urlunsplit
from uuid import UUID

from sqlalchemy.ext.asyncio import AsyncSession

from adapters.ezviz.quirks import ENCODER_SERVICES, corrected_sensitivity
from adapters.onvif import analytics, imaging, media, ptz, recordings, system
from adapters.onvif.media import Encoder, EncodingOptions, Range, StreamProfile
from adapters.onvif.soap import OnvifError, OnvifFault, OnvifRefused, descendant, descendants, text
from adapters.v380.bridge import BridgeClient, BridgeError
from app.auth.context import UserContext
from app.core.base_service import BaseModelService
from app.core.config import settings
from app.core.exceptions import BadGateway, Conflict, NotFound, Unprocessable
from app.models import Camera
from app.modules.control.schemas import (
    AudioRead,
    ClockRead,
    DeviceRead,
    EncoderOptionsRead,
    EncoderRead,
    EncoderUpdate,
    ExtrasRead,
    ImageOptionsRead,
    ImageRead,
    ImageSettings,
    MotionRead,
    MotionUpdate,
    PresetRead,
    PresetsRead,
    RangeRead,
    RecordingsRead,
    ReplayRead,
    ResolutionRead,
    SegmentRead,
    VideoRead,
)
from app.onvif.endpoints import Connection, Directory, OnvifEndpoint, bridge_endpoint, device_endpoint, directory
from app.streaming.go2rtc import Go2rtcError
from app.streaming.replay import ReplayBusy, ReplayStreams, replay_streams

__all__ = ["CameraControlService", "NotOffered"]

SENSITIVITY_RANGE = RangeRead(min=0, max=100)
FPS_TOLERANCE = 0.01
SEARCH_ROUNDS = 20
PRESET_ACTION_TIMEOUT = 8.0

REPLAY_OFF = "Playback is off: the cameras reset local playback sessions right after PLAY, use the vendor app"

AUDIO_CODECS = {"AAC": "AAC", "MP4A-LATM": "AAC", "MPEG4-GENERIC": "AAC", "OPUS": "Opus"}

remembered_cells: dict[UUID, str] = {}


class NotOffered(Exception):
    """Raised when a camera does not offer the feature or ONVIF service a call needs."""

    pass


@dataclass(frozen=True)
class PtzTarget:
    """ONVIF connection and profile that serve PTZ presets for a camera.

    Attributes:
        connection: Open connection to the endpoint that serves PTZ.
        profile_token: Token of the media profile with PTZ.
        node: PTZ node details, including preset and home support.
    """

    connection: Connection
    profile_token: str
    node: ptz.NodeInfo


def range_read(value: Range | None) -> RangeRead | None:
    """Convert an ONVIF range to its response schema.

    Args:
        value: Range reported by the camera, if any.

    Returns:
        The range as a schema, or None when the camera reported none.
    """
    if value is None:
        return None
    return RangeRead(min=value.minimum, max=value.maximum)


def within(value: float, limits: Range | None) -> bool:
    """Check that a value lies inside a range.

    The range edges are widened by FPS_TOLERANCE, the margin also used to match listed frame rates.

    Args:
        value: Value to check.
        limits: Allowed range, or None when the camera reports none.

    Returns:
        True when there are no limits or the value is inside them.
    """
    return limits is None or limits.minimum - FPS_TOLERANCE <= value <= limits.maximum + FPS_TOLERANCE


def options_read(option: EncodingOptions) -> EncoderOptionsRead:
    """Convert one ONVIF encoding option to its response schema.

    Args:
        option: Encoder options the camera offers for one encoding.

    Returns:
        The options as a schema.
    """
    return EncoderOptionsRead(
        encoding=option.encoding,
        resolutions=[ResolutionRead(width=width, height=height) for width, height in option.resolutions],
        fps_values=list(option.fps_values),
        fps=range_read(option.fps_range),
        bitrate=range_read(option.bitrate),
        gop=range_read(option.gop),
        quality=range_read(option.quality),
        profiles=list(option.profiles),
    )


def with_credentials(uri: str, username: str | None, password: str | None) -> str:
    """Put a username and password into a URI.

    Args:
        uri: URI to complete.
        username: Username to embed, if any.
        password: Password to embed, if any.

    Returns:
        The URI with the credentials percent-encoded into its host part, or the URI unchanged when there is no username
        or it already carries credentials.
    """
    parts = urlsplit(uri)
    if not username or "@" in parts.netloc:
        return uri
    credentials = quote(username, safe="")
    if password:
        credentials = f"{credentials}:{quote(password, safe='')}"
    return urlunsplit((parts.scheme, f"{credentials}@{parts.netloc}", parts.path, parts.query, parts.fragment))


def with_start(uri: str, start: datetime) -> str:
    """Set the start time of an SD card replay URI.

    Args:
        uri: Replay URI the camera gave.
        start: Time to play from.

    Returns:
        The URI with its starttime query parameter set to start in UTC, replacing any existing one.
    """
    parts = urlsplit(uri)
    stamp = start.astimezone(UTC).strftime("%Y%m%dT%H%M%SZ")
    query = "&".join(item for item in parts.query.split("&") if item and not item.startswith("starttime="))
    query = f"{query}&starttime={stamp}" if query else f"starttime={stamp}"
    return urlunsplit((parts.scheme, parts.netloc, parts.path, query, parts.fragment))


class CameraControlService(BaseModelService[Camera]):
    """Reads and changes camera settings over ONVIF and the V380 bridge.

    Attributes:
        model: Model class the service manages.
        not_found_code: Error code raised when a camera does not exist.
        directory: Cache of open ONVIF connections.
        replays: Registry of SD card playback sessions.
    """

    model = Camera
    not_found_code = "camera_not_found"

    def __init__(
        self,
        session: AsyncSession,
        actor: UserContext | None = None,
        services: Directory = directory,
        replays: ReplayStreams = replay_streams,
    ):
        """Bind the service to a session, a user and its ONVIF and playback registries.

        Args:
            session: Database session the service works in.
            actor: User making the request, if any.
            services: Cache of open ONVIF connections.
            replays: Registry of SD card playback sessions.
        """
        super().__init__(session, actor)
        self.directory = services
        self.replays = replays

    async def get(self, uuid: UUID) -> Camera:
        """Load a camera the backend reaches itself.

        Args:
            uuid: Public id of the camera.

        Returns:
            The camera.

        Raises:
            Conflict: The camera is reached through a connector, which does not relay camera settings yet.
        """
        camera = await super().get(uuid)
        if camera.connector_id is not None:
            raise Conflict(
                "connector_camera", "Camera settings of a camera behind a connector are not available yet; PTZ is"
            )
        return camera

    async def open(self, endpoint: OnvifEndpoint) -> Connection:
        """Open an ONVIF connection to an endpoint.

        Args:
            endpoint: Endpoint to connect to.

        Returns:
            Open connection with the services the endpoint lists.

        Raises:
            NotOffered: When the endpoint refuses ONVIF or cannot be reached.
        """
        try:
            return await self.directory.open(endpoint)
        except OnvifRefused:
            raise NotOffered(f"The camera has no ONVIF service at {endpoint.label}")
        except OnvifError as exc:
            if endpoint.bridged:
                raise NotOffered(f"The camera has no ONVIF service at {endpoint.label}")
            raise NotOffered(str(exc))

    async def device_connection(self, camera: Camera) -> Connection:
        """Open the ONVIF connection to a camera's own device endpoint.

        Args:
            camera: Camera to connect to.

        Returns:
            Open connection to the camera.

        Raises:
            NotOffered: When the camera has no ONVIF port.
        """
        endpoint = device_endpoint(camera)
        if endpoint is None:
            raise NotOffered("The camera has no ONVIF port")
        return await self.open(endpoint)

    async def call(self, connection: Connection, service: str, body: str, secure: bool = True):
        """Send an ONVIF request to one of a connection's services.

        A transport failure drops the cached connection so that the next request connects again; a fault the camera
        answered with leaves it cached.

        Args:
            connection: Connection to send through.
            service: Name of the ONVIF service to call.
            body: SOAP body to send.
            secure: Whether to sign the request with the camera's credentials.

        Returns:
            The parsed answer.

        Raises:
            NotOffered: When the camera offers no such service.
            OnvifFault: When the camera answers with a fault.
            OnvifError: When the request fails in transport or the answer is invalid.
        """
        address = connection.address(service)
        if not address:
            raise NotOffered(f"The camera offers no {service} service")
        try:
            return await connection.client.call(address, body, secure=secure)
        except OnvifFault:
            raise
        except OnvifError:
            self.directory.drop(connection.endpoint)
            raise

    def forbid(self, exc: NotOffered) -> Conflict:
        """Turn a missing feature into an API error.

        Args:
            exc: Error that says what the camera does not offer.

        Returns:
            Conflict error with the not_supported code.
        """
        return Conflict("not_supported", str(exc))

    def gateway(self, exc: OnvifError) -> BadGateway:
        """Turn an ONVIF failure into an API error.

        Args:
            exc: ONVIF error to report.

        Returns:
            Bad gateway error with the onvif_error code.
        """
        return BadGateway("onvif_error", str(exc))

    async def device(self, uuid: UUID) -> DeviceRead:
        """Read a camera's device details and clock.

        Args:
            uuid: Public id of the camera.

        Returns:
            Device details, or a result marked unsupported with the reason when the camera cannot be
            read. The clock is left out when it cannot be read.
        """
        camera = await self.get(uuid)
        try:
            connection = await self.device_connection(camera)
        except NotOffered as exc:
            return DeviceRead(camera_uuid=camera.uuid, supported=False, reason=str(exc))
        try:
            details = system.parse_details(await self.call(connection, "device", system.DEVICE_INFORMATION))
        except OnvifError as exc:
            return DeviceRead(camera_uuid=camera.uuid, supported=False, reason=str(exc))
        clock = None
        try:
            parsed = system.parse_clock(await self.call(connection, "device", system.DATE_AND_TIME, secure=False))
            now = datetime.now(UTC)
            clock = ClockRead(
                camera_utc=parsed.utc,
                server_utc=now,
                offset_seconds=round((parsed.utc - now).total_seconds(), 1) if parsed.utc else None,
                mode=parsed.mode,
                timezone=parsed.timezone,
                daylight_savings=parsed.daylight_savings,
            )
        except OnvifError:
            pass
        return DeviceRead(
            camera_uuid=camera.uuid,
            supported=True,
            endpoint=connection.endpoint.label,
            manufacturer=details.manufacturer,
            model=details.model,
            firmware=details.firmware,
            serial=details.serial,
            hardware_id=details.hardware_id,
            clock=clock,
            can_reboot=True,
        )

    async def sync_time(self, uuid: UUID) -> DeviceRead:
        """Set a camera's clock to this server's time.

        A camera using NTP is put back in NTP mode after the manual time is set. The connection's cached clock offset is
        cleared so request signing reads the new camera time.

        Args:
            uuid: Public id of the camera.

        Returns:
            Device details read after the change.

        Raises:
            Conflict: When the camera offers no ONVIF device service.
            BadGateway: When the camera rejects or fails a request.
        """
        camera = await self.get(uuid)
        try:
            connection = await self.device_connection(camera)
        except NotOffered as exc:
            raise self.forbid(exc)
        try:
            clock = system.parse_clock(await self.call(connection, "device", system.DATE_AND_TIME, secure=False))
            await self.call(connection, "device", system.manual_time_body(clock, datetime.now(UTC)))
            if (clock.mode or "").upper() == "NTP":
                await self.call(connection, "device", system.ntp_mode_body(clock))
        except OnvifError as exc:
            raise self.gateway(exc)
        connection.client.clock_offset = None
        return await self.device(uuid)

    async def reboot(self, uuid: UUID) -> None:
        """Reboot a camera and forget its cached connection.

        Args:
            uuid: Public id of the camera.

        Raises:
            Conflict: When the camera offers no ONVIF device service.
            BadGateway: When the camera rejects or fails the request.
        """
        camera = await self.get(uuid)
        try:
            connection = await self.device_connection(camera)
        except NotOffered as exc:
            raise self.forbid(exc)
        try:
            await self.call(connection, "device", system.REBOOT)
        except OnvifError as exc:
            raise self.gateway(exc)
        self.directory.drop(connection.endpoint)

    async def media_state(
        self, connection: Connection
    ) -> tuple[str, list[StreamProfile], list[Encoder], dict[str, list[EncodingOptions]]]:
        """Read a camera's media profiles, video encoders and encoder options.

        Media2 is tried first and Media1 when Media2 is missing or answers a fault.

        Args:
            connection: Connection to the camera.

        Returns:
            The media service used, its profiles, its encoders and the options offered for each
            encoder token. An encoder whose options the camera refuses gets an empty list.

        Raises:
            OnvifFault: When every media service the camera lists answered a fault.
            NotOffered: When the camera lists no media service.
        """
        failure: Exception | None = None
        for service in ENCODER_SERVICES:
            if not connection.address(service):
                continue
            try:
                profiles = media.parse_profiles(
                    await self.call(connection, service, media.profiles_body(service)), service
                )
                encoders = media.parse_encoders(
                    await self.call(connection, service, media.encoders_body(service)), service
                )
            except OnvifFault as exc:
                failure = exc
                continue
            options: dict[str, list[EncodingOptions]] = {}
            for encoder in encoders:
                try:
                    body = await self.call(connection, service, media.options_body(encoder))
                except OnvifFault:
                    options[encoder.token] = []
                    continue
                parse = media.parse_media2_options if service == media.MEDIA2 else media.parse_media1_options
                options[encoder.token] = parse(body)
            return service, profiles, encoders, options
        if failure is not None:
            raise failure
        raise NotOffered("The camera offers no media service")

    async def video(self, uuid: UUID) -> VideoRead:
        """Read a camera's video encoders and the options each offers.

        Args:
            uuid: Public id of the camera.

        Returns:
            Encoder settings, or a result marked unsupported with the reason when the camera cannot be read.
        """
        camera = await self.get(uuid)
        try:
            connection = await self.device_connection(camera)
            service, profiles, encoders, options = await self.media_state(connection)
        except NotOffered as exc:
            return VideoRead(camera_uuid=camera.uuid, supported=False, reason=str(exc))
        except OnvifError as exc:
            return VideoRead(camera_uuid=camera.uuid, supported=False, reason=str(exc))
        items = []
        for encoder in encoders:
            items.append(
                EncoderRead(
                    token=encoder.token,
                    name=encoder.name,
                    profiles=[profile.name for profile in profiles if profile.encoder_token == encoder.token],
                    encoding=encoder.encoding,
                    width=encoder.width,
                    height=encoder.height,
                    fps=encoder.fps,
                    bitrate=encoder.bitrate,
                    gop=encoder.gop,
                    quality=encoder.quality,
                    profile=encoder.profile,
                    options=[options_read(option) for option in options.get(encoder.token, [])],
                )
            )
        return VideoRead(camera_uuid=camera.uuid, supported=True, service=service, encoders=items)

    def validate_encoder(self, encoder: Encoder, options: list[EncodingOptions], payload: EncoderUpdate) -> Encoder:
        """Apply requested changes to an encoder and check them against what the camera offers.

        Changing the encoding without naming a profile selects the first profile the new encoding
        offers when the current one is not among them. Nothing beyond the resolution pairing is
        checked when the camera lists no options.

        Args:
            encoder: Current encoder settings.
            options: Options the camera offers for the encoder.
            payload: Requested changes.

        Returns:
            The encoder settings to write.

        Raises:
            Unprocessable: When only one of width and height is given, or a value is not among the options offered.
        """
        if (payload.width is None) != (payload.height is None):
            raise Unprocessable("invalid_resolution", "Give both the width and the height")
        updated = media.changed(
            encoder,
            encoding=payload.encoding,
            width=payload.width,
            height=payload.height,
            fps=payload.fps,
            bitrate=payload.bitrate,
            gop=payload.gop,
            quality=payload.quality,
            profile=payload.profile,
        )
        if not options:
            return updated
        option = next((item for item in options if item.encoding.upper() == (updated.encoding or "").upper()), None)
        if option is None:
            raise Unprocessable("invalid_encoding", f"The camera does not offer {updated.encoding} on this stream")
        if payload.encoding is not None and payload.profile is None and option.profiles:
            if updated.profile not in option.profiles:
                updated = media.changed(updated, profile=option.profiles[0])
        if option.resolutions and (updated.width, updated.height) not in option.resolutions:
            raise Unprocessable("invalid_resolution", f"{updated.width}x{updated.height} is not offered")
        if updated.fps is not None:
            if option.fps_values and not any(abs(updated.fps - value) <= FPS_TOLERANCE for value in option.fps_values):
                raise Unprocessable("invalid_fps", f"{updated.fps:g} fps is not offered")
            if not within(updated.fps, option.fps_range):
                raise Unprocessable("invalid_fps", f"{updated.fps:g} fps is outside the allowed range")
        if updated.bitrate is not None and not within(updated.bitrate, option.bitrate):
            raise Unprocessable("invalid_bitrate", f"{updated.bitrate} kbit/s is outside the allowed range")
        if updated.gop is not None and not within(updated.gop, option.gop):
            raise Unprocessable("invalid_gop", f"A key frame interval of {updated.gop} is outside the allowed range")
        if updated.quality is not None and not within(updated.quality, option.quality):
            raise Unprocessable("invalid_quality", f"Quality {updated.quality:g} is outside the allowed range")
        if payload.profile is not None and option.profiles and payload.profile not in option.profiles:
            raise Unprocessable("invalid_profile", f"The profile {payload.profile} is not offered")
        return updated

    async def update_video(self, uuid: UUID, token: str, payload: EncoderUpdate) -> VideoRead:
        """Change the settings of one video encoder.

        Args:
            uuid: Public id of the camera.
            token: ONVIF token of the encoder.
            payload: Requested changes.

        Returns:
            Encoder settings read after the change.

        Raises:
            Conflict: When the camera offers no ONVIF media service.
            BadGateway: When the camera rejects or fails a request.
            NotFound: When the camera has no encoder with the token.
        """
        camera = await self.get(uuid)
        try:
            connection = await self.device_connection(camera)
            service, _, encoders, options = await self.media_state(connection)
        except NotOffered as exc:
            raise self.forbid(exc)
        except OnvifError as exc:
            raise self.gateway(exc)
        encoder = next((item for item in encoders if item.token == token), None)
        if encoder is None:
            raise NotFound("encoder_not_found", f"The camera has no video encoder {token}")
        updated = self.validate_encoder(encoder, options.get(token, []), payload)
        if updated == encoder:
            return await self.video(uuid)
        try:
            await self.call(connection, service, media.set_body(updated))
        except OnvifError as exc:
            raise self.gateway(exc)
        return await self.video(uuid)

    async def source_token(self, connection: Connection) -> str:
        """Find the token of a camera's video source.

        Args:
            connection: Connection to the camera.

        Returns:
            Token of the first source found in the media profiles, or in the Media1 source list when
            the profiles name none.

        Raises:
            NotOffered: When the camera reports no video source.
        """
        for service in (media.MEDIA1, media.MEDIA2):
            if not connection.address(service):
                continue
            try:
                profiles = media.parse_profiles(
                    await self.call(connection, service, media.profiles_body(service)), service
                )
            except OnvifFault:
                continue
            for profile in profiles:
                if profile.source_token:
                    return profile.source_token
        if connection.address(media.MEDIA1):
            tokens = imaging.video_sources(await self.call(connection, media.MEDIA1, "<trt:GetVideoSources/>"))
            if tokens:
                return tokens[0]
        raise NotOffered("The camera reports no video source")

    async def imaging_state(self, connection: Connection) -> tuple[str, imaging.ImagingState, imaging.ImagingOptions]:
        """Read a camera's imaging settings and the options it offers.

        Args:
            connection: Connection to the camera.

        Returns:
            The video source token, the current settings and the options. The options are empty when
            the camera answers a fault for them.

        Raises:
            NotOffered: When the camera offers no imaging service or video source.
        """
        if not connection.address("imaging"):
            raise NotOffered("The camera offers no imaging service")
        source = await self.source_token(connection)
        state = imaging.parse_settings(await self.call(connection, "imaging", imaging.settings_body(source)))
        try:
            options = imaging.parse_options(await self.call(connection, "imaging", imaging.options_body(source)))
        except OnvifFault:
            options = imaging.ImagingOptions()
        return source, state, options

    async def image(self, uuid: UUID) -> ImageRead:
        """Read a camera's imaging settings and the options it offers.

        Args:
            uuid: Public id of the camera.

        Returns:
            Imaging settings, or a result marked unsupported with the reason when the camera cannot be read.
        """
        camera = await self.get(uuid)
        try:
            connection = await self.device_connection(camera)
            source, state, options = await self.imaging_state(connection)
        except NotOffered as exc:
            return ImageRead(camera_uuid=camera.uuid, supported=False, reason=str(exc))
        except OnvifError as exc:
            return ImageRead(camera_uuid=camera.uuid, supported=False, reason=str(exc))
        return ImageRead(
            camera_uuid=camera.uuid,
            supported=True,
            source_token=source,
            settings=ImageSettings(
                brightness=state.brightness,
                contrast=state.contrast,
                saturation=state.saturation,
                sharpness=state.sharpness,
                ir_cut_filter=state.ir_cut_filter,
                wdr_mode=state.wdr_mode,
                wdr_level=state.wdr_level,
                backlight_mode=state.backlight_mode,
                backlight_level=state.backlight_level,
            ),
            options=ImageOptionsRead(
                levels={key: range_read(value) for key, value in options.levels.items()},
                ir_cut_filter_modes=list(options.ir_cut_filter_modes),
                wdr_modes=list(options.wdr_modes),
                wdr_level=range_read(options.wdr_level),
                backlight_modes=list(options.backlight_modes),
                backlight_level=range_read(options.backlight_level),
            ),
        )

    def validate_image(
        self, state: imaging.ImagingState, options: imaging.ImagingOptions, payload: ImageSettings
    ) -> imaging.ImagingState:
        """Check requested imaging changes against what the camera offers.

        A level change without its mode, or a mode change without its level, takes the missing half
        from the current state so that the camera receives a complete pair.

        Args:
            state: Current imaging settings.
            options: Options the camera offers.
            payload: Requested changes.

        Returns:
            The settings to write.

        Raises:
            Unprocessable: When nothing is requested, a setting is not offered or a value is outside the range offered.
        """
        values = payload.model_dump(exclude_unset=True, exclude_none=True)
        if not values:
            raise Unprocessable("nothing_to_change", "Give at least one setting")
        for key in imaging.LEVELS:
            if key in values:
                limits = options.levels.get(key)
                if limits is None and getattr(state, key) is None:
                    raise Unprocessable("not_supported", f"The camera does not offer {key}")
                if not within(values[key], limits):
                    raise Unprocessable(
                        "out_of_range", f"{key} must be between {limits.minimum:g} and {limits.maximum:g}"
                    )
        checks = (
            ("ir_cut_filter", options.ir_cut_filter_modes),
            ("wdr_mode", options.wdr_modes),
            ("backlight_mode", options.backlight_modes),
        )
        for key, allowed in checks:
            if key in values and allowed and values[key] not in allowed:
                raise Unprocessable("not_supported", f"{values[key]} is not offered for {key}")
        if "wdr_level" in values and not within(values["wdr_level"], options.wdr_level):
            raise Unprocessable("out_of_range", "The WDR level is outside the allowed range")
        if "backlight_level" in values and not within(values["backlight_level"], options.backlight_level):
            raise Unprocessable("out_of_range", "The backlight level is outside the allowed range")
        result = imaging.ImagingState(**{key: value for key, value in values.items()})
        if result.wdr_level is not None and result.wdr_mode is None:
            result = imaging.ImagingState(**{**result.__dict__, "wdr_mode": state.wdr_mode})
        if result.wdr_mode is not None and result.wdr_level is None and state.wdr_level is not None:
            result = imaging.ImagingState(**{**result.__dict__, "wdr_level": state.wdr_level})
        if result.backlight_level is not None and result.backlight_mode is None:
            result = imaging.ImagingState(**{**result.__dict__, "backlight_mode": state.backlight_mode})
        if result.backlight_mode is not None and result.backlight_level is None and state.backlight_level is not None:
            result = imaging.ImagingState(**{**result.__dict__, "backlight_level": state.backlight_level})
        return result

    async def update_image(self, uuid: UUID, payload: ImageSettings) -> ImageRead:
        """Change a camera's imaging settings.

        Args:
            uuid: Public id of the camera.
            payload: Requested changes.

        Returns:
            Imaging settings read after the change.

        Raises:
            Conflict: When the camera offers no imaging service.
            BadGateway: When the camera rejects or fails a request.
        """
        camera = await self.get(uuid)
        try:
            connection = await self.device_connection(camera)
            source, state, options = await self.imaging_state(connection)
        except NotOffered as exc:
            raise self.forbid(exc)
        except OnvifError as exc:
            raise self.gateway(exc)
        changes = self.validate_image(state, options, payload)
        try:
            await self.call(connection, "imaging", imaging.set_body(source, changes))
        except OnvifError as exc:
            raise self.gateway(exc)
        return await self.image(uuid)

    async def motion_setup(self, connection: Connection) -> analytics.MotionSetup:
        """Find a camera's motion detection module and rule.

        Each analytics configuration of the media profiles is tried until one carries a sensitivity or active cells.

        Args:
            connection: Connection to the camera.

        Returns:
            The motion setup found.

        Raises:
            NotOffered: When the camera has no analytics service or exposes no motion rule.
        """
        if not connection.address("analytics"):
            raise NotOffered("Motion detection is set in the vendor app: the camera offers no analytics service")
        tokens: list[str] = []
        for service in (media.MEDIA1, media.MEDIA2):
            if connection.address(service):
                try:
                    tokens = analytics.analytics_tokens(
                        await self.call(connection, service, media.profiles_body(service))
                    )
                except OnvifFault:
                    continue
                if tokens:
                    break
        for token in tokens:
            try:
                modules = await self.call(connection, "analytics", analytics.modules_body(token))
            except OnvifFault:
                modules = None
            try:
                rules = await self.call(connection, "analytics", analytics.rules_body(token))
            except OnvifFault:
                rules = None
            setup = analytics.parse_setup(token, modules, rules)
            if setup.sensitivity is not None or setup.active_cells is not None:
                return setup
        raise NotOffered("Motion detection is set in the vendor app: the camera exposes no motion rule")

    def motion_read(self, camera: Camera, setup: analytics.MotionSetup) -> MotionRead:
        """Convert a motion setup to its response schema.

        Detection counts as enabled when at least one cell is active.

        Args:
            camera: Camera the setup belongs to.
            setup: Motion setup read from the camera.

        Returns:
            The setup as a schema.
        """
        cells = setup.cells
        active = analytics.active_count(setup.active_cells, cells) if cells else None
        return MotionRead(
            camera_uuid=camera.uuid,
            supported=True,
            sensitivity=setup.sensitivity,
            sensitivity_range=SENSITIVITY_RANGE if setup.sensitivity is not None else None,
            enabled=None if active is None else active > 0,
            active_cells=active,
            cells=cells,
        )

    async def motion(self, uuid: UUID) -> MotionRead:
        """Read a camera's motion detection setup.

        Args:
            uuid: Public id of the camera.

        Returns:
            Motion setup, or a result marked unsupported with the reason when the camera cannot be read.
        """
        camera = await self.get(uuid)
        try:
            connection = await self.device_connection(camera)
            setup = await self.motion_setup(connection)
        except NotOffered as exc:
            return MotionRead(camera_uuid=camera.uuid, supported=False, reason=str(exc))
        except OnvifError as exc:
            return MotionRead(camera_uuid=camera.uuid, supported=False, reason=str(exc))
        return self.motion_read(camera, setup)

    async def write_sensitivity(self, connection: Connection, setup: analytics.MotionSetup, value: int) -> None:
        """Write a motion sensitivity into the camera's motion module.

        Args:
            connection: Connection to the camera.
            setup: Motion setup that holds the module to change.
            value: Sensitivity to write.
        """
        module = analytics.with_item(setup.module, analytics.SENSITIVITY, str(value))
        await self.call(connection, "analytics", analytics.modify_module_body(setup.configuration_token, module))

    async def update_motion(self, uuid: UUID, payload: MotionUpdate) -> MotionRead:
        """Change a camera's motion sensitivity or switch detection on or off.

        When the camera reads back a different sensitivity than was written, the value is written
        once more shifted by the difference, if that stays within 0 to 100. Switching detection off
        clears every active cell after remembering them for this process, and switching it on
        restores the remembered cells, or activates every cell when none are remembered.

        Args:
            uuid: Public id of the camera.
            payload: Requested changes.

        Returns:
            Motion setup read after the change.

        Raises:
            Conflict: When the camera offers no motion detection or does not expose the sensitivity or area to change.
            BadGateway: When the camera rejects or fails a request.
        """
        camera = await self.get(uuid)
        try:
            connection = await self.device_connection(camera)
            setup = await self.motion_setup(connection)
        except NotOffered as exc:
            raise self.forbid(exc)
        except OnvifError as exc:
            raise self.gateway(exc)
        try:
            if payload.sensitivity is not None:
                if setup.module is None or setup.sensitivity is None:
                    raise Conflict("not_supported", "The camera does not expose a motion sensitivity")
                await self.write_sensitivity(connection, setup, payload.sensitivity)
                reread = await self.motion_setup(connection)
                corrected = corrected_sensitivity(payload.sensitivity, reread.sensitivity)
                if corrected is not None:
                    await self.write_sensitivity(connection, reread, corrected)
            if payload.enabled is not None:
                setup = await self.motion_setup(connection)
                cells = setup.cells
                if setup.rule is None or setup.active_cells is None or not cells:
                    raise Conflict("not_supported", "The camera does not expose the motion area")
                current = analytics.active_count(setup.active_cells, cells) or 0
                if payload.enabled and current == 0:
                    value = remembered_cells.get(camera.uuid) or analytics.cells_value(cells, True)
                elif not payload.enabled and current > 0:
                    remembered_cells[camera.uuid] = setup.active_cells
                    value = analytics.cells_value(cells, False)
                else:
                    value = None
                if value is not None:
                    rule = analytics.with_item(setup.rule, analytics.ACTIVE_CELLS, value)
                    await self.call(
                        connection, "analytics", analytics.modify_rule_body(setup.configuration_token, rule)
                    )
        except OnvifError as exc:
            raise self.gateway(exc)
        return await self.motion(uuid)

    async def ptz_target(self, camera: Camera) -> PtzTarget:
        """Find the ONVIF endpoint and profile that serve a camera's PTZ presets.

        The camera's own device endpoint is tried first and the V380 bridge endpoint second.

        Args:
            camera: Camera to look up.

        Returns:
            The connection, PTZ profile token and PTZ node.

        Raises:
            NotOffered: When no endpoint offers PTZ with a profile and preset or home support.
        """
        endpoints = [endpoint for endpoint in (device_endpoint(camera), bridge_endpoint(camera)) if endpoint]
        reason = "The camera offers no PTZ presets"
        for endpoint in endpoints:
            try:
                connection = await self.open(endpoint)
            except NotOffered as exc:
                reason = str(exc)
                continue
            if not connection.address("ptz") or not connection.address(media.MEDIA1):
                continue
            try:
                profiles = await connection.client.profiles(connection.address(media.MEDIA1))
                node = ptz.parse_node(await self.call(connection, "ptz", ptz.nodes_body()))
            except OnvifError as exc:
                reason = str(exc)
                continue
            profile = next((item for item in profiles if item.ptz), None)
            if profile is None:
                continue
            if not node.max_presets and not node.home_supported:
                reason = "The PTZ service of this camera keeps no presets"
                continue
            return PtzTarget(connection=connection, profile_token=profile.token, node=node)
        raise NotOffered(reason)

    async def presets(self, uuid: UUID) -> PresetsRead:
        """List a camera's PTZ presets.

        Args:
            uuid: Public id of the camera.

        Returns:
            Presets, or a result marked unsupported with the reason when the camera has no PTZ or cannot be read.
        """
        camera = await self.get(uuid)
        if not camera.ptz_enabled:
            return PresetsRead(camera_uuid=camera.uuid, supported=False, reason="The camera has no PTZ")
        try:
            target = await self.ptz_target(camera)
            body = await self.call(target.connection, "ptz", ptz.presets_body(target.profile_token))
        except NotOffered as exc:
            return PresetsRead(camera_uuid=camera.uuid, supported=False, reason=str(exc))
        except OnvifError as exc:
            return PresetsRead(camera_uuid=camera.uuid, supported=False, reason=str(exc))
        return PresetsRead(
            camera_uuid=camera.uuid,
            supported=True,
            endpoint=target.connection.endpoint.label,
            presets=[PresetRead(token=item.token, name=item.name) for item in ptz.parse_presets(body)],
            max_presets=target.node.max_presets,
            home_supported=bool(target.node.home_supported),
        )

    async def ptz_action(self, uuid: UUID, build) -> None:
        """Send one PTZ command to a camera.

        The command is abandoned when the camera does not answer within PRESET_ACTION_TIMEOUT seconds.

        Args:
            uuid: Public id of the camera.
            build: Function that takes the PTZ target and returns the SOAP body to send.

        Raises:
            Conflict: When the camera offers no PTZ presets.
            BadGateway: When the camera rejects the command, fails it or does not answer in time.
        """
        camera = await self.get(uuid)
        try:
            target = await self.ptz_target(camera)
        except NotOffered as exc:
            raise self.forbid(exc)
        body = build(target)
        try:
            await asyncio.wait_for(self.call(target.connection, "ptz", body), PRESET_ACTION_TIMEOUT)
        except TimeoutError:
            raise BadGateway("onvif_error", "The camera did not answer the PTZ command in time")
        except OnvifError as exc:
            raise self.gateway(exc)

    async def create_preset(self, uuid: UUID, name: str) -> PresetsRead:
        """Save the camera's current position as a new PTZ preset.

        Args:
            uuid: Public id of the camera.
            name: Name of the preset.

        Returns:
            Presets read after the change.
        """
        await self.ptz_action(uuid, lambda target: ptz.set_preset_body(target.profile_token, name))
        return await self.presets(uuid)

    async def rename_preset(self, uuid: UUID, token: str, name: str) -> PresetsRead:
        """Rename a PTZ preset.

        Args:
            uuid: Public id of the camera.
            token: ONVIF token of the preset.
            name: New name of the preset.

        Returns:
            Presets read after the change.
        """
        await self.ptz_action(uuid, lambda target: ptz.set_preset_body(target.profile_token, name, token))
        return await self.presets(uuid)

    async def remove_preset(self, uuid: UUID, token: str) -> PresetsRead:
        """Delete a PTZ preset.

        Args:
            uuid: Public id of the camera.
            token: ONVIF token of the preset.

        Returns:
            Presets read after the change.
        """
        await self.ptz_action(uuid, lambda target: ptz.remove_preset_body(target.profile_token, token))
        return await self.presets(uuid)

    async def goto_preset(self, uuid: UUID, token: str) -> None:
        """Move a camera to a PTZ preset.

        Args:
            uuid: Public id of the camera.
            token: ONVIF token of the preset.
        """
        await self.ptz_action(uuid, lambda target: ptz.goto_preset_body(target.profile_token, token))

    async def goto_home(self, uuid: UUID) -> None:
        """Move a camera to its PTZ home position.

        Args:
            uuid: Public id of the camera.
        """
        await self.ptz_action(uuid, lambda target: ptz.goto_home_body(target.profile_token))

    async def set_home(self, uuid: UUID) -> None:
        """Store a camera's current position as its PTZ home position.

        Args:
            uuid: Public id of the camera.
        """
        await self.ptz_action(uuid, lambda target: ptz.set_home_body(target.profile_token))

    async def recording_list(self, connection: Connection) -> list[recordings.Recording]:
        """List the recordings a camera reports.

        Args:
            connection: Connection to the camera.

        Returns:
            The recordings, or an empty list when the camera offers no recording service or answers a fault.
        """
        if connection.address("recording"):
            try:
                return recordings.parse_recordings(await self.call(connection, "recording", recordings.RECORDINGS))
            except OnvifFault:
                return []
        return []

    async def track_changes(
        self, connection: Connection, recording: str, start: datetime, end: datetime
    ) -> list[recordings.TrackChange]:
        """Search a recording for the times its tracks start and stop recording.

        Result pages are read for at most SEARCH_ROUNDS rounds or until the camera reports the search completed, and the
        search is always ended afterwards.

        Args:
            connection: Connection to the camera.
            recording: Token of the recording to search.
            start: Start of the time range.
            end: End of the time range.

        Returns:
            The track changes found, or an empty list when the camera starts no search.
        """
        body = await self.call(connection, "search", recordings.find_events_body(recording, start, end))
        token = recordings.parse_search_token(body)
        if not token:
            return []
        changes: list[recordings.TrackChange] = []
        try:
            for _ in range(SEARCH_ROUNDS):
                page = recordings.parse_event_page(
                    await self.call(connection, "search", recordings.event_results_body(token))
                )
                changes.extend(page.changes)
                if (page.state or "").lower() == "completed":
                    break
        finally:
            try:
                await self.call(connection, "search", recordings.end_search_body(token))
            except OnvifError:
                pass
        return changes

    async def recordings(self, uuid: UUID, start: datetime | None, end: datetime | None) -> RecordingsRead:
        """Summarise a camera's SD card recordings and list the recorded segments in a time range.

        Segments are searched only when both ends of the range are given and the camera reports recordings.

        Args:
            uuid: Public id of the camera.
            start: Start of the range, if any.
            end: End of the range, if any.

        Returns:
            Recording summary and segments. When the camera cannot be read the result is marked unsupported with the
            reason; when only the segment search fails the summary is kept and the reason is set.

        Raises:
            Unprocessable: When the range ends before it starts or is longer than two days.
        """
        camera = await self.get(uuid)
        if start is not None and end is not None and end <= start:
            raise Unprocessable("invalid_range", "The end of the range must come after its start")
        if start is not None and end is not None and end - start > timedelta(days=2):
            raise Unprocessable("invalid_range", "Ask for at most two days at a time")
        try:
            connection = await self.device_connection(camera)
            if not connection.address("search"):
                raise NotOffered("The camera offers no recording search")
            summary = recordings.parse_summary(await self.call(connection, "search", recordings.SUMMARY))
        except NotOffered as exc:
            return RecordingsRead(camera_uuid=camera.uuid, supported=False, reason=str(exc))
        except OnvifError as exc:
            return RecordingsRead(camera_uuid=camera.uuid, supported=False, reason=str(exc))
        result = RecordingsRead(
            camera_uuid=camera.uuid,
            supported=True,
            playback=settings.replay_enabled and bool(connection.address("replay")),
            playback_reason=None if settings.replay_enabled else REPLAY_OFF,
            recordings=summary.count,
            data_from=summary.data_from,
            data_until=summary.data_until,
            start=start,
            end=end,
        )
        if not summary.count or start is None or end is None:
            return result
        limit = min(end, datetime.now(UTC))
        segments: list[SegmentRead] = []
        try:
            for recording in await self.recording_list(connection):
                changes = await self.track_changes(connection, recording.token, start, end)
                for begin, finish in recordings.segments(changes, start, limit, recording.video_tracks):
                    segments.append(SegmentRead(start=begin, end=finish))
        except OnvifError as exc:
            return RecordingsRead(**{**result.model_dump(), "supported": True, "reason": str(exc)})
        return RecordingsRead(**{**result.model_dump(), "segments": segments})

    async def start_replay(self, uuid: UUID, start: datetime, session: str | None) -> ReplayRead:
        """Start SD card playback from a point in time.

        The replay address the camera gives is completed with the camera's credentials and the start time before it is
        handed to the playback registry.

        Args:
            uuid: Public id of the camera.
            start: Time to play from.
            session: Id of the client's playback session, if it has one.

        Returns:
            The playback session that was opened.

        Raises:
            Conflict: When playback is switched off, the camera offers no replay or recordings, or
                another session holds the camera.
            Unprocessable: When the start time is in the future.
            BadGateway: When the camera rejects a request or gives no replay address, or go2rtc
                fails to open the stream.
        """
        camera = await self.get(uuid)
        if not settings.replay_enabled:
            raise Conflict("not_supported", REPLAY_OFF)
        if start > datetime.now(UTC):
            raise Unprocessable("invalid_start", "Pick a time in the past")
        try:
            connection = await self.device_connection(camera)
            if not connection.address("replay"):
                raise NotOffered("The camera offers no replay service")
            listed = await self.recording_list(connection)
            if not listed:
                raise NotOffered("The camera has no recordings")
            body = await self.call(connection, "replay", recordings.replay_uri_body(listed[0].token))
        except NotOffered as exc:
            raise self.forbid(exc)
        except OnvifError as exc:
            raise self.gateway(exc)
        uri = text(descendant(body, "Uri"))
        if not uri:
            raise BadGateway("onvif_error", "The camera gave no replay address")
        endpoint = connection.endpoint
        url = with_start(with_credentials(uri, endpoint.username, endpoint.password), start)
        try:
            replay = await self.replays.open(camera.uuid, url, start, session)
        except ReplayBusy as exc:
            raise Conflict("replay_busy", str(exc))
        except Go2rtcError as exc:
            raise BadGateway("go2rtc_error", str(exc))
        return ReplayRead(active=True, session=replay.id, stream=replay.name, start=replay.start)

    async def replay_status(self, uuid: UUID) -> ReplayRead:
        """Read the state of a camera's playback session.

        Args:
            uuid: Public id of the camera.

        Returns:
            Whether a session is active, with its id, stream, start time and the failure of the last session.
        """
        camera = await self.get(uuid)
        status = self.replays.status(camera.uuid)
        return ReplayRead(
            active=status.active,
            session=status.session,
            stream=status.stream,
            start=status.start,
            failure=status.failure,
        )

    async def stop_replay(self, uuid: UUID, session: str | None) -> None:
        """Stop a camera's playback session.

        Args:
            uuid: Public id of the camera.
            session: Id of the session to stop; when given, a different current session is left running.
        """
        camera = await self.get(uuid)
        await self.replays.close(camera.uuid, session)

    async def extras(self, uuid: UUID) -> ExtrasRead:
        """Report whether a camera has a light and siren behind a V380 bridge.

        Args:
            uuid: Public id of the camera.

        Returns:
            Light and siren availability, or a result marked unsupported with the reason when the
            camera has no bridge or the bridge API is not enabled.
        """
        camera = await self.get(uuid)
        if not camera.device_host:
            return ExtrasRead(
                camera_uuid=camera.uuid, supported=False, reason="Light and siren come from a V380 bridge"
            )
        if not await BridgeClient(camera.host).available():
            return ExtrasRead(camera_uuid=camera.uuid, supported=False, reason="The bridge API is not enabled")
        return ExtrasRead(camera_uuid=camera.uuid, supported=True, light=True, siren=True)

    async def bridge(self, uuid: UUID) -> BridgeClient:
        """Build a client for a camera's V380 bridge.

        Args:
            uuid: Public id of the camera.

        Returns:
            Client for the bridge API.

        Raises:
            Conflict: When the camera is not behind a V380 bridge.
        """
        camera = await self.get(uuid)
        if not camera.device_host:
            raise Conflict("not_supported", "Light and siren come from a V380 bridge")
        return BridgeClient(camera.host)

    async def light(self, uuid: UUID, mode: str) -> None:
        """Set the light mode through the V380 bridge.

        Args:
            uuid: Public id of the camera.
            mode: Light mode, one of on, off or auto.

        Raises:
            BadGateway: When the bridge rejects or fails the request.
        """
        client = await self.bridge(uuid)
        try:
            await client.light(mode)
        except BridgeError as exc:
            raise BadGateway("bridge_error", str(exc))

    async def siren(self, uuid: UUID, seconds: int) -> None:
        """Sound or silence the siren through the V380 bridge.

        Args:
            uuid: Public id of the camera.
            seconds: How long to sound the siren; 0 turns it off.

        Raises:
            BadGateway: When the bridge rejects or fails the request.
        """
        client = await self.bridge(uuid)
        try:
            await client.siren(seconds)
        except BridgeError as exc:
            raise BadGateway("bridge_error", str(exc))

    async def audio(self, uuid: UUID) -> AudioRead:
        """Report whether a camera stream carries audio the browser player can play.

        Only AAC and Opus encodings are accepted; the first encoding listed in the media profiles that is one of them
        decides the codec.

        Args:
            uuid: Public id of the camera.

        Returns:
            Audio support with the codec, or a result marked unsupported with the reason.
        """
        camera = await self.get(uuid)
        if camera.device_host:
            return AudioRead(camera_uuid=camera.uuid, supported=False, reason="The V380 bridge carries no sound")
        try:
            connection = await self.device_connection(camera)
            body = await self.call(connection, media.MEDIA1, media.profiles_body(media.MEDIA1))
        except NotOffered as exc:
            return AudioRead(camera_uuid=camera.uuid, supported=False, reason=str(exc))
        except OnvifError as exc:
            return AudioRead(camera_uuid=camera.uuid, supported=False, reason=str(exc))
        encodings = [text(descendant(item, "Encoding")) for item in descendants(body, "AudioEncoderConfiguration")]
        encodings = [item.upper() for item in encodings if item]
        for encoding in encodings:
            if encoding in AUDIO_CODECS:
                return AudioRead(camera_uuid=camera.uuid, supported=True, codec=AUDIO_CODECS[encoding])
        if encodings:
            return AudioRead(
                camera_uuid=camera.uuid,
                supported=False,
                reason=f"The camera sends {encodings[0]} audio, which the browser player cannot play",
            )
        return AudioRead(camera_uuid=camera.uuid, supported=False, reason="The camera stream has no sound")
