// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing_method_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PairingMethodList _$PairingMethodListFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['items', 'connectors', 'direct'],
    disallowNullValues: const ['items', 'connectors', 'direct'],
  );
  return PairingMethodList(
    items: (json['items'] as List<dynamic>)
        .map((e) => PairingMethod.fromJson(e as Map<String, dynamic>))
        .toList(),
    connectors: (json['connectors'] as List<dynamic>)
        .map((e) => e as String)
        .toList(),
    direct: json['direct'] as bool,
    additionalProperties:
        PairingMethodList._extras(json, 'additionalProperties') == null
        ? const {}
        : PairingMethodList._readExtras(
            PairingMethodList._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$PairingMethodListToJson(PairingMethodList instance) =>
    <String, dynamic>{
      'items': instance.items.map((e) => e.toJson()).toList(),
      'connectors': instance.connectors,
      'direct': instance.direct,
    };
