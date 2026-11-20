"""Video encoder and media profile requests and parsers for the ONVIF media services."""

from dataclasses import dataclass, field, replace
from xml.etree.ElementTree import Element
from xml.sax.saxutils import escape

from adapters.onvif.soap import child, children, descendants, text

MEDIA2 = "media2"
MEDIA1 = "media"


@dataclass(frozen=True)
class Range:
    """A numeric range.

    Attributes:
        minimum: Lower bound.
        maximum: Upper bound.
    """

    minimum: float
    maximum: float


@dataclass(frozen=True)
class Multicast:
    """Multicast settings of a video encoder.

    Attributes:
        kind: Address type, such as IPv4.
        address: Multicast address.
        port: Multicast port.
        ttl: Multicast time to live.
        auto_start: Whether multicast starts automatically.
    """

    kind: str = "IPv4"
    address: str = "0.0.0.0"
    port: int = 0
    ttl: int = 0
    auto_start: bool = False


@dataclass(frozen=True)
class Encoder:
    """A video encoder configuration.

    Attributes:
        token: Configuration token.
        name: Configuration name, the token when the device gives none.
        use_count: Number of profiles using the configuration.
        encoding: Video encoding, such as H264.
        width: Video width in pixels.
        height: Video height in pixels.
        fps: Frame rate limit.
        bitrate: Bitrate limit.
        gop: Group of pictures length.
        quality: Encoder quality.
        profile: Encoding profile name, such as Main.
        service: Media service the configuration belongs to, media or media2.
        constant_bitrate: Whether the bitrate is constant, only reported by media2.
        encoding_interval: Rate control encoding interval, only reported by media.
        session_timeout: Session timeout duration, only reported by media.
        multicast: Multicast settings.
    """

    token: str
    name: str
    use_count: int
    encoding: str | None
    width: int | None
    height: int | None
    fps: float | None
    bitrate: int | None
    gop: int | None
    quality: float | None
    profile: str | None
    service: str
    constant_bitrate: bool | None = None
    encoding_interval: int | None = None
    session_timeout: str | None = None
    multicast: Multicast = field(default_factory=Multicast)


@dataclass(frozen=True)
class EncodingOptions:
    """What a video encoder accepts for one encoding.

    Attributes:
        encoding: Video encoding the options belong to.
        resolutions: Available resolutions as width and height.
        fps_values: Supported frame rates, when the device lists them.
        fps_range: Supported frame rate range, when the device gives a range.
        bitrate: Bitrate range.
        gop: Group of pictures length range.
        quality: Quality range.
        profiles: Supported encoding profiles.
    """

    encoding: str
    resolutions: tuple[tuple[int, int], ...]
    fps_values: tuple[float, ...] = ()
    fps_range: Range | None = None
    bitrate: Range | None = None
    gop: Range | None = None
    quality: Range | None = None
    profiles: tuple[str, ...] = ()


@dataclass(frozen=True)
class StreamProfile:
    """A media profile and the configurations it uses.

    Attributes:
        token: Profile token.
        name: Profile name, the token when the device gives none.
        encoder_token: Token of the video encoder configuration.
        source_token: Token of the video source.
    """

    token: str
    name: str
    encoder_token: str | None
    source_token: str | None


def number(value: str | None) -> float | None:
    """Convert text to a number.

    Args:
        value: Text to convert, or None.

    Returns:
        The number, or None when the text is missing or not a number.
    """
    if value is None:
        return None
    try:
        return float(value)
    except ValueError:
        return None


def whole(value: str | None) -> int | None:
    """Convert text to a whole number, rounding a fractional value.

    Args:
        value: Text to convert, or None.

    Returns:
        The rounded integer, or None when the text is missing or not a number.
    """
    result = number(value)
    return None if result is None else int(round(result))


def value_range(element: Element | None) -> Range | None:
    """Read a range from an element with Min and Max children.

    Args:
        element: Element to read, or None.

    Returns:
        The range, or None when the element or either bound is missing.
    """
    if element is None:
        return None
    low = number(text(child(element, "Min")))
    high = number(text(child(element, "Max")))
    if low is None or high is None:
        return None
    return Range(low, high)


def attribute_range(value: str | None) -> Range | None:
    """Read a range from an attribute holding two numbers separated by whitespace.

    Args:
        value: Attribute text, or None.

    Returns:
        The range, or None when the text is not exactly two numbers.
    """
    parts = (value or "").split()
    if len(parts) != 2:
        return None
    low, high = number(parts[0]), number(parts[1])
    if low is None or high is None:
        return None
    return Range(low, high)


