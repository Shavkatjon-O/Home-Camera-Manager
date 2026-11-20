import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../app/providers.dart';
import '../data/models/analytics.dart';
import '../data/models/camera.dart';
import '../data/models/event.dart';
import '../data/models/insights.dart';

part 'site_data.g.dart';

@riverpod
Future<List<Camera>> cameras(Ref ref, String siteId) => ref.watch(backendProvider).devices.cameras(siteId);

@riverpod
Future<List<AnalyticsView>> views(Ref ref, String siteId) => ref.watch(backendProvider).analytics.views(siteId);

@riverpod
Future<List<CameraTile>> tiles(Ref ref, String siteId) async {
  final cameras = await ref.watch(camerasProvider(siteId).future);
  final views = await ref.watch(viewsProvider(siteId).future);
  return [
    for (final camera in cameras.where((c) => c.enabled))
      for (var lens = 0; lens < camera.lenses; lens++)
        CameraTile(
          camera: camera,
          lens: lens,
          viewId: views.where((v) => v.cameraId == camera.id && v.lens == lens).firstOrNull?.id,
        ),
  ];
}

@riverpod
Future<List<Connector>> connectors(Ref ref, String siteId) => ref.watch(backendProvider).devices.connectors(siteId);

DateTime startOfDay(DateTime at) => DateTime(at.year, at.month, at.day);

@riverpod
Future<EventCounts> todayCounts(Ref ref, String siteId) {
  final now = ref.watch(clockProvider)();
  return ref.watch(backendProvider).events.counts(siteId, EventFilter(day: startOfDay(now)));
}

@riverpod
Future<List<CameraEvent>> recentEvents(Ref ref, String siteId) async {
  final page = await ref.watch(backendProvider).events.events(siteId, const EventFilter(), pageSize: 12);
  return page.items;
}

@riverpod
Future<List<Area>> areas(Ref ref, String siteId) => ref.watch(backendProvider).analytics.areas(siteId);

@riverpod
Future<CountsReport> todayReport(Ref ref, String siteId) {
  final now = ref.watch(clockProvider)();
  final start = startOfDay(now);
  return ref
      .watch(backendProvider)
      .analytics
      .counts(siteId, start: start, end: start.add(const Duration(days: 1)), bucket: Bucket.hour);
}

@riverpod
Stream<LiveUpdate> liveUpdates(Ref ref, String siteId) => ref.watch(backendProvider).events.updates(siteId);

extension SiteRefresh on WidgetRef {
  void refreshSite(String siteId) {
    invalidate(todayCountsProvider(siteId));
    invalidate(recentEventsProvider(siteId));
  }
}
