// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usage_total.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UsageTotal _$UsageTotalFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['metric', 'value'],
    disallowNullValues: const ['metric', 'value'],
  );
  return UsageTotal(
    metric: json['metric'] as String,
    value: json['value'] as num,
    additionalProperties: UsageTotal._extras(json, 'additionalProperties') == null
        ? const {}
        : UsageTotal._readExtras(UsageTotal._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$UsageTotalToJson(UsageTotal instance) => <String, dynamic>{
  'metric': instance.metric,
  'value': instance.value,
};
