import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/features/analytics/domain/models.dart';

part 'providers.g.dart';
/// Loads the analytics views of the site [siteId].
@riverpod
Future<List<AnalyticsView>> views(Ref ref, String siteId) => ref.watch(backendProvider).analytics.views(siteId);