def resolutions(element: Element | None) -> tuple[tuple[int, int], ...]:
    """Read the available resolutions of an options element.

    Args:
        element: Element holding ResolutionsAvailable children, or None.

    Returns:
        The distinct width and height pairs with both values set, in document order.
    """
    found = []
    for item in children(element, "ResolutionsAvailable"):
        width = whole(text(child(item, "Width")))
        height = whole(text(child(item, "Height")))
        if width and height and (width, height) not in found:
            found.append((width, height))
    return tuple(found)


def parse_multicast(element: Element | None) -> Multicast:
    """Read multicast settings from a Multicast element.

    Args:
        element: Multicast element, or None.

    Returns:
        The settings, with defaults for missing parts and for a missing element.
    """
    if element is None:
        return Multicast()
    address = child(element, "Address")
    return Multicast(
        kind=text(child(address, "Type")) or "IPv4",
        address=text(child(address, "IPv4Address")) or "0.0.0.0",
        port=whole(text(child(element, "Port"))) or 0,
        ttl=whole(text(child(element, "TTL"))) or 0,
        auto_start=(text(child(element, "AutoStart")) or "false").lower() == "true",
    )


def parse_profiles(body: Element, service: str) -> list[StreamProfile]:
    """Read the media profiles from a GetProfiles response.

    Args:
        body: SOAP body of the response.
        service: Media service that answered, media or media2, which decides where the configurations are.

    Returns:
        The profiles that carry a token.
    """
    result = []
    for element in descendants(body, "Profiles"):
        token = element.get("token")
        if not token:
            continue
        if service == MEDIA2:
            configurations = child(element, "Configurations")
            encoder = child(configurations, "VideoEncoder")
            source = child(configurations, "VideoSource")
        else:
            encoder = child(element, "VideoEncoderConfiguration")
            source = child(element, "VideoSourceConfiguration")
        result.append(
            StreamProfile(
                token=token,
                name=text(child(element, "Name")) or token,
                encoder_token=encoder.get("token") if encoder is not None else None,
                source_token=text(child(source, "SourceToken")),
            )
        )
    return result


def parse_encoder(element: Element, service: str) -> Encoder | None:
    """Read one video encoder configuration.

    Args:
        element: Configuration element.
        service: Media service that answered, media or media2, which decides where the settings are.

    Returns:
        The encoder, or None when the element has no token.
    """
    token = element.get("token")
    if not token:
        return None
    resolution = child(element, "Resolution")
    rate = child(element, "RateControl")
    if service == MEDIA2:
        gop = whole(element.get("GovLength"))
        profile = element.get("Profile")
        constant = rate.get("ConstantBitRate") if rate is not None else None
        interval = None
    else:
        h264 = child(element, "H264")
        gop = whole(text(child(h264, "GovLength")))
        profile = text(child(h264, "H264Profile"))
        constant = None
        interval = whole(text(child(rate, "EncodingInterval")))
    return Encoder(
        token=token,
        name=text(child(element, "Name")) or token,
        use_count=whole(text(child(element, "UseCount"))) or 1,
        encoding=text(child(element, "Encoding")),
        width=whole(text(child(resolution, "Width"))),
        height=whole(text(child(resolution, "Height"))),
        fps=number(text(child(rate, "FrameRateLimit"))),
        bitrate=whole(text(child(rate, "BitrateLimit"))),
        gop=gop,
        quality=number(text(child(element, "Quality"))),
        profile=profile,
        service=service,
        constant_bitrate=None if constant is None else constant.lower() == "true",
        encoding_interval=interval,
        session_timeout=text(child(element, "SessionTimeout")),
        multicast=parse_multicast(child(element, "Multicast")),
    )


def parse_encoders(body: Element, service: str) -> list[Encoder]:
    """Read the video encoder configurations from a response.

    Args:
        body: SOAP body of the response.
        service: Media service that answered, media or media2.

    Returns:
        The encoders that carry a token.
    """
    result = []
    for element in descendants(body, "Configurations"):
        encoder = parse_encoder(element, service)
        if encoder is not None:
            result.append(encoder)
    return result


