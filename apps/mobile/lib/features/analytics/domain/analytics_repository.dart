
import 'package:smart_surveillance/core/media/media_source.dart';
import 'package:smart_surveillance/features/analytics/domain/models.dart';
import 'package:smart_surveillance/features/insights/domain/models.dart';
import 'package:smart_surveillance/features/investigation/domain/models.dart';
/// The source of camera analytics configuration, live detections, counts and person tracking.
abstract interface class AnalyticsRepository {
  /// Returns the analytics views of every camera at the site [siteId].
  Future<List<AnalyticsView>> views(String siteId);

  /// Returns the analytics view [viewId].
  Future<AnalyticsView> view(String viewId);

  /// Saves the settings of [view] and returns the stored view.
  Future<AnalyticsView> updateView(AnalyticsView view);

  /// Replaces the zones and lines of view [viewId] with [zones] and [lines].
  ///
  /// Returns the stored view.
  Future<AnalyticsView> saveRules(String viewId, {required List<Zone> zones, required List<Line> lines});

  /// Returns a still image of view [viewId] to draw zones and lines on.
  Future<MediaSource> viewSnapshot(String viewId);

  /// Streams the objects currently detected in view [viewId], updated as they move.
  Stream<List<LiveObject>> liveObjects(String viewId);

  /// Returns the entry and exit counts at [siteId] between [start] and [end], grouped by [bucket].
  Future<CountsReport> counts(String siteId, {required DateTime start, required DateTime end, required Bucket bucket});

  /// Returns the counted areas of the site [siteId] with their current occupancy.
  Future<List<Area>> areas(String siteId);

  /// Sets the occupancy of area [areaId] to [occupancy] and zeroes its entry and exit totals.
  Future<Area> resetArea(String areaId, int occupancy);

  /// Returns the path a person took across cameras for event [eventId], or null if none exists.
  Future<Journey?> journey(String eventId);

  /// Returns the other sightings that look like the person in event [eventId].
  Future<List<AppearanceMatch>> findPerson(String eventId);
}
