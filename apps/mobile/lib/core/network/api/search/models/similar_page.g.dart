// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'similar_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SimilarPage _$SimilarPageFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['items', 'total', 'page', 'page_size'],
    disallowNullValues: const ['items', 'total', 'page', 'page_size'],
  );
  return SimilarPage(
    items: (json['items'] as List<dynamic>)
        .map((e) => SimilarRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    total: SimilarPage._read_total(json['total']),
    page: SimilarPage._read_page(json['page']),
    pageSize: SimilarPage._read_pageSize(json['page_size']),
    additionalProperties: SimilarPage._extras(json, 'additionalProperties') == null
        ? const {}
        : SimilarPage._readExtras(SimilarPage._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$SimilarPageToJson(SimilarPage instance) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
  'total': ?SimilarPage._write_total(instance.total),
  'page': ?SimilarPage._write_page(instance.page),
  'page_size': ?SimilarPage._write_pageSize(instance.pageSize),
};
