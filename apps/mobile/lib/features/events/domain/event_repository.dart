import 'package:smart_surveillance/core/media/media_source.dart';
import 'package:smart_surveillance/features/events/domain/models.dart';
import 'package:smart_surveillance/features/media/domain/media_repository.dart';

/// The source of camera events, their media and live updates.
abstract interface class EventRepository {
  /// Returns page [page] of the events at [siteId] matching [filter], [pageSize] events per page.
  Future<EventPage> events(String siteId, EventFilter filter, {int page = 1, int pageSize = 30});

  /// Returns the totals of the events at [siteId] matching [filter].
  Future<EventCounts> counts(String siteId, EventFilter filter);

  /// Returns the event [eventId].
  Future<CameraEvent> event(String eventId);

  /// Marks the event [eventId] as acknowledged and returns it.
  Future<CameraEvent> acknowledge(String eventId);

  /// Acknowledges every unacknowledged alert at [siteId] and returns how many changed.
  Future<int> acknowledgeAll(String siteId);

  /// Streams live changes to events, arm state and camera status at [siteId].
  Stream<LiveUpdate> updates(String siteId);

  /// Returns the full-size snapshot of [event].
  MediaSource snapshot(CameraEvent event);

  /// Returns the small preview image of [event].
  MediaSource thumbnail(CameraEvent event);

  /// Returns the cropped face image of [event], or null when it has none.
  MediaSource? faceCrop(CameraEvent event);

  /// Returns the recorded clip of [event], or null when none was kept.
  ClipSource? clip(CameraEvent event);

  /// Downloads the clip of [event] and returns the path of the saved file.
  Future<String> downloadClip(CameraEvent event);
}
