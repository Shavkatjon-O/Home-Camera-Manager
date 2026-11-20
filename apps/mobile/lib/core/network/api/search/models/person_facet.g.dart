// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person_facet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PersonFacet _$PersonFacetFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['uuid', 'name', 'color'],
    disallowNullValues: const ['uuid', 'name', 'color'],
  );
  return PersonFacet(
    uuid: json['uuid'] as String,
    name: json['name'] as String,
    color: json['color'] as String,
    additionalProperties:
        PersonFacet._extras(json, 'additionalProperties') == null
        ? const {}
        : PersonFacet._readExtras(
            PersonFacet._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$PersonFacetToJson(PersonFacet instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'name': instance.name,
      'color': instance.color,
    };
