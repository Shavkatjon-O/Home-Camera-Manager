// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'similar_query.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SimilarQuery _$SimilarQueryFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const ['sample', 'event', 'photo', 'page', 'page_size'],
    disallowNullValues: const ['page', 'page_size'],
  );
  return SimilarQuery(
    sample: json['sample'] as String?,
    event: json['event'] as String?,
    photo: json['photo'] as String?,
    page: SimilarQuery._presentValue(json, 'page') == null
        ? 1
        : SimilarQuery._read_page(
            SimilarQuery._presentValue(json, 'page') as Object,
          ),
    pageSize: SimilarQuery._presentValue(json, 'page_size') == null
        ? 50
        : SimilarQuery._read_pageSize(
            SimilarQuery._presentValue(json, 'page_size') as Object,
          ),
  );
}

Map<String, dynamic> _$SimilarQueryToJson(SimilarQuery instance) =>
    <String, dynamic>{
      'sample': ?instance.sample,
      'event': ?instance.event,
      'photo': ?instance.photo,
      'page': ?SimilarQuery._write_page(instance.page),
      'page_size': ?SimilarQuery._write_pageSize(instance.pageSize),
    };
