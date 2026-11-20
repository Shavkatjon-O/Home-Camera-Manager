// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cluster_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClusterList _$ClusterListFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['items', 'total', 'page', 'page_size'],
    disallowNullValues: const ['items', 'total', 'page', 'page_size'],
  );
  return ClusterList(
    items: (json['items'] as List<dynamic>)
        .map((e) => ClusterRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    total: ClusterList._read_total(json['total']),
    page: ClusterList._read_page(json['page']),
    pageSize: ClusterList._read_pageSize(json['page_size']),
    additionalProperties: ClusterList._extras(json, 'additionalProperties') == null
        ? const {}
        : ClusterList._readExtras(ClusterList._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$ClusterListToJson(ClusterList instance) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
  'total': ?ClusterList._write_total(instance.total),
  'page': ?ClusterList._write_page(instance.page),
  'page_size': ?ClusterList._write_pageSize(instance.pageSize),
};
