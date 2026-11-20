"""Schemas of the pairing method catalog, label reading, identification, device creation and telemetry."""

from datetime import datetime
from enum import StrEnum
from uuid import UUID

from pydantic import BaseModel, Field, model_validator

from app.modules.devices.schemas.capabilities import CapabilitiesRead

__all__ = [
    "AttemptOutcome",
    "ChannelRead",
    "IdentifyRequest",
    "IdentifyResult",
    "LabelRead",
    "LabelRequest",
    "MethodStats",
    "PairingAttemptCreate",
    "PairingAttemptRead",
    "PairingDeviceCreate",
    "PairingMethod",
    "PairingMethodId",
    "PairingMethodList",
    "PairingParameter",
    "PairingStats",
    "StatCount",
]


class PairingMethodId(StrEnum):
    """Ways to add a camera, a recorder or a connector."""

    CONNECTOR_DISCOVERY = "connector_discovery"
    MANUAL_HOST = "manual_host"
    RTSP_URL = "rtsp_url"
    LABEL_QR = "label_qr"
    NVR_IMPORT = "nvr_import"
    CONNECTOR_CODE = "connector_code"
    CONNECTOR_QR = "connector_qr"
    CONNECTOR_MDNS = "connector_mdns"


class AttemptOutcome(StrEnum):
    """Outcome of a pairing attempt."""

    STARTED = "started"
    SUCCEEDED = "succeeded"
    FAILED = "failed"
    ABANDONED = "abandoned"


class PairingParameter(BaseModel):
    """A value a pairing method asks for.

    Attributes:
        name: Field name, as the method's request carries it.
        type: string, integer, password, uuid, url, qr or list.
        required: Whether the method needs it.
        description: What it is.
        default: Value used when it is omitted.
        prefill: Value read from the context, such as a scanned label.
    """

    name: str
    type: str
    required: bool
    description: str
    default: str | int | None = None
    prefill: str | int | None = None


class PairingMethod(BaseModel):
    """A pairing method that works for the request's site and context.

    Attributes:
        id: Method id.
        title: Name shown to people.
        description: What the method does.
        requires: What it needs, such as admin, connector, direct, camera_app or same_wifi.
        parameters: Values it asks for.
        endpoint: API operation that carries it out.
        adapter: Adapter the context points to, if any.
        recommended: Whether it is the best method for the context.
    """

    id: PairingMethodId
    title: str
    description: str
    requires: list[str]
    parameters: list[PairingParameter]
    endpoint: str
    adapter: str | None = None
    recommended: bool = False


class PairingMethodList(BaseModel):
    """The pairing methods that work now, best first.

    Attributes:
        items: The methods.
        connectors: Paired connectors of the site that are online.
        direct: Whether the backend may reach cameras itself.
    """

    items: list[PairingMethod]
    connectors: list[UUID]
    direct: bool


class LabelRequest(BaseModel):
    """A label QR code a member scanned.

    Attributes:
        payload: The decoded QR text.
    """

    payload: str = Field(min_length=1, max_length=2048)


class LabelRead(BaseModel):
    """What a label says.

    Attributes:
        adapter: Adapter the label belongs to.
        format: Label format that matched.
        confirmed: Whether the format follows a published standard; other formats are tolerant guesses.
        kind: camera, nvr or dvr.
        vendor: Vendor.
        model: Model.
        serial: Serial number.
        code: Verification or claim code printed with it.
        device_id: Device id, such as a V380 id.
        host: Address, when the label carries one.
        port: Port, when the label carries one.
        url: Stream or service address, when the label carries one.
        methods: Pairing methods that can continue from the label, best first.
    """

    adapter: str
    format: str
    confirmed: bool
    kind: str
    vendor: str | None
    model: str | None
    serial: str | None
    code: str | None
    device_id: str | None
    host: str | None
    port: int | None
    url: str | None
    methods: list[PairingMethodId]


class IdentifyRequest(BaseModel):
    """A device to identify, by address or stream address.

    Attributes:
        host: Address on the site's network.
        port: Control port, such as the ONVIF port; the adapter's usual one when omitted.
        rtsp_port: RTSP port.
        username: Login.
        password: Password; it is not stored by the identification.
        adapter: Adapter to use, when known; otherwise the registry picks one.
        rtsp_url: Full stream address, for a plain RTSP camera.
        device_id: Device id, for a V380 camera.
        connector: Connector that reaches the device; the backend reaches it itself when omitted and allowed.
    """

    host: str | None = Field(default=None, min_length=1, max_length=255)
    port: int | None = Field(default=None, ge=1, le=65535)
    rtsp_port: int | None = Field(default=None, ge=1, le=65535)
    username: str | None = Field(default=None, max_length=100)
    password: str | None = Field(default=None, max_length=256)
    adapter: str | None = Field(default=None, max_length=40)
    rtsp_url: str | None = Field(default=None, max_length=1024)
    device_id: str | None = Field(default=None, max_length=40)
    connector: UUID | None = None

    @model_validator(mode="after")
    def needs_an_address(self):
        """Require a host or a stream address.

        Returns:
            The validated request.

        Raises:
            ValueError: Neither is given.
        """
        if not self.host and not self.rtsp_url:
            raise ValueError("give the host or the stream address")
        return self


