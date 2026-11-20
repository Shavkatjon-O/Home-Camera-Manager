import 'package:freezed_annotation/freezed_annotation.dart';

part 'insights.freezed.dart';

enum Bucket { hour, day }

@freezed
abstract class CountLine with _$CountLine {
  const factory CountLine({
    required String id,
    required String name,
    required String viewName,
    required String cameraName,
  }) = _CountLine;
}

@freezed
abstract class CountBucket with _$CountBucket {
  const factory CountBucket({
    required String lineId,
    required DateTime at,
    required String label,
    required int inward,
    required int outward,
  }) = _CountBucket;
}

@freezed
abstract class CountsReport with _$CountsReport {
  const factory CountsReport({
    required DateTime start,
    required DateTime end,
    required Bucket bucket,
    required List<CountLine> lines,
    required List<CountBucket> buckets,
  }) = _CountsReport;
}

@freezed
abstract class Area with _$Area {
  const factory Area({
    required String id,
    required String name,
    required int occupancy,
    required int entered,
    required int exited,
    required DateTime since,
    String? resetAt,
    @Default(<String>['person']) List<String> labels,
    @Default(<String>[]) List<String> lineNames,
    int? capacity,
  }) = _Area;
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
