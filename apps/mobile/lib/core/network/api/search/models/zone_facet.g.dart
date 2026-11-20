// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zone_facet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ZoneFacet _$ZoneFacetFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'name', 'view'],
    disallowNullValues: const ['id', 'name', 'view'],
  );
  return ZoneFacet(
    id: json['id'] as String,
    name: json['name'] as String,
    view: json['view'] as String,
    additionalProperties:
        ZoneFacet._extras(json, 'additionalProperties') == null
        ? const {}
        : ZoneFacet._readExtras(
            ZoneFacet._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$ZoneFacetToJson(ZoneFacet instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'view': instance.view,
};
