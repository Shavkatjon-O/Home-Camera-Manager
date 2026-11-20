// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventList _$EventListFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['items', 'total', 'page', 'page_size'],
    disallowNullValues: const ['items', 'total', 'page', 'page_size'],
  );
  return EventList(
    items: (json['items'] as List<dynamic>)
        .map((e) => EventRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    total: EventList._read_total(json['total']),
    page: EventList._read_page(json['page']),
    pageSize: EventList._read_pageSize(json['page_size']),
    additionalProperties: EventList._extras(json, 'additionalProperties') == null
        ? const {}
        : EventList._readExtras(EventList._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$EventListToJson(EventList instance) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
  'total': ?EventList._write_total(instance.total),
  'page': ?EventList._write_page(instance.page),
  'page_size': ?EventList._write_pageSize(instance.pageSize),
};
