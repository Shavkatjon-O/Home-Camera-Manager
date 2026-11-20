// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camera_link_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CameraLinkUpdate _$CameraLinkUpdateFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['parent_uuid']);
  return CameraLinkUpdate(
    parentUuid: json['parent_uuid'] as String?,
    link: CameraLinkUpdate._read_link(json['link']),
    additionalProperties: CameraLinkUpdate._extras(json, 'additionalProperties') == null
        ? const {}
        : CameraLinkUpdate._readExtras(CameraLinkUpdate._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$CameraLinkUpdateToJson(CameraLinkUpdate instance) => <String, dynamic>{
  'parent_uuid': instance.parentUuid,
  'link': ?CameraLinkUpdate._write_link(instance.link),
};
