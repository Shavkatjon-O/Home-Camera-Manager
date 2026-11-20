// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PersonList _$PersonListFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['items', 'total', 'page', 'page_size'],
    disallowNullValues: const ['items', 'total', 'page', 'page_size'],
  );
  return PersonList(
    items: (json['items'] as List<dynamic>)
        .map((e) => PersonRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    total: PersonList._read_total(json['total']),
    page: PersonList._read_page(json['page']),
    pageSize: PersonList._read_pageSize(json['page_size']),
    additionalProperties: PersonList._extras(json, 'additionalProperties') == null
        ? const {}
        : PersonList._readExtras(PersonList._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$PersonListToJson(PersonList instance) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
  'total': ?PersonList._write_total(instance.total),
  'page': ?PersonList._write_page(instance.page),
  'page_size': ?PersonList._write_pageSize(instance.pageSize),
};
