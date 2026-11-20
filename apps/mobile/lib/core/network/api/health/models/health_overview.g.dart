// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_overview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthOverview _$HealthOverviewFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'range',
      'since',
      'until',
      'bucket_seconds',
      'interval_seconds',
      'targets',
    ],
    disallowNullValues: const [
      'range',
      'since',
      'until',
      'bucket_seconds',
      'interval_seconds',
      'targets',
    ],
  );
  return HealthOverview(
    range: HealthOverview._read_range(json['range']),
    since: HealthOverview._read_since(json['since']),
    until: HealthOverview._read_until(json['until']),
    bucketSeconds: HealthOverview._read_bucketSeconds(json['bucket_seconds']),
    intervalSeconds: HealthOverview._read_intervalSeconds(json['interval_seconds']),
    targets: (json['targets'] as List<dynamic>)
        .map((e) => TargetHealth.fromJson(e as Map<String, dynamic>))
        .toList(),
    additionalProperties: HealthOverview._extras(json, 'additionalProperties') == null
        ? const {}
        : HealthOverview._readExtras(HealthOverview._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$HealthOverviewToJson(HealthOverview instance) => <String, dynamic>{
  'range': ?HealthOverview._write_range(instance.range),
  'since': ?HealthOverview._write_since(instance.since),
  'until': ?HealthOverview._write_until(instance.until),
  'bucket_seconds': ?HealthOverview._write_bucketSeconds(instance.bucketSeconds),
  'interval_seconds': ?HealthOverview._write_intervalSeconds(instance.intervalSeconds),
  'targets': instance.targets.map((e) => e.toJson()).toList(),
};
