import 'package:smart_surveillance/core/media/media_source.dart';
import 'package:smart_surveillance/features/events/domain/models.dart';
import 'package:smart_surveillance/features/media/domain/media_repository.dart';
abstract interface class EventRepository {
  Future<EventPage> events(String siteId, EventFilter filter, {int page = 1, int pageSize = 30});

  Future<EventCounts> counts(String siteId, EventFilter filter);

  Future<CameraEvent> event(String eventId);

  Future<CameraEvent> acknowledge(String eventId);

  Future<int> acknowledgeAll(String siteId);

  Stream<LiveUpdate> updates(String siteId);

  MediaSource snapshot(CameraEvent event);

  MediaSource thumbnail(CameraEvent event);

  MediaSource? faceCrop(CameraEvent event);

  ClipSource? clip(CameraEvent event);

  Future<String> downloadClip(CameraEvent event);
}
