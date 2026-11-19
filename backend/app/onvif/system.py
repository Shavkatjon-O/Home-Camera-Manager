from dataclasses import dataclass
from datetime import UTC, datetime
from xml.etree.ElementTree import Element
from xml.sax.saxutils import escape

from app.onvif.client import parse_device_time
from app.onvif.soap import child, descendant, descendant_text, text

DEVICE_INFORMATION = "<tds:GetDeviceInformation/>"
DATE_AND_TIME = "<tds:GetSystemDateAndTime/>"
REBOOT = "<tds:SystemReboot/>"


@dataclass(frozen=True)
class DeviceDetails:
    manufacturer: str | None
    model: str | None
    firmware: str | None
    serial: str | None
    hardware_id: str | None


@dataclass(frozen=True)
class Clock:
    mode: str | None
    timezone: str | None
    daylight_savings: bool | None
    utc: datetime | None


def parse_details(body: Element) -> DeviceDetails:
    return DeviceDetails(
        manufacturer=descendant_text(body, "Manufacturer"),
        model=descendant_text(body, "Model"),
        firmware=descendant_text(body, "FirmwareVersion"),
        serial=descendant_text(body, "SerialNumber"),
        hardware_id=descendant_text(body, "HardwareId"),
    )


def parse_clock(body: Element) -> Clock:
    moment = descendant(body, "SystemDateAndTime")
    daylight = text(child(moment, "DaylightSavings"))
    return Clock(
        mode=text(child(moment, "DateTimeType")),
        timezone=text(child(child(moment, "TimeZone"), "TZ")),
        daylight_savings=None if daylight is None else daylight.lower() == "true",
        utc=parse_device_time(body),
    )


def clock_fields(clock: Clock) -> str:
    daylight = "true" if clock.daylight_savings else "false"
    zone = f"<tds:TimeZone><tt:TZ>{escape(clock.timezone)}</tt:TZ></tds:TimeZone>" if clock.timezone else ""
    return f"<tds:DaylightSavings>{daylight}</tds:DaylightSavings>{zone}"


def manual_time_body(clock: Clock, now: datetime) -> str:
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
    return (
        "<tds:SetSystemDateAndTime><tds:DateTimeType>NTP</tds:DateTimeType>"
        f"{clock_fields(clock)}</tds:SetSystemDateAndTime>"
    )
