// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoRead _$VideoReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['camera_uuid', 'supported'],
    disallowNullValues: const ['camera_uuid', 'supported', 'encoders'],
  );
  return VideoRead(
    cameraUuid: json['camera_uuid'] as String,
    supported: json['supported'] as bool,
    reason: json['reason'] as String?,
    service: json['service'] as String?,
    encoders: VideoRead._presentValue(json, 'encoders') == null
        ? const []
        : VideoRead._read_encoders(
            VideoRead._presentValue(json, 'encoders') as Object,
          ),
    additionalProperties:
        VideoRead._extras(json, 'additionalProperties') == null
        ? const {}
        : VideoRead._readExtras(
            VideoRead._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$VideoReadToJson(VideoRead instance) => <String, dynamic>{
  'camera_uuid': instance.cameraUuid,
  'supported': instance.supported,
  'reason': ?instance.reason,
  'service': ?instance.service,
  'encoders': ?VideoRead._write_encoders(instance.encoders),
};
