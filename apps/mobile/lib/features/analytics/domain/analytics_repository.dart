
import 'package:smart_surveillance/core/media/media_source.dart';
import 'package:smart_surveillance/features/analytics/domain/models.dart';
import 'package:smart_surveillance/features/insights/domain/models.dart';
import 'package:smart_surveillance/features/investigation/domain/models.dart';
abstract interface class AnalyticsRepository {
  Future<List<AnalyticsView>> views(String siteId);

  Future<AnalyticsView> view(String viewId);

  Future<AnalyticsView> updateView(AnalyticsView view);

  Future<AnalyticsView> saveRules(String viewId, {required List<Zone> zones, required List<Line> lines});

  Future<MediaSource> viewSnapshot(String viewId);

  Stream<List<LiveObject>> liveObjects(String viewId);

  Future<CountsReport> counts(String siteId, {required DateTime start, required DateTime end, required Bucket bucket});

  Future<List<Area>> areas(String siteId);

  Future<Area> resetArea(String areaId, int occupancy);

  Future<Journey?> journey(String eventId);

  Future<List<AppearanceMatch>> findPerson(String eventId);
}
