// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResultPage _$ResultPageFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['items', 'total', 'page', 'page_size'],
    disallowNullValues: const ['items', 'total', 'page', 'page_size'],
  );
  return ResultPage(
    items: (json['items'] as List<dynamic>)
        .map((e) => SearchResult.fromJson(e as Map<String, dynamic>))
        .toList(),
    total: ResultPage._read_total(json['total']),
    page: ResultPage._read_page(json['page']),
    pageSize: ResultPage._read_pageSize(json['page_size']),
    additionalProperties:
        ResultPage._extras(json, 'additionalProperties') == null
        ? const {}
        : ResultPage._readExtras(
            ResultPage._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$ResultPageToJson(ResultPage instance) =>
    <String, dynamic>{
      'items': instance.items.map((e) => e.toJson()).toList(),
      'total': ?ResultPage._write_total(instance.total),
      'page': ?ResultPage._write_page(instance.page),
      'page_size': ?ResultPage._write_pageSize(instance.pageSize),
    };
