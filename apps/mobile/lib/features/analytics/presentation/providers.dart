import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/features/analytics/domain/models.dart';

part 'providers.g.dart';
@riverpod
Future<List<AnalyticsView>> views(Ref ref, String siteId) => ref.watch(backendProvider).analytics.views(siteId);
