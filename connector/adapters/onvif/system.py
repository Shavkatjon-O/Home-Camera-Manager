"""Device information and system clock requests for ONVIF devices."""

from dataclasses import dataclass
from datetime import UTC, datetime
from xml.etree.ElementTree import Element
from xml.sax.saxutils import escape

from adapters.onvif.client import parse_device_time
from adapters.onvif.soap import child, descendant, descendant_text, text

DEVICE_INFORMATION = "<tds:GetDeviceInformation/>"
DATE_AND_TIME = "<tds:GetSystemDateAndTime/>"
REBOOT = "<tds:SystemReboot/>"


@dataclass(frozen=True)
class DeviceDetails:
    """Identity of an ONVIF device as it reports itself.

    Attributes:
        manufacturer: Manufacturer name.
        model: Model name.
        firmware: Firmware version.
        serial: Serial number.
        hardware_id: Hardware identifier.
    """

    manufacturer: str | None
    model: str | None
    firmware: str | None
    serial: str | None
    hardware_id: str | None


@dataclass(frozen=True)
class Clock:
    """Date and time settings of a device.

    Attributes:
        mode: Date and time type, Manual or NTP.
        timezone: POSIX time zone string of the device.
        daylight_savings: Whether daylight savings is enabled.
        utc: Current UTC time of the device.
    """

    mode: str | None
    timezone: str | None
    daylight_savings: bool | None
    utc: datetime | None


def parse_details(body: Element) -> DeviceDetails:
    """Read the device information from a GetDeviceInformation response.

    Args:
        body: SOAP body of the response.

    Returns:
        The device details, with None for fields the device left out.
    """
    return DeviceDetails(
        manufacturer=descendant_text(body, "Manufacturer"),
        model=descendant_text(body, "Model"),
        firmware=descendant_text(body, "FirmwareVersion"),
        serial=descendant_text(body, "SerialNumber"),
        hardware_id=descendant_text(body, "HardwareId"),
    )


def parse_clock(body: Element) -> Clock:
    """Read the date and time settings from a GetSystemDateAndTime response.

    Args:
        body: SOAP body of the response.

    Returns:
        The clock settings, with None for fields the device left out.
    """
    moment = descendant(body, "SystemDateAndTime")
    daylight = text(child(moment, "DaylightSavings"))
    return Clock(
        mode=text(child(moment, "DateTimeType")),
        timezone=text(child(child(moment, "TimeZone"), "TZ")),
        daylight_savings=None if daylight is None else daylight.lower() == "true",
        utc=parse_device_time(body),
    )


def clock_fields(clock: Clock) -> str:
    """Build the daylight savings and time zone XML of a SetSystemDateAndTime request.

    Args:
        clock: Current clock settings whose daylight savings and time zone are kept.

    Returns:
        The XML fragment, without a time zone element when the clock has none.
    """
    daylight = "true" if clock.daylight_savings else "false"
    zone = f"<tds:TimeZone><tt:TZ>{escape(clock.timezone)}</tt:TZ></tds:TimeZone>" if clock.timezone else ""
    return f"<tds:DaylightSavings>{daylight}</tds:DaylightSavings>{zone}"


def manual_time_body(clock: Clock, now: datetime) -> str:
    """Build a SetSystemDateAndTime request that sets the device clock by hand.

    Args:
        clock: Current clock settings whose daylight savings and time zone are kept.
        now: Moment to set, converted to UTC.

    Returns:
        The XML of the request body.
    """
    moment = now.astimezone(UTC)
    return (
        "<tds:SetSystemDateAndTime><tds:DateTimeType>Manual</tds:DateTimeType>"
        f"{clock_fields(clock)}"
        "<tds:UTCDateTime>"
        f"<tt:Time><tt:Hour>{moment.hour}</tt:Hour><tt:Minute>{moment.minute}</tt:Minute>"
        f"<tt:Second>{moment.second}</tt:Second></tt:Time>"
        f"<tt:Date><tt:Year>{moment.year}</tt:Year><tt:Month>{moment.month}</tt:Month>"
        f"<tt:Day>{moment.day}</tt:Day></tt:Date>"
        "</tds:UTCDateTime></tds:SetSystemDateAndTime>"
    )


def ntp_mode_body(clock: Clock) -> str:
    """Build a SetSystemDateAndTime request that switches the device clock to NTP.

    Args:
        clock: Current clock settings whose daylight savings and time zone are kept.

    Returns:
        The XML of the request body.
    """
    return (
        "<tds:SetSystemDateAndTime><tds:DateTimeType>NTP</tds:DateTimeType>"
        f"{clock_fields(clock)}</tds:SetSystemDateAndTime>"
    )
