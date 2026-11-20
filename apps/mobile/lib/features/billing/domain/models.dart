import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';
enum PlanFeature { faces, plates, appearance, journeys, falls, objects, follow, telegram }

@freezed
abstract class PlanLimits with _$PlanLimits {
  const factory PlanLimits({
    int? sites,
    int? cameras,
    int? members,
    int? eventRetentionDays,
    int? clipRetentionDays,
  }) = _PlanLimits;
}

@freezed
abstract class Plan with _$Plan {
  const Plan._();

  const factory Plan({
    required String id,
    required String name,
    @Default(false) bool internal,
    @Default(PlanLimits()) PlanLimits limits,
    @Default(<PlanFeature>{}) Set<PlanFeature> features,
  }) = _Plan;

  bool has(PlanFeature feature) => features.contains(feature);
}

@freezed
abstract class Usage with _$Usage {
  const factory Usage({
    required DateTime periodStart,
    @Default(0) int sites,
    @Default(0) int cameras,
    @Default(0) int members,
    @Default(0) double cameraHours,
    @Default(0) double analyticsHours,
    @Default(0) int events,
    @Default(0) int clipBytes,
    @Default(0) int notifications,
  }) = _Usage;
}

@freezed
abstract class PlanReport with _$PlanReport {
  const factory PlanReport({required Plan plan, required Usage usage}) = _PlanReport;
}
