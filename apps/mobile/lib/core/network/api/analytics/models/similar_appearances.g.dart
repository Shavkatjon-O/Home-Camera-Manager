// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'similar_appearances.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SimilarAppearances _$SimilarAppearancesFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['query_uuid', 'items'],
    disallowNullValues: const ['query_uuid', 'items'],
  );
  return SimilarAppearances(
    queryUuid: json['query_uuid'] as String,
    items: (json['items'] as List<dynamic>)
        .map((e) => AppearanceMatch.fromJson(e as Map<String, dynamic>))
        .toList(),
    additionalProperties: SimilarAppearances._extras(json, 'additionalProperties') == null
        ? const {}
        : SimilarAppearances._readExtras(SimilarAppearances._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$SimilarAppearancesToJson(SimilarAppearances instance) => <String, dynamic>{
  'query_uuid': instance.queryUuid,
  'items': instance.items.map((e) => e.toJson()).toList(),
};
