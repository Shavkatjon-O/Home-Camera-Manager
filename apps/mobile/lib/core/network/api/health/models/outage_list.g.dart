// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outage_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutageList _$OutageListFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['items', 'total', 'page', 'page_size'],
    disallowNullValues: const ['items', 'total', 'page', 'page_size'],
  );
  return OutageList(
    items: (json['items'] as List<dynamic>)
        .map((e) => OutageRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    total: OutageList._read_total(json['total']),
    page: OutageList._read_page(json['page']),
    pageSize: OutageList._read_pageSize(json['page_size']),
    additionalProperties: OutageList._extras(json, 'additionalProperties') == null
        ? const {}
        : OutageList._readExtras(OutageList._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$OutageListToJson(OutageList instance) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
  'total': ?OutageList._write_total(instance.total),
  'page': ?OutageList._write_page(instance.page),
  'page_size': ?OutageList._write_pageSize(instance.pageSize),
};
