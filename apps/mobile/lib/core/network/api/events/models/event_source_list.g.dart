// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_source_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventSourceList _$EventSourceListFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['items'],
    disallowNullValues: const ['items'],
  );
  return EventSourceList(
    items: (json['items'] as List<dynamic>)
        .map((e) => EventSourceRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    additionalProperties:
        EventSourceList._extras(json, 'additionalProperties') == null
        ? const {}
        : EventSourceList._readExtras(
            EventSourceList._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$EventSourceListToJson(EventSourceList instance) =>
    <String, dynamic>{'items': instance.items.map((e) => e.toJson()).toList()};
