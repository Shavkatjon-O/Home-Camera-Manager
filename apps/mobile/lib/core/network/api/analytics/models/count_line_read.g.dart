// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'count_line_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CountLineRead _$CountLineReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'uuid',
      'name',
      'view_uuid',
      'view_name',
      'camera_uuid',
      'camera_name',
      'direction',
      'enabled',
    ],
    disallowNullValues: const [
      'uuid',
      'name',
      'view_uuid',
      'view_name',
      'camera_uuid',
      'direction',
      'enabled',
    ],
  );
  return CountLineRead(
    uuid: json['uuid'] as String,
    name: json['name'] as String,
    viewUuid: json['view_uuid'] as String,
    viewName: json['view_name'] as String,
    cameraUuid: json['camera_uuid'] as String,
    cameraName: json['camera_name'] as String?,
    direction: json['direction'] as String,
    enabled: json['enabled'] as bool,
    additionalProperties: CountLineRead._extras(json, 'additionalProperties') == null
        ? const {}
        : CountLineRead._readExtras(CountLineRead._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$CountLineReadToJson(CountLineRead instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'name': instance.name,
  'view_uuid': instance.viewUuid,
  'view_name': instance.viewName,
  'camera_uuid': instance.cameraUuid,
  'camera_name': instance.cameraName,
  'direction': instance.direction,
  'enabled': instance.enabled,
};
