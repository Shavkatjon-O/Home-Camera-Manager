// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImageRead _$ImageReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['camera_uuid', 'supported'],
    disallowNullValues: const ['camera_uuid', 'supported'],
  );
  return ImageRead(
    cameraUuid: json['camera_uuid'] as String,
    supported: json['supported'] as bool,
    reason: json['reason'] as String?,
    sourceToken: json['source_token'] as String?,
    settings: json['settings'] == null
        ? null
        : ImageSettings.fromJson(json['settings'] as Map<String, dynamic>),
    options: json['options'] == null
        ? null
        : ImageOptionsRead.fromJson(json['options'] as Map<String, dynamic>),
    additionalProperties: ImageRead._extras(json, 'additionalProperties') == null
        ? const {}
        : ImageRead._readExtras(ImageRead._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$ImageReadToJson(ImageRead instance) => <String, dynamic>{
  'camera_uuid': instance.cameraUuid,
  'supported': instance.supported,
  'reason': ?instance.reason,
  'source_token': ?instance.sourceToken,
  'settings': ?instance.settings?.toJson(),
  'options': ?instance.options?.toJson(),
};
