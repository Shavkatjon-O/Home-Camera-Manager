import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/core/providers.dart';
import 'package:smart_surveillance/features/events/presentation/providers.dart';
import 'package:smart_surveillance/features/insights/domain/models.dart';

part 'providers.g.dart';

/// Loads the counted areas of the site [siteId].
@riverpod
Future<List<Area>> areas(Ref ref, String siteId) =>
    ref.watch(backendProvider).analytics.areas(siteId);

/// Loads today's line crossing counts for the site [siteId], grouped by hour.
@riverpod
Future<CountsReport> todayReport(Ref ref, String siteId) {
  final now = ref.watch(clockProvider)();
  final start = startOfDay(now);
  return ref
      .watch(backendProvider)
      .analytics
      .counts(siteId, start: start, end: start.add(const Duration(days: 1)), bucket: Bucket.hour);
}