class ChannelRead(BaseModel):
    """A video channel an adapter found.

    Attributes:
        index: Channel number from 1.
        name: Name the device gives it.
        main_path: Main stream path.
        sub_path: Sub stream path.
        width: Width of the main stream.
        height: Height of the main stream.
        encoding: Codec of the main stream.
        ptz: Whether it can be moved.
    """

    index: int
    name: str
    main_path: str | None
    sub_path: str | None
    width: int | None
    height: int | None
    encoding: str | None
    ptz: bool


class IdentifyResult(BaseModel):
    """What an adapter learned about a device.

    Attributes:
        adapter: Adapter that identified it.
        kind: camera, nvr or dvr.
        vendor: Manufacturer.
        model: Model.
        rtsp_port: RTSP port of its streams.
        channels: Its video channels.
        capabilities: Its capability manifest.
        attempt: Pairing attempt the identification belongs to, to pass on to device creation.
    """

    adapter: str
    kind: str
    vendor: str | None
    model: str | None
    rtsp_port: int | None
    channels: list[ChannelRead]
    capabilities: CapabilitiesRead
    attempt: UUID


class PairingDeviceCreate(IdentifyRequest):
    """Request to add a device and some of its channels as cameras.

    Attributes:
        method: Pairing method the member used.
        name: Name of the device; channels are named after it.
        channels: Channels to add; every channel of a camera when omitted, at least one of a recorder.
        discovered: Discovered camera the device comes from, if any.
        attempt: Pairing attempt that identified the device, if any.
    """

    method: PairingMethodId = PairingMethodId.MANUAL_HOST
    name: str = Field(min_length=1, max_length=100)
    channels: list[int] | None = Field(default=None, max_length=64)
    discovered: UUID | None = None
    attempt: UUID | None = None


class PairingAttemptCreate(BaseModel):
    """A pairing step the app reports itself, such as a scan the member abandoned.

    Attributes:
        method: Pairing method.
        adapter: Adapter involved, if known.
        last_step: Last step reached.
        outcome: started, succeeded, failed or abandoned.
        error_code: Stable error code of a failure.
        duration_ms: Time from start to the outcome.
    """

    method: PairingMethodId
    adapter: str | None = Field(default=None, max_length=20)
    last_step: str = Field(min_length=1, max_length=30, pattern=r"^[a-z_]+$")
    outcome: AttemptOutcome
    error_code: str | None = Field(default=None, max_length=40, pattern=r"^[a-z_]+$")
    duration_ms: int = Field(default=0, ge=0, le=86_400_000)


class PairingAttemptRead(BaseModel):
    """A recorded pairing attempt.

    Attributes:
        uuid: Public id.
        method: Pairing method.
        adapter: Adapter involved.
        last_step: Last step reached.
        outcome: Outcome.
        error_code: Error code of a failure.
        duration_ms: Duration.
        created_at: When it started.
    """

    uuid: UUID
    method: PairingMethodId
    adapter: str | None
    last_step: str
    outcome: AttemptOutcome
    error_code: str | None
    duration_ms: int
    created_at: datetime


class StatCount(BaseModel):
    """A value and how often it occurred.

    Attributes:
        value: The value, such as an error code or a step.
        count: Occurrences.
    """

    value: str
    count: int


class MethodStats(BaseModel):
    """How one pairing method fares.

    Attributes:
        method: Pairing method.
        attempts: Finished attempts.
        succeeded: Attempts that succeeded.
        failed: Attempts that failed.
        abandoned: Attempts the member abandoned.
        success_rate: Succeeded over finished attempts, from 0 to 1.
        median_duration_ms: Median duration of the finished attempts.
        errors: Most frequent error codes.
        stopped_at: Steps where unsuccessful attempts stopped.
    """

    method: PairingMethodId
    attempts: int
    succeeded: int
    failed: int
    abandoned: int
    success_rate: float
    median_duration_ms: int | None
    errors: list[StatCount]
    stopped_at: list[StatCount]


class PairingStats(BaseModel):
    """Success of the pairing methods over a period.

    Attributes:
        since: Start of the period.
        methods: Stats per method, most attempted first.
    """

    since: datetime
    methods: list[MethodStats]
