"""Recording search and replay requests and parsers for ONVIF devices that record on board."""

from dataclasses import dataclass
from datetime import UTC, datetime
from xml.etree.ElementTree import Element
from xml.sax.saxutils import escape

from camera_adapters.onvif.media import whole
from camera_adapters.onvif.notifications import clean_topic, items, parse_time
from camera_adapters.onvif.soap import child, descendant, descendant_text, descendants, text

TRACK_STATE = "RecordingHistory/Track/State"
RECORDING_STATE = "RecordingHistory/Recording/State"

SUMMARY = "<tse:GetRecordingSummary/>"
RECORDINGS = "<trc:GetRecordings/>"


@dataclass(frozen=True)
class Summary:
    """Overview of what a device has recorded.

    Attributes:
        count: Number of recordings.
        data_from: Time of the oldest recorded data.
        data_until: Time of the newest recorded data.
    """

    count: int | None
    data_from: datetime | None
    data_until: datetime | None


@dataclass(frozen=True)
class Recording:
    """A recording on the device.

    Attributes:
        token: Recording token.
        video_tracks: Tokens of the recording's video tracks.
    """

    token: str
    video_tracks: tuple[str, ...]


@dataclass(frozen=True)
class TrackChange:
    """A change in whether a track has recorded data.

    Attributes:
        time: When the change happened.
        track: Track token, None when the event does not name one.
        present: Whether data is present from this time.
        start_state: Whether the event reports the state at the start of the search rather than a change.
    """

    time: datetime
    track: str | None
    present: bool
    start_state: bool


@dataclass(frozen=True)
class EventPage:
    """One page of recording event search results.

    Attributes:
        state: Search state the device reports, such as Completed.
        changes: Track changes found on the page.
    """

    state: str | None
    changes: list[TrackChange]


def stamp(moment: datetime) -> str:
    """Format a moment as a UTC timestamp for a request.

    Args:
        moment: Moment to format.

    Returns:
        The moment in UTC as YYYY-MM-DDTHH:MM:SSZ.
    """
    return moment.astimezone(UTC).strftime("%Y-%m-%dT%H:%M:%SZ")


def parse_summary(body: Element) -> Summary:
    """Read the recording summary from a GetRecordingSummary response.

    Args:
        body: SOAP body of the response.

    Returns:
        The summary, with None for fields the device left out.
    """
    summary = descendant(body, "Summary")
    return Summary(
        count=whole(text(child(summary, "NumberRecordings"))),
        data_from=parse_time(text(child(summary, "DataFrom"))),
        data_until=parse_time(text(child(summary, "DataUntil"))),
    )


def parse_recordings(body: Element) -> list[Recording]:
    """Read the recordings from a GetRecordings response.

    Args:
        body: SOAP body of the response.

    Returns:
        The recordings that carry a token, each with its video track tokens.
    """
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
    """Build a FindEvents request for the recording state events of one recording.

    Args:
        recording: Recording token.
        start: Start of the searched period.
        end: End of the searched period.

    Returns:
        The XML of the request body.
    """
    return (
        f"<tse:FindEvents><tse:StartPoint>{stamp(start)}</tse:StartPoint><tse:EndPoint>{stamp(end)}</tse:EndPoint>"
        f"<tse:Scope><tt:IncludedRecordings>{escape(recording)}</tt:IncludedRecordings></tse:Scope>"
        "<tse:SearchFilter></tse:SearchFilter><tse:IncludeStartState>true</tse:IncludeStartState>"
        "<tse:MaxMatches>2000</tse:MaxMatches><tse:KeepAliveTime>PT30S</tse:KeepAliveTime></tse:FindEvents>"
    )


def event_results_body(token: str) -> str:
    """Build a GetEventSearchResults request.

    Args:
        token: Search token returned by FindEvents.

    Returns:
        The XML of the request body.
    """
    return (
        f"<tse:GetEventSearchResults><tse:SearchToken>{escape(token)}</tse:SearchToken>"
        "<tse:MinResults>1</tse:MinResults><tse:MaxResults>500</tse:MaxResults>"
        "<tse:WaitTime>PT3S</tse:WaitTime></tse:GetEventSearchResults>"
    )


def end_search_body(token: str) -> str:
    """Build an EndSearch request.

    Args:
        token: Search token to release.

    Returns:
        The XML of the request body.
    """
    return f"<tse:EndSearch><tse:SearchToken>{escape(token)}</tse:SearchToken></tse:EndSearch>"


def replay_uri_body(recording: str) -> str:
    """Build a GetReplayUri request for RTSP replay.

    Args:
        recording: Recording token.

    Returns:
        The XML of the request body.
    """
    return (
        "<trp:GetReplayUri><trp:StreamSetup><tt:Stream>RTP-Unicast</tt:Stream>"
        "<tt:Transport><tt:Protocol>RTSP</tt:Protocol></tt:Transport></trp:StreamSetup>"
        f"<trp:RecordingToken>{escape(recording)}</trp:RecordingToken></trp:GetReplayUri>"
    )


def parse_search_token(body: Element) -> str | None:
    """Read the search token from a FindEvents response.

    Args:
        body: SOAP body of the response.

    Returns:
        The token, or None when the response has none.
    """
    return descendant_text(body, "SearchToken")


def parse_event_page(body: Element) -> EventPage:
    """Read a page of search results into track changes.

    Only track and recording state events with a time and a data presence value are kept.

    Args:
        body: SOAP body of the response.

    Returns:
        The search state and the track changes found.
    """
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
    """Turn track changes into the periods that have recorded data.

    Changes are clamped to the searched period, and overlapping or touching periods are merged.

    Args:
        changes: Track changes found by the search.
        start: Start of the searched period.
        end: End of the searched period.
        tracks: Track tokens to consider, every track when empty. Changes without a track are always considered.

    Returns:
        Start and end of each period with recorded data, in time order.
    """
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
