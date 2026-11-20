// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_device_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetworkDeviceList _$NetworkDeviceListFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['items', 'total', 'page', 'page_size'],
    disallowNullValues: const ['items', 'total', 'page', 'page_size'],
  );
  return NetworkDeviceList(
    items: (json['items'] as List<dynamic>)
        .map((e) => NetworkDeviceRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    total: NetworkDeviceList._read_total(json['total']),
    page: NetworkDeviceList._read_page(json['page']),
    pageSize: NetworkDeviceList._read_pageSize(json['page_size']),
    additionalProperties: NetworkDeviceList._extras(json, 'additionalProperties') == null
        ? const {}
        : NetworkDeviceList._readExtras(NetworkDeviceList._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$NetworkDeviceListToJson(NetworkDeviceList instance) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
  'total': ?NetworkDeviceList._write_total(instance.total),
  'page': ?NetworkDeviceList._write_page(instance.page),
  'page_size': ?NetworkDeviceList._write_pageSize(instance.pageSize),
};
