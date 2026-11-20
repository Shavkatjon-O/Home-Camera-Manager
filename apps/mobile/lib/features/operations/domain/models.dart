import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';

/// The kind of action an audit entry records.
enum AuditCategory {
  /// A sign-in or sign-out.
  signIn,

  /// A change to the site's members or invitations.
  members,

  /// A change to the site's cameras.
  cameras,

  /// A change to the alert rules.
  rules,

  /// A change of the arm mode.
  arm,

  /// Opening a camera's live or recorded view.
  views,

  /// An export of data.
  exports,

  /// A change to the known faces.
  faces,

  /// An administrative action.
  admin,
}

/// The category an audit [action] code of the server belongs to.
AuditCategory auditCategoryOf(String action) => switch (action) {
  'sign_in' || 'sign_out' || 'account_delete' || 'password_change' => AuditCategory.signIn,
  'camera_create' ||
  'camera_update' ||
  'camera_delete' ||
  'device_pair' ||
  'connector_claim' ||
  'connector_update' ||
  'connector_revoke' ||
  'camera_control' => AuditCategory.cameras,
  'rules_update' => AuditCategory.rules,
  'arm_mode_change' || 'alert_channel_link' || 'alert_channel_remove' => AuditCategory.arm,
  'live_view' || 'clip_view' => AuditCategory.views,
  'export' => AuditCategory.exports,
  'face_enrol' || 'face_delete' || 'faces_consent' => AuditCategory.faces,
  _ when action.startsWith('admin_') => AuditCategory.admin,
  _ => AuditCategory.members,
};

/// One recorded action in the audit log.
@freezed
abstract class AuditEntry with _$AuditEntry {
  /// Creates the entry [id] where [actor] did [action] at [at].
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

/// One page of the audit log.
@freezed
abstract class AuditPage with _$AuditPage {
  /// Creates page number [page] with its [items] out of [total] entries.
  const factory AuditPage({
    required List<AuditEntry> items,
    required int total,
    required int page,
  }) = _AuditPage;
}

/// How well a monitored target is working.
enum HealthStatus {
  /// The target is working.
  up,

  /// The target works with problems.
  degraded,

  /// The target is not working.
  down,

  /// The state of the target is not known.
  unknown,

  /// Monitoring of the target is turned off.
  disabled,
}

/// The availability and latency of a target over one time slice.
@freezed
abstract class HealthBucket with _$HealthBucket {
  /// Creates a bucket that starts at [start].
  const factory HealthBucket({required DateTime start, double? availability, double? latencyMs}) =
      _HealthBucket;
}

/// A monitored connector or camera with its uptime and latency.
@freezed
abstract class HealthTarget with _$HealthTarget {
  /// Creates the target [id] named [name] of the [kind] with the [status].
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

/// A period during which a target was unavailable.
@freezed
abstract class Outage with _$Outage {
  /// Creates the outage [id] of [targetName] that began at [startedAt].
  const factory Outage({
    required String id,
    required String targetName,
    required DateTime startedAt,
    DateTime? endedAt,
    @Default(false) bool ongoing,
    String? causeName,
  }) = _Outage;
}

/// The health of every target of a site together with its outages.
@freezed
abstract class HealthReport with _$HealthReport {
  /// Creates a report of [targets] and [outages].
  const factory HealthReport({required List<HealthTarget> targets, required List<Outage> outages}) =
      _HealthReport;
}
