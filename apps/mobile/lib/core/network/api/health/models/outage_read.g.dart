// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outage_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutageRead _$OutageReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'uuid',
      'target_kind',
      'target_uuid',
      'target_name',
      'started_at',
      'ended_at',
      'ongoing',
      'duration_seconds',
      'failed_samples',
      'upstream_uuid',
      'upstream_name',
      'created_at',
      'updated_at',
    ],
    disallowNullValues: const [
      'uuid',
      'target_kind',
      'target_uuid',
      'started_at',
      'ongoing',
      'duration_seconds',
      'failed_samples',
      'created_at',
      'updated_at',
    ],
  );
  return OutageRead(
    uuid: json['uuid'] as String,
    targetKind: OutageRead._read_targetKind(json['target_kind']),
    targetUuid: json['target_uuid'] as String,
    targetName: json['target_name'] as String?,
    startedAt: OutageRead._read_startedAt(json['started_at']),
    endedAt: OutageRead._read_endedAt(json['ended_at']),
    ongoing: json['ongoing'] as bool,
    durationSeconds: json['duration_seconds'] as num,
    failedSamples: OutageRead._read_failedSamples(json['failed_samples']),
    upstreamUuid: json['upstream_uuid'] as String?,
    upstreamName: json['upstream_name'] as String?,
    createdAt: OutageRead._read_createdAt(json['created_at']),
    updatedAt: OutageRead._read_updatedAt(json['updated_at']),
    additionalProperties: OutageRead._extras(json, 'additionalProperties') == null
        ? const {}
        : OutageRead._readExtras(OutageRead._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$OutageReadToJson(OutageRead instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'target_kind': ?OutageRead._write_targetKind(instance.targetKind),
  'target_uuid': instance.targetUuid,
  'target_name': instance.targetName,
  'started_at': ?OutageRead._write_startedAt(instance.startedAt),
  'ended_at': OutageRead._write_endedAt(instance.endedAt),
  'ongoing': instance.ongoing,
  'duration_seconds': instance.durationSeconds,
  'failed_samples': ?OutageRead._write_failedSamples(instance.failedSamples),
  'upstream_uuid': instance.upstreamUuid,
  'upstream_name': instance.upstreamName,
  'created_at': ?OutageRead._write_createdAt(instance.createdAt),
  'updated_at': ?OutageRead._write_updatedAt(instance.updatedAt),
};
