// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventRead _$EventReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'uuid',
      'camera_uuid',
      'camera_name',
      'kind',
      'source',
      'source_topic',
      'label',
      'alert',
      'view_uuid',
      'started_at',
      'ended_at',
      'ongoing',
      'duration_seconds',
      'camera_time',
      'has_snapshot',
      'has_thumbnail',
      'has_clip',
      'details',
      'created_at',
      'updated_at',
    ],
    disallowNullValues: const [
      'uuid',
      'camera_uuid',
      'kind',
      'source',
      'source_topic',
      'alert',
      'started_at',
      'ongoing',
      'duration_seconds',
      'has_snapshot',
      'has_thumbnail',
      'has_clip',
      'details',
      'created_at',
      'updated_at',
    ],
  );
  return EventRead(
    uuid: json['uuid'] as String,
    cameraUuid: json['camera_uuid'] as String,
    cameraName: json['camera_name'] as String?,
    kind: EventRead._read_kind(json['kind']),
    source: EventRead._read_source(json['source']),
    sourceTopic: json['source_topic'] as String,
    label: json['label'] as String?,
    alert: json['alert'] as bool,
    viewUuid: json['view_uuid'] as String?,
    startedAt: EventRead._read_startedAt(json['started_at']),
    endedAt: EventRead._read_endedAt(json['ended_at']),
    ongoing: json['ongoing'] as bool,
    durationSeconds: json['duration_seconds'] as num,
    cameraTime: EventRead._read_cameraTime(json['camera_time']),
    hasSnapshot: json['has_snapshot'] as bool,
    hasThumbnail: json['has_thumbnail'] as bool,
    hasClip: json['has_clip'] as bool,
    details: json['details'] as Map<String, dynamic>,
    createdAt: EventRead._read_createdAt(json['created_at']),
    updatedAt: EventRead._read_updatedAt(json['updated_at']),
    face: json['face'] == null ? null : FaceRead.fromJson(json['face'] as Map<String, dynamic>),
    acknowledgedAt: EventRead._read_acknowledgedAt(json['acknowledged_at']),
    additionalProperties: EventRead._extras(json, 'additionalProperties') == null
        ? const {}
        : EventRead._readExtras(EventRead._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$EventReadToJson(EventRead instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'camera_uuid': instance.cameraUuid,
  'camera_name': instance.cameraName,
  'kind': ?EventRead._write_kind(instance.kind),
  'source': ?EventRead._write_source(instance.source),
  'source_topic': instance.sourceTopic,
  'label': instance.label,
  'alert': instance.alert,
  'view_uuid': instance.viewUuid,
  'started_at': ?EventRead._write_startedAt(instance.startedAt),
  'ended_at': EventRead._write_endedAt(instance.endedAt),
  'ongoing': instance.ongoing,
  'duration_seconds': instance.durationSeconds,
  'camera_time': EventRead._write_cameraTime(instance.cameraTime),
  'has_snapshot': instance.hasSnapshot,
  'has_thumbnail': instance.hasThumbnail,
  'has_clip': instance.hasClip,
  'details': instance.details,
  'created_at': ?EventRead._write_createdAt(instance.createdAt),
  'updated_at': ?EventRead._write_updatedAt(instance.updatedAt),
  'face': ?instance.face?.toJson(),
  'acknowledged_at': ?EventRead._write_acknowledgedAt(instance.acknowledgedAt),
};
