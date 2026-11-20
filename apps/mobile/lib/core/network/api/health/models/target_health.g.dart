// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'target_health.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TargetHealth _$TargetHealthFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'uuid',
      'kind',
      'device_kind',
      'name',
      'host',
      'port',
      'parent_uuid',
      'parent_name',
      'link',
      'notes',
      'enabled',
      'status',
      'last_sample_at',
      'last_error',
      'samples',
      'uptime_percent',
      'latency',
      'outage_count',
      'last_outage',
      'buckets',
    ],
    disallowNullValues: const [
      'uuid',
      'kind',
      'name',
      'host',
      'port',
      'enabled',
      'status',
      'samples',
      'latency',
      'outage_count',
      'buckets',
    ],
  );
  return TargetHealth(
    uuid: json['uuid'] as String,
    kind: TargetHealth._read_kind(json['kind']),
    deviceKind: TargetHealth._read_deviceKind(json['device_kind']),
    name: json['name'] as String,
    host: json['host'] as String,
    port: TargetHealth._read_port(json['port']),
    parentUuid: json['parent_uuid'] as String?,
    parentName: json['parent_name'] as String?,
    link: TargetHealth._read_link(json['link']),
    notes: json['notes'] as String?,
    enabled: json['enabled'] as bool,
    status: TargetHealth._read_status(json['status']),
    lastSampleAt: TargetHealth._read_lastSampleAt(json['last_sample_at']),
    lastError: json['last_error'] as String?,
    samples: TargetHealth._read_samples(json['samples']),
    uptimePercent: json['uptime_percent'] as num?,
    latency: LatencyStats.fromJson(json['latency'] as Map<String, dynamic>),
    outageCount: TargetHealth._read_outageCount(json['outage_count']),
    lastOutage: json['last_outage'] == null
        ? null
        : OutageBrief.fromJson(json['last_outage'] as Map<String, dynamic>),
    buckets: (json['buckets'] as List<dynamic>)
        .map((e) => HealthBucket.fromJson(e as Map<String, dynamic>))
        .toList(),
    additionalProperties:
        TargetHealth._extras(json, 'additionalProperties') == null
        ? const {}
        : TargetHealth._readExtras(
            TargetHealth._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$TargetHealthToJson(TargetHealth instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'kind': ?TargetHealth._write_kind(instance.kind),
      'device_kind': TargetHealth._write_deviceKind(instance.deviceKind),
      'name': instance.name,
      'host': instance.host,
      'port': ?TargetHealth._write_port(instance.port),
      'parent_uuid': instance.parentUuid,
      'parent_name': instance.parentName,
      'link': TargetHealth._write_link(instance.link),
      'notes': instance.notes,
      'enabled': instance.enabled,
      'status': ?TargetHealth._write_status(instance.status),
      'last_sample_at': TargetHealth._write_lastSampleAt(instance.lastSampleAt),
      'last_error': instance.lastError,
      'samples': ?TargetHealth._write_samples(instance.samples),
      'uptime_percent': instance.uptimePercent,
      'latency': instance.latency.toJson(),
      'outage_count': ?TargetHealth._write_outageCount(instance.outageCount),
      'last_outage': instance.lastOutage?.toJson(),
      'buckets': instance.buckets.map((e) => e.toJson()).toList(),
    };
