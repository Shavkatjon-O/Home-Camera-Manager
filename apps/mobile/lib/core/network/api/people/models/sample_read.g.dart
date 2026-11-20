// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sample_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SampleRead _$SampleReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'uuid',
      'source',
      'quality',
      'confidence',
      'seen_at',
      'has_crop',
      'event_uuid',
      'camera_uuid',
      'camera_name',
      'view_name',
    ],
    disallowNullValues: const [
      'uuid',
      'source',
      'quality',
      'seen_at',
      'has_crop',
    ],
  );
  return SampleRead(
    uuid: json['uuid'] as String,
    source: SampleRead._read_source(json['source']),
    quality: json['quality'] as num,
    confidence: json['confidence'] as num?,
    seenAt: SampleRead._read_seenAt(json['seen_at']),
    hasCrop: json['has_crop'] as bool,
    eventUuid: json['event_uuid'] as String?,
    cameraUuid: json['camera_uuid'] as String?,
    cameraName: json['camera_name'] as String?,
    viewName: json['view_name'] as String?,
    additionalProperties:
        SampleRead._extras(json, 'additionalProperties') == null
        ? const {}
        : SampleRead._readExtras(
            SampleRead._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$SampleReadToJson(SampleRead instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'source': ?SampleRead._write_source(instance.source),
      'quality': instance.quality,
      'confidence': instance.confidence,
      'seen_at': ?SampleRead._write_seenAt(instance.seenAt),
      'has_crop': instance.hasCrop,
      'event_uuid': instance.eventUuid,
      'camera_uuid': instance.cameraUuid,
      'camera_name': instance.cameraName,
      'view_name': instance.viewName,
    };
