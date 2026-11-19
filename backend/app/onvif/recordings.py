from dataclasses import dataclass
from datetime import UTC, datetime
from xml.etree.ElementTree import Element
from xml.sax.saxutils import escape

from app.camera_events.notifications import clean_topic, items, parse_time
from app.onvif.media import whole
from app.onvif.soap import child, descendant, descendant_text, descendants, text

TRACK_STATE = "RecordingHistory/Track/State"
RECORDING_STATE = "RecordingHistory/Recording/State"

SUMMARY = "<tse:GetRecordingSummary/>"
RECORDINGS = "<trc:GetRecordings/>"


@dataclass(frozen=True)
class Summary:
    count: int | None
    data_from: datetime | None
    data_until: datetime | None


@dataclass(frozen=True)
class Recording:
    token: str
    video_tracks: tuple[str, ...]


@dataclass(frozen=True)
class TrackChange:
    time: datetime
    track: str | None
    present: bool
    start_state: bool


@dataclass(frozen=True)
class EventPage:
    state: str | None
    changes: list[TrackChange]


def stamp(moment: datetime) -> str:
    return moment.astimezone(UTC).strftime("%Y-%m-%dT%H:%M:%SZ")


def parse_summary(body: Element) -> Summary:
    summary = descendant(body, "Summary")
    return Summary(
        count=whole(text(child(summary, "NumberRecordings"))),
        data_from=parse_time(text(child(summary, "DataFrom"))),
        data_until=parse_time(text(child(summary, "DataUntil"))),
    )


def parse_recordings(body: Element) -> list[Recording]:
    result = []
    for item in descendants(body, "RecordingItem"):
        token = text(child(item, "RecordingToken"))
        if not token:
            continue
        tracks = []
        for track in descendants(item, "Track"):
            kind = descendant_text(track, "TrackType")
            track_token = text(child(track, "TrackToken"))
            if track_token and (kind or "").lower() == "video":
                tracks.append(track_token)
        result.append(Recording(token=token, video_tracks=tuple(tracks)))
    return result


def find_events_body(recording: str, start: datetime, end: datetime) -> str:
    return (
        f"<tse:FindEvents><tse:StartPoint>{stamp(start)}</tse:StartPoint><tse:EndPoint>{stamp(end)}</tse:EndPoint>"
        f"<tse:Scope><tt:IncludedRecordings>{escape(recording)}</tt:IncludedRecordings></tse:Scope>"
        "<tse:SearchFilter></tse:SearchFilter><tse:IncludeStartState>true</tse:IncludeStartState>"
        "<tse:MaxMatches>2000</tse:MaxMatches><tse:KeepAliveTime>PT30S</tse:KeepAliveTime></tse:FindEvents>"
    )


def event_results_body(token: str) -> str:
    return (
        f"<tse:GetEventSearchResults><tse:SearchToken>{escape(token)}</tse:SearchToken>"
        "<tse:MinResults>1</tse:MinResults><tse:MaxResults>500</tse:MaxResults>"
        "<tse:WaitTime>PT3S</tse:WaitTime></tse:GetEventSearchResults>"
    )


def end_search_body(token: str) -> str:
    return f"<tse:EndSearch><tse:SearchToken>{escape(token)}</tse:SearchToken></tse:EndSearch>"


def replay_uri_body(recording: str) -> str:
    return (
        "<trp:GetReplayUri><trp:StreamSetup><tt:Stream>RTP-Unicast</tt:Stream>"
        "<tt:Transport><tt:Protocol>RTSP</tt:Protocol></tt:Transport></trp:StreamSetup>"
        f"<trp:RecordingToken>{escape(recording)}</trp:RecordingToken></trp:GetReplayUri>"
    )


def parse_search_token(body: Element) -> str | None:
    return descendant_text(body, "SearchToken")


def parse_event_page(body: Element) -> EventPage:
    changes = []
    for result in descendants(body, "Result"):
        topic = clean_topic(descendant_text(result, "Topic"))
        if topic not in (TRACK_STATE, RECORDING_STATE):
            continue
        moment = parse_time(text(child(result, "Time")))
        message = None
        for element in result.iter():
            if element.tag.endswith("Message") and child(element, "Data") is not None:
                message = element
                break
        data, _ = items(child(message, "Data"))
        source, _ = items(child(message, "Source"))
        present = data.get("IsDataPresent") or data.get("IsRecording")
        if moment is None or present is None:
            continue
        changes.append(
            TrackChange(
                time=moment,
                track=text(child(result, "TrackToken")) or source.get("Track"),
                present=present.lower() == "true",
                start_state=(text(child(result, "StartStateEvent")) or "false").lower() == "true",
            )
        )
    return EventPage(state=descendant_text(body, "SearchState"), changes=changes)


def segments(
    changes: list[TrackChange], start: datetime, end: datetime, tracks: tuple[str, ...]
) -> list[tuple[datetime, datetime]]:
    relevant = [change for change in changes if not tracks or change.track in tracks or change.track is None]
    relevant.sort(key=lambda change: (change.time, not change.start_state))
    result: list[tuple[datetime, datetime]] = []
    opened: datetime | None = None
    for change in relevant:
        moment = min(max(change.time, start), end)
        if change.present and opened is None:
            opened = moment
        elif not change.present and opened is not None:
            if moment > opened:
                result.append((opened, moment))
            opened = None
    if opened is not None and end > opened:
        result.append((opened, end))
    merged: list[tuple[datetime, datetime]] = []
    for begin, finish in result:
        if merged and begin <= merged[-1][1]:
            merged[-1] = (merged[-1][0], max(merged[-1][1], finish))
        else:
            merged.append((begin, finish))
    return merged
