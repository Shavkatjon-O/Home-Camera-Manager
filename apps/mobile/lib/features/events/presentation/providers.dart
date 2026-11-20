import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/core/providers.dart';
import 'package:smart_surveillance/features/events/domain/models.dart';

part 'providers.g.dart';
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
Stream<LiveUpdate> liveUpdates(Ref ref, String siteId) => ref.watch(backendProvider).events.updates(siteId);

extension SiteRefresh on WidgetRef {
  void refreshSite(String siteId) {
    invalidate(todayCountsProvider(siteId));
    invalidate(recentEventsProvider(siteId));
  }
}
