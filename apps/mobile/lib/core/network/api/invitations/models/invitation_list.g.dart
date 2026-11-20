// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitation_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvitationList _$InvitationListFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['items'], disallowNullValues: const ['items']);
  return InvitationList(
    items: (json['items'] as List<dynamic>)
        .map((e) => InvitationRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    additionalProperties: InvitationList._extras(json, 'additionalProperties') == null
        ? const {}
        : InvitationList._readExtras(InvitationList._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$InvitationListToJson(InvitationList instance) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
};
