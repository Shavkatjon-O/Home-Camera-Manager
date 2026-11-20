// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'similar_appearance_query.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SimilarAppearanceQuery _$SimilarAppearanceQueryFromJson(
  Map<String, dynamic> json,
) {
  $checkKeys(json, disallowNullValues: const ['limit']);
  return SimilarAppearanceQuery(
    eventUuid: json['event_uuid'] as String?,
    appearanceUuid: json['appearance_uuid'] as String?,
    start: SimilarAppearanceQuery._read_start(json['start']),
    end: SimilarAppearanceQuery._read_end(json['end']),
    limit: SimilarAppearanceQuery._presentValue(json, 'limit') == null
        ? 20
        : SimilarAppearanceQuery._read_limit(
            SimilarAppearanceQuery._presentValue(json, 'limit') as Object,
          ),
    additionalProperties:
        SimilarAppearanceQuery._extras(json, 'additionalProperties') == null
        ? const {}
        : SimilarAppearanceQuery._readExtras(
            SimilarAppearanceQuery._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$SimilarAppearanceQueryToJson(
  SimilarAppearanceQuery instance,
) => <String, dynamic>{
  'event_uuid': ?instance.eventUuid,
  'appearance_uuid': ?instance.appearanceUuid,
  'start': ?SimilarAppearanceQuery._write_start(instance.start),
  'end': ?SimilarAppearanceQuery._write_end(instance.end),
  'limit': ?SimilarAppearanceQuery._write_limit(instance.limit),
};
