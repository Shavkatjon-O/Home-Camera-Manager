// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_facet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LineFacet _$LineFacetFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'name', 'view'],
    disallowNullValues: const ['id', 'name', 'view'],
  );
  return LineFacet(
    id: json['id'] as String,
    name: json['name'] as String,
    view: json['view'] as String,
    additionalProperties: LineFacet._extras(json, 'additionalProperties') == null
        ? const {}
        : LineFacet._readExtras(LineFacet._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$LineFacetToJson(LineFacet instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'view': instance.view,
};
