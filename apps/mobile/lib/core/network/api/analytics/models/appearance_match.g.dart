// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appearance_match.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppearanceMatch _$AppearanceMatchFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'uuid',
      'view_uuid',
      'view_name',
      'camera_uuid',
      'camera_name',
      'started_at',
      'ended_at',
      'similarity',
      'journey_uuid',
      'event_uuid',
    ],
    disallowNullValues: const [
      'uuid',
      'view_uuid',
      'camera_uuid',
      'started_at',
      'ended_at',
      'similarity',
    ],
  );
  return AppearanceMatch(
    uuid: json['uuid'] as String,
    viewUuid: json['view_uuid'] as String,
    viewName: json['view_name'] as String?,
    cameraUuid: json['camera_uuid'] as String,
    cameraName: json['camera_name'] as String?,
    startedAt: AppearanceMatch._read_startedAt(json['started_at']),
    endedAt: AppearanceMatch._read_endedAt(json['ended_at']),
    similarity: json['similarity'] as num,
    journeyUuid: json['journey_uuid'] as String?,
    eventUuid: json['event_uuid'] as String?,
    additionalProperties:
        AppearanceMatch._extras(json, 'additionalProperties') == null
        ? const {}
        : AppearanceMatch._readExtras(
            AppearanceMatch._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$AppearanceMatchToJson(AppearanceMatch instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'view_uuid': instance.viewUuid,
      'view_name': instance.viewName,
      'camera_uuid': instance.cameraUuid,
      'camera_name': instance.cameraName,
      'started_at': ?AppearanceMatch._write_startedAt(instance.startedAt),
      'ended_at': ?AppearanceMatch._write_endedAt(instance.endedAt),
      'similarity': instance.similarity,
      'journey_uuid': instance.journeyUuid,
      'event_uuid': instance.eventUuid,
    };
