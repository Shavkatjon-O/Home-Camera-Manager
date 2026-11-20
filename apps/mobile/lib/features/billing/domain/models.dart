import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';

/// A capability that a plan can include.
enum PlanFeature {
  /// Face recognition.
  faces,

  /// Licence plate recognition.
  plates,

  /// Appearance search.
  appearance,

  /// Journeys of a person across cameras.
  journeys,

  /// Fall detection.
  falls,

  /// Object detection.
  objects,

  /// Following a person across cameras.
  follow,

  /// Telegram alerts.
  telegram,
}

/// The quantity limits of a plan, where null means unlimited.
@freezed
abstract class PlanLimits with _$PlanLimits {
  /// Creates limits for sites, cameras, members and retention.
  const factory PlanLimits({
    int? sites,
    int? cameras,
    int? members,
    int? eventRetentionDays,
    int? clipRetentionDays,
  }) = _PlanLimits;
}

/// A subscription plan with its limits and features.
@freezed
abstract class Plan with _$Plan {
  const Plan._();

  /// Creates the plan [id] named [name].
  const factory Plan({
    required String id,
    required String name,
    @Default(false) bool internal,
    @Default(PlanLimits()) PlanLimits limits,
    @Default(<PlanFeature>{}) Set<PlanFeature> features,
  }) = _Plan;

  /// Returns whether the plan includes [feature].
  bool has(PlanFeature feature) => features.contains(feature);
}

/// The resources an organisation has used in one billing period.
@freezed
abstract class Usage with _$Usage {
  /// Creates usage for the period starting at [periodStart].
  ///
  /// [metered] is false when the member may not read the metered usage, so
  /// only the counts of sites, cameras and members are known.
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
    @Default(true) bool metered,
  }) = _Usage;
}

/// A plan together with the usage measured against it.
@freezed
abstract class PlanReport with _$PlanReport {
  /// Creates a report of [plan] and [usage]; [suspended] is set when a platform
  /// admin suspended the organisation.
  const factory PlanReport({
    required Plan plan,
    required Usage usage,
    @Default(false) bool suspended,
  }) = _PlanReport;
}