def parse_media2_options(body: Element) -> list[EncodingOptions]:
    """Read the encoder options from a media2 GetVideoEncoderConfigurationOptions response.

    Args:
        body: SOAP body of the response.

    Returns:
        One entry for each option set that names an encoding.
    """
    result = []
    for element in descendants(body, "Options"):
        encoding = text(child(element, "Encoding"))
        if not encoding:
            continue
        rates = tuple(
            value for value in (number(part) for part in (element.get("FrameRatesSupported") or "").split()) if value
        )
        result.append(
            EncodingOptions(
                encoding=encoding,
                resolutions=resolutions(element),
                fps_values=tuple(sorted(set(rates))),
                bitrate=value_range(child(element, "BitrateRange")),
                gop=attribute_range(element.get("GovLengthRange")),
                quality=value_range(child(element, "QualityRange")),
                profiles=tuple((element.get("ProfilesSupported") or "").split()),
            )
        )
    return result


def parse_media1_options(body: Element) -> list[EncodingOptions]:
    """Read the encoder options from a media GetVideoEncoderConfigurationOptions response.

    Args:
        body: SOAP body of the response.

    Returns:
        One entry for each of H264, MPEG4 and JPEG that the response lists, empty when it has no options.
    """
    options = next(iter(descendants(body, "Options")), None)
    if options is None:
        return []
    quality = value_range(child(options, "QualityRange"))
    extension = child(options, "Extension")
    result = []
    for name, encoding, profile_name in (
        ("H264", "H264", "H264ProfilesSupported"),
        ("MPEG4", "MPEG4", "Mpeg4ProfilesSupported"),
        ("JPEG", "JPEG", ""),
    ):
        element = child(options, name)
        if element is None:
            continue
        extended = child(extension, name)
        result.append(
            EncodingOptions(
                encoding=encoding,
                resolutions=resolutions(element),
                fps_range=value_range(child(element, "FrameRateRange")),
                bitrate=value_range(child(extended, "BitrateRange")),
                gop=value_range(child(element, "GovLengthRange")),
                quality=quality,
                profiles=tuple(text(item) for item in children(element, profile_name) if text(item))
                if profile_name
                else (),
            )
        )
    return result


def changed(encoder: Encoder, **values) -> Encoder:
    """Copy an encoder with some fields replaced.

    Args:
        encoder: Encoder to copy.
        **values: Field values to set, fields given as None are left unchanged.

    Returns:
        The updated copy.
    """
    return replace(encoder, **{key: value for key, value in values.items() if value is not None})


def format_number(value: float | None) -> str:
    """Format a number for XML.

    Args:
        value: Number to format, or None.

    Returns:
        An integer without decimals for whole values, otherwise up to six decimals, and "0" for None.
    """
    if value is None:
        return "0"
    if float(value).is_integer():
        return str(int(value))
    return f"{value:.6f}".rstrip("0")


def multicast_xml(multicast: Multicast) -> str:
    """Build the Multicast XML of an encoder configuration.

    Args:
        multicast: Multicast settings.

    Returns:
        The XML element.
    """
    return (
        "<tt:Multicast><tt:Address>"
        f"<tt:Type>{escape(multicast.kind)}</tt:Type><tt:IPv4Address>{escape(multicast.address)}</tt:IPv4Address>"
        f"</tt:Address><tt:Port>{multicast.port}</tt:Port><tt:TTL>{multicast.ttl}</tt:TTL>"
        f"<tt:AutoStart>{'true' if multicast.auto_start else 'false'}</tt:AutoStart></tt:Multicast>"
    )


def media2_set_body(encoder: Encoder) -> str:
    """Build a media2 SetVideoEncoderConfiguration request.

    Args:
        encoder: Encoder configuration to write.

    Returns:
        The XML of the request body.
    """
    attributes = [f'token="{escape(encoder.token)}"']
    if encoder.gop is not None:
        attributes.append(f'GovLength="{encoder.gop}"')
    if encoder.profile:
        attributes.append(f'Profile="{escape(encoder.profile)}"')
    constant = ""
    if encoder.constant_bitrate is not None:
        constant = f' ConstantBitRate="{"true" if encoder.constant_bitrate else "false"}"'
    return (
        f"<tr2:SetVideoEncoderConfiguration><tr2:Configuration {' '.join(attributes)}>"
        f"<tt:Name>{escape(encoder.name)}</tt:Name><tt:UseCount>{encoder.use_count}</tt:UseCount>"
        f"<tt:Encoding>{escape(encoder.encoding or '')}</tt:Encoding>"
        f"<tt:Resolution><tt:Width>{encoder.width}</tt:Width><tt:Height>{encoder.height}</tt:Height></tt:Resolution>"
        f"<tt:RateControl{constant}><tt:FrameRateLimit>{format_number(encoder.fps)}</tt:FrameRateLimit>"
        f"<tt:BitrateLimit>{encoder.bitrate or 0}</tt:BitrateLimit></tt:RateControl>"
        f"{multicast_xml(encoder.multicast)}"
        f"<tt:Quality>{format_number(encoder.quality)}</tt:Quality>"
        "</tr2:Configuration></tr2:SetVideoEncoderConfiguration>"
    )


