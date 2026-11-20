// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journey_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JourneyList _$JourneyListFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['items'], disallowNullValues: const ['items']);
  return JourneyList(
    items: (json['items'] as List<dynamic>)
        .map((e) => JourneyRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    additionalProperties: JourneyList._extras(json, 'additionalProperties') == null
        ? const {}
        : JourneyList._readExtras(JourneyList._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$JourneyListToJson(JourneyList instance) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
};
