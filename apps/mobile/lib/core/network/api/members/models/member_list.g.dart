// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MemberList _$MemberListFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['items'], disallowNullValues: const ['items']);
  return MemberList(
    items: (json['items'] as List<dynamic>)
        .map((e) => MemberRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    additionalProperties: MemberList._extras(json, 'additionalProperties') == null
        ? const {}
        : MemberList._readExtras(MemberList._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$MemberListToJson(MemberList instance) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
};
