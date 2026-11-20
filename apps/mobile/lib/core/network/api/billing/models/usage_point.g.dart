// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usage_point.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UsagePoint _$UsagePointFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['at', 'metric', 'value'],
    disallowNullValues: const ['at', 'metric', 'value'],
  );
  return UsagePoint(
    at: UsagePoint._read_at(json['at']),
    metric: json['metric'] as String,
    value: json['value'] as num,
    additionalProperties: UsagePoint._extras(json, 'additionalProperties') == null
        ? const {}
        : UsagePoint._readExtras(UsagePoint._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$UsagePointToJson(UsagePoint instance) => <String, dynamic>{
  'at': ?UsagePoint._write_at(instance.at),
  'metric': instance.metric,
  'value': instance.value,
};
