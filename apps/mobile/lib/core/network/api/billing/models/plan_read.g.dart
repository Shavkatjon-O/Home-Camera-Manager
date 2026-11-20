// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlanRead _$PlanReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['key', 'name', 'limits', 'features'],
    disallowNullValues: const ['key', 'name', 'limits', 'features'],
  );
  return PlanRead(
    key: json['key'] as String,
    name: json['name'] as String,
    limits: PlanRead._read_limits(json['limits']),
    features: (json['features'] as List<dynamic>)
        .map((e) => e as String)
        .toList(),
    additionalProperties: PlanRead._extras(json, 'additionalProperties') == null
        ? const {}
        : PlanRead._readExtras(PlanRead._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$PlanReadToJson(PlanRead instance) => <String, dynamic>{
  'key': instance.key,
  'name': instance.name,
  'limits': ?PlanRead._write_limits(instance.limits),
  'features': instance.features,
};
