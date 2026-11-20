// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionList _$SessionListFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['items'],
    disallowNullValues: const ['items'],
  );
  return SessionList(
    items: (json['items'] as List<dynamic>)
        .map((e) => SessionRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    additionalProperties:
        SessionList._extras(json, 'additionalProperties') == null
        ? const {}
        : SessionList._readExtras(
            SessionList._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$SessionListToJson(SessionList instance) =>
    <String, dynamic>{'items': instance.items.map((e) => e.toJson()).toList()};
