// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discovered_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiscoveredList _$DiscoveredListFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['items', 'discovered_at'],
    disallowNullValues: const ['items'],
  );
  return DiscoveredList(
    items: (json['items'] as List<dynamic>)
        .map((e) => DiscoveredRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    discoveredAt: DiscoveredList._read_discoveredAt(json['discovered_at']),
    additionalProperties:
        DiscoveredList._extras(json, 'additionalProperties') == null
        ? const {}
        : DiscoveredList._readExtras(
            DiscoveredList._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$DiscoveredListToJson(
  DiscoveredList instance,
) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
  'discovered_at': DiscoveredList._write_discoveredAt(instance.discoveredAt),
};
