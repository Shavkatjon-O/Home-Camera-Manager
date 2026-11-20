// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_target_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushTargetList _$PushTargetListFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['items'], disallowNullValues: const ['items']);
  return PushTargetList(
    items: (json['items'] as List<dynamic>)
        .map((e) => PushTargetRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    additionalProperties: PushTargetList._extras(json, 'additionalProperties') == null
        ? const {}
        : PushTargetList._readExtras(PushTargetList._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$PushTargetListToJson(PushTargetList instance) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
};
