import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';
enum AuditCategory { signIn, members, cameras, rules, arm, views, exports, faces, admin }

@freezed
abstract class AuditEntry with _$AuditEntry {
  const factory AuditEntry({
    required String id,
    required DateTime at,
    required String actor,
    required String action,
    required AuditCategory category,
    String? target,
    String? siteName,
  }) = _AuditEntry;
}

@freezed
abstract class AuditPage with _$AuditPage {
  const factory AuditPage({required List<AuditEntry> items, required int total, required int page}) = _AuditPage;
}

enum HealthStatus { up, degraded, down, unknown, disabled }

@freezed
abstract class HealthBucket with _$HealthBucket {
  const factory HealthBucket({
    required DateTime start,
    double? availability,
    double? latencyMs,
  }) = _HealthBucket;
}

@freezed
abstract class HealthTarget with _$HealthTarget {
  const factory HealthTarget({
    required String id,
    required String name,
    required String kind,
    required HealthStatus status,
    double? uptimePercent,
    double? latencyMs,
    @Default(0) int outageCount,
    String? parentName,
    DateTime? lastSampleAt,
    @Default(<HealthBucket>[]) List<HealthBucket> buckets,
  }) = _HealthTarget;
}

@freezed
abstract class Outage with _$Outage {
  const factory Outage({
    required String id,
    required String targetName,
    required DateTime startedAt,
    DateTime? endedAt,
    @Default(false) bool ongoing,
    String? causeName,
  }) = _Outage;
}

@freezed
abstract class HealthReport with _$HealthReport {
  const factory HealthReport({
    required List<HealthTarget> targets,
    required List<Outage> outages,
  }) = _HealthReport;
}
