import 'package:smart_surveillance/core/network/api/surveillance_api.dart' as api;
import 'package:smart_surveillance/core/network/client/http.dart';
import 'package:smart_surveillance/features/operations/domain/health_repository.dart';
import 'package:smart_surveillance/features/operations/domain/models.dart';

/// Reads the health of a site's connectors and cameras from the server.
class ApiHealthRepository implements HealthRepository {
  /// Creates the repository over [client].
  ApiHealthRepository(this.client);

  /// The generated API.
  final api.SurveillanceApi client;

  /// The number of outages read.
  static const outageLimit = 100;

  /// Reads a JSON object.
  static Map<String, Object?> objectOf(Object? value) =>
      value is Map ? value.cast<String, Object?>() : const <String, Object?>{};

  /// Reads a time field as local time.
  static DateTime? timeOf(Object? value) =>
      value is String ? DateTime.tryParse(value)?.toLocal() : null;

  /// Converts a monitored target as the server writes it in JSON to the app's [HealthTarget].
  static HealthTarget targetOf(Map<String, Object?> json) => HealthTarget(
    id: json['uuid']! as String,
    name: json['name'] as String? ?? '',
    kind: json['kind'] as String? ?? 'device',
    status: HealthStatus.values.asNameMap()[json['status']] ?? HealthStatus.unknown,
    uptimePercent: (json['uptime_percent'] as num?)?.toDouble(),
    latencyMs: (objectOf(json['latency'])['avg_ms'] as num?)?.toDouble(),
    outageCount: (json['outage_count'] as num?)?.toInt() ?? 0,
    parentName: json['parent_name'] as String?,
    lastSampleAt: timeOf(json['last_sample_at']),
    buckets: [
      for (final item in json['buckets'] as List<Object?>? ?? const <Object?>[])
        HealthBucket(
          start: timeOf(objectOf(item)['start']) ?? DateTime.fromMillisecondsSinceEpoch(0),
          availability: (objectOf(item)['availability'] as num?)?.toDouble(),
          latencyMs: (objectOf(item)['latency_ms'] as num?)?.toDouble(),
        ),
    ],
  );

  /// Converts an outage as the server writes it in JSON to the app's [Outage].
  static Outage outageOf(Map<String, Object?> json) => Outage(
    id: json['uuid']! as String,
    targetName: json['target_name'] as String? ?? '',
    startedAt: timeOf(json['started_at']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    endedAt: timeOf(json['ended_at']),
    ongoing: json['ongoing'] == true,
    causeName: json['upstream_name'] as String?,
  );

  @override
  Future<HealthReport> health(String siteId) async {
    final overview = await guarded(
      () => client.health.healthOverview(xSite: siteId, range: api.HealthRange.field24h),
    );
    final outages = await guarded(
      () => client.health.listOutages(xSite: siteId, pageSize: outageLimit),
    );
    return HealthReport(
      targets: [
        for (final item in overview.toJson()['targets'] as List<Object?>? ?? const <Object?>[])
          targetOf(objectOf(item)),
      ],
      outages: [
        for (final item in outages.toJson()['items'] as List<Object?>? ?? const <Object?>[])
          outageOf(objectOf(item)),
      ],
    );
  }
}
