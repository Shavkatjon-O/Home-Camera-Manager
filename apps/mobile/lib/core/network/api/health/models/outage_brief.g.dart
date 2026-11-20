// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outage_brief.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutageBrief _$OutageBriefFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'uuid',
      'started_at',
      'ended_at',
      'duration_seconds',
      'upstream_uuid',
      'upstream_name',
    ],
    disallowNullValues: const ['uuid', 'started_at', 'duration_seconds'],
  );
  return OutageBrief(
    uuid: json['uuid'] as String,
    startedAt: OutageBrief._read_startedAt(json['started_at']),
    endedAt: OutageBrief._read_endedAt(json['ended_at']),
    durationSeconds: json['duration_seconds'] as num,
    upstreamUuid: json['upstream_uuid'] as String?,
    upstreamName: json['upstream_name'] as String?,
    additionalProperties:
        OutageBrief._extras(json, 'additionalProperties') == null
        ? const {}
        : OutageBrief._readExtras(
            OutageBrief._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$OutageBriefToJson(OutageBrief instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'started_at': ?OutageBrief._write_startedAt(instance.startedAt),
      'ended_at': OutageBrief._write_endedAt(instance.endedAt),
      'duration_seconds': instance.durationSeconds,
      'upstream_uuid': instance.upstreamUuid,
      'upstream_name': instance.upstreamName,
    };
