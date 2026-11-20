import 'package:freezed_annotation/freezed_annotation.dart';

part 'business.freezed.dart';

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

@freezed
abstract class TelegramChat with _$TelegramChat {
  const factory TelegramChat({
    required String id,
    required String title,
    @Default(false) bool group,
    required DateTime linkedAt,
    String? linkedBy,
  }) = _TelegramChat;
}

@freezed
abstract class TelegramLink with _$TelegramLink {
  const factory TelegramLink({required String url, required DateTime expiresAt}) = _TelegramLink;
}

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
