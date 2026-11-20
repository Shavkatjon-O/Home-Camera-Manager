// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camera_link_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CameraLinkRead _$CameraLinkReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['camera_uuid', 'parent_uuid', 'parent_name', 'link', 'updated_at'],
    disallowNullValues: const ['camera_uuid'],
  );
  return CameraLinkRead(
    cameraUuid: json['camera_uuid'] as String,
    parentUuid: json['parent_uuid'] as String?,
    parentName: json['parent_name'] as String?,
    link: CameraLinkRead._read_link(json['link']),
    updatedAt: CameraLinkRead._read_updatedAt(json['updated_at']),
    additionalProperties: CameraLinkRead._extras(json, 'additionalProperties') == null
        ? const {}
        : CameraLinkRead._readExtras(CameraLinkRead._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$CameraLinkReadToJson(CameraLinkRead instance) => <String, dynamic>{
  'camera_uuid': instance.cameraUuid,
  'parent_uuid': instance.parentUuid,
  'parent_name': instance.parentName,
  'link': CameraLinkRead._write_link(instance.link),
  'updated_at': CameraLinkRead._write_updatedAt(instance.updatedAt),
};
