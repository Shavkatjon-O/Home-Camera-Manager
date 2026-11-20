// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AudioRead _$AudioReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['camera_uuid', 'supported'],
    disallowNullValues: const ['camera_uuid', 'supported'],
  );
  return AudioRead(
    cameraUuid: json['camera_uuid'] as String,
    supported: json['supported'] as bool,
    reason: json['reason'] as String?,
    codec: json['codec'] as String?,
    additionalProperties:
        AudioRead._extras(json, 'additionalProperties') == null
        ? const {}
        : AudioRead._readExtras(
            AudioRead._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$AudioReadToJson(AudioRead instance) => <String, dynamic>{
  'camera_uuid': instance.cameraUuid,
  'supported': instance.supported,
  'reason': ?instance.reason,
  'codec': ?instance.codec,
};
