import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/core/providers.dart';
import 'package:smart_surveillance/features/events/domain/models.dart';

part 'providers.g.dart';

/// Returns midnight at the start of the day containing [at].
DateTime startOfDay(DateTime at) => DateTime(at.year, at.month, at.day);

/// Loads the event totals for today at [siteId].
@riverpod
Future<EventCounts> todayCounts(Ref ref, String siteId) {
  final now = ref.watch(clockProvider)();
  return ref.watch(backendProvider).events.counts(siteId, EventFilter(day: startOfDay(now)));
}

/// Loads the latest events at [siteId] for the home screen.
@riverpod
Future<List<CameraEvent>> recentEvents(Ref ref, String siteId) async {
  final page = await ref
      .watch(backendProvider)
      .events
      .events(siteId, const EventFilter(), pageSize: 12);
  return page.items;
}

/// Streams live updates for [siteId] as they arrive.
@riverpod
Stream<LiveUpdate> liveUpdates(Ref ref, String siteId) =>
    ref.watch(backendProvider).events.updates(siteId);

/// Refreshing helpers for the data shown on the site's home screen.
extension SiteRefresh on WidgetRef {
  /// Reloads today's counts and the recent events of [siteId].
  void refreshSite(String siteId) {
    invalidate(todayCountsProvider(siteId));
    invalidate(recentEventsProvider(siteId));
  }
}
