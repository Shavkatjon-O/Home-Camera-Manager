// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sighting_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SightingRead _$SightingReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'event_uuid',
      'sample_uuid',
      'camera_uuid',
      'camera_name',
      'view_name',
      'seen_at',
      'confidence',
    ],
    disallowNullValues: const ['sample_uuid', 'seen_at'],
  );
  return SightingRead(
    eventUuid: json['event_uuid'] as String?,
    sampleUuid: json['sample_uuid'] as String,
    cameraUuid: json['camera_uuid'] as String?,
    cameraName: json['camera_name'] as String?,
    viewName: json['view_name'] as String?,
    seenAt: SightingRead._read_seenAt(json['seen_at']),
    confidence: json['confidence'] as num?,
    additionalProperties: SightingRead._extras(json, 'additionalProperties') == null
        ? const {}
        : SightingRead._readExtras(SightingRead._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$SightingReadToJson(SightingRead instance) => <String, dynamic>{
  'event_uuid': instance.eventUuid,
  'sample_uuid': instance.sampleUuid,
  'camera_uuid': instance.cameraUuid,
  'camera_name': instance.cameraName,
  'view_name': instance.viewName,
  'seen_at': ?SightingRead._write_seenAt(instance.seenAt),
  'confidence': instance.confidence,
};
