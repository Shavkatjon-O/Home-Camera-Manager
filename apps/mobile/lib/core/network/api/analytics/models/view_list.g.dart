// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'view_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ViewList _$ViewListFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['items'],
    disallowNullValues: const ['items'],
  );
  return ViewList(
    items: (json['items'] as List<dynamic>)
        .map((e) => ViewRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    additionalProperties: ViewList._extras(json, 'additionalProperties') == null
        ? const {}
        : ViewList._readExtras(ViewList._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$ViewListToJson(ViewList instance) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
};
