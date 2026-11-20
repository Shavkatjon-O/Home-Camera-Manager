// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journey_step_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JourneyStepRead _$JourneyStepReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'view_uuid',
      'view_name',
      'camera_uuid',
      'camera_name',
      'track',
      'started_at',
      'ended_at',
      'similarity',
    ],
    disallowNullValues: const ['view_uuid', 'camera_uuid', 'track', 'started_at', 'ended_at'],
  );
  return JourneyStepRead(
    viewUuid: json['view_uuid'] as String,
    viewName: json['view_name'] as String?,
    cameraUuid: json['camera_uuid'] as String,
    cameraName: json['camera_name'] as String?,
    track: JourneyStepRead._read_track(json['track']),
    startedAt: JourneyStepRead._read_startedAt(json['started_at']),
    endedAt: JourneyStepRead._read_endedAt(json['ended_at']),
    similarity: json['similarity'] as num?,
    eventUuid: json['event_uuid'] as String?,
    additionalProperties: JourneyStepRead._extras(json, 'additionalProperties') == null
        ? const {}
        : JourneyStepRead._readExtras(JourneyStepRead._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$JourneyStepReadToJson(JourneyStepRead instance) => <String, dynamic>{
  'view_uuid': instance.viewUuid,
  'view_name': instance.viewName,
  'camera_uuid': instance.cameraUuid,
  'camera_name': instance.cameraName,
  'track': ?JourneyStepRead._write_track(instance.track),
  'started_at': ?JourneyStepRead._write_startedAt(instance.startedAt),
  'ended_at': ?JourneyStepRead._write_endedAt(instance.endedAt),
  'similarity': instance.similarity,
  'event_uuid': ?instance.eventUuid,
};
