// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceList _$DeviceListFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['items'], disallowNullValues: const ['items']);
  return DeviceList(
    items: (json['items'] as List<dynamic>)
        .map((e) => DeviceRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    additionalProperties: DeviceList._extras(json, 'additionalProperties') == null
        ? const {}
        : DeviceList._readExtras(DeviceList._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$DeviceListToJson(DeviceList instance) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
};