def media1_set_body(encoder: Encoder) -> str:
    """Build a media SetVideoEncoderConfiguration request that is persisted on the device.

    The H264 block is included only for H264 encoders.

    Args:
        encoder: Encoder configuration to write.

    Returns:
        The XML of the request body.
    """
    h264 = ""
    if (encoder.encoding or "").upper() == "H264":
        h264 = (
            f"<tt:H264><tt:GovLength>{encoder.gop or 0}</tt:GovLength>"
            f"<tt:H264Profile>{escape(encoder.profile or 'Main')}</tt:H264Profile></tt:H264>"
        )
    return (
        f'<trt:SetVideoEncoderConfiguration><trt:Configuration token="{escape(encoder.token)}">'
        f"<tt:Name>{escape(encoder.name)}</tt:Name><tt:UseCount>{encoder.use_count}</tt:UseCount>"
        f"<tt:Encoding>{escape(encoder.encoding or '')}</tt:Encoding>"
        f"<tt:Resolution><tt:Width>{encoder.width}</tt:Width><tt:Height>{encoder.height}</tt:Height></tt:Resolution>"
        f"<tt:Quality>{format_number(encoder.quality)}</tt:Quality>"
        f"<tt:RateControl><tt:FrameRateLimit>{format_number(encoder.fps)}</tt:FrameRateLimit>"
        f"<tt:EncodingInterval>{encoder.encoding_interval or 1}</tt:EncodingInterval>"
        f"<tt:BitrateLimit>{encoder.bitrate or 0}</tt:BitrateLimit></tt:RateControl>"
        f"{h264}{multicast_xml(encoder.multicast)}"
        f"<tt:SessionTimeout>{escape(encoder.session_timeout or 'PT60S')}</tt:SessionTimeout>"
        "</trt:Configuration><trt:ForcePersistence>true</trt:ForcePersistence></trt:SetVideoEncoderConfiguration>"
    )


def set_body(encoder: Encoder) -> str:
    """Build the SetVideoEncoderConfiguration request for the encoder's media service.

    Args:
        encoder: Encoder configuration to write.

    Returns:
        The XML of the request body.
    """
    return media2_set_body(encoder) if encoder.service == MEDIA2 else media1_set_body(encoder)


def options_body(encoder: Encoder) -> str:
    """Build the GetVideoEncoderConfigurationOptions request for the encoder's media service.

    Args:
        encoder: Encoder whose options are requested.

    Returns:
        The XML of the request body.
    """
    token = escape(encoder.token)
    if encoder.service == MEDIA2:
        return (
            "<tr2:GetVideoEncoderConfigurationOptions>"
            f"<tr2:ConfigurationToken>{token}</tr2:ConfigurationToken></tr2:GetVideoEncoderConfigurationOptions>"
        )
    return (
        "<trt:GetVideoEncoderConfigurationOptions>"
        f"<trt:ConfigurationToken>{token}</trt:ConfigurationToken></trt:GetVideoEncoderConfigurationOptions>"
    )


def profiles_body(service: str) -> str:
    """Build the GetProfiles request for a media service.

    Args:
        service: Media service, media or media2.

    Returns:
        The XML of the request body.
    """
    if service == MEDIA2:
        return "<tr2:GetProfiles><tr2:Type>All</tr2:Type></tr2:GetProfiles>"
    return "<trt:GetProfiles/>"


def encoders_body(service: str) -> str:
    """Build the GetVideoEncoderConfigurations request for a media service.

    Args:
        service: Media service, media or media2.

    Returns:
        The XML of the request body.
    """
    if service == MEDIA2:
        return "<tr2:GetVideoEncoderConfigurations/>"
    return "<trt:GetVideoEncoderConfigurations/>"
