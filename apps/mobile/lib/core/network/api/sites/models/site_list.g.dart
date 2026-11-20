// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SiteList _$SiteListFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['items'],
    disallowNullValues: const ['items'],
  );
  return SiteList(
    items: (json['items'] as List<dynamic>)
        .map((e) => SiteRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    additionalProperties: SiteList._extras(json, 'additionalProperties') == null
        ? const {}
        : SiteList._readExtras(SiteList._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$SiteListToJson(SiteList instance) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
};
