// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'view_facet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ViewFacet _$ViewFacetFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'name', 'camera_uuid'],
    disallowNullValues: const ['id', 'name', 'camera_uuid'],
  );
  return ViewFacet(
    id: json['id'] as String,
    name: json['name'] as String,
    cameraUuid: json['camera_uuid'] as String,
    additionalProperties:
        ViewFacet._extras(json, 'additionalProperties') == null
        ? const {}
        : ViewFacet._readExtras(
            ViewFacet._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$ViewFacetToJson(ViewFacet instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'camera_uuid': instance.cameraUuid,
};
