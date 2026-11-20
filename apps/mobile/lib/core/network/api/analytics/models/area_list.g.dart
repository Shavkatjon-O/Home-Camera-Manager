// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'area_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AreaList _$AreaListFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['items'], disallowNullValues: const ['items']);
  return AreaList(
    items: (json['items'] as List<dynamic>)
        .map((e) => AreaRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    additionalProperties: AreaList._extras(json, 'additionalProperties') == null
        ? const {}
        : AreaList._readExtras(AreaList._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$AreaListToJson(AreaList instance) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
};
