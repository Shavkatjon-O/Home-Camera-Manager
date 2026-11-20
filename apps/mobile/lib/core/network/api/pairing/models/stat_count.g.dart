// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stat_count.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatCount _$StatCountFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['value', 'count'],
    disallowNullValues: const ['value', 'count'],
  );
  return StatCount(
    value: json['value'] as String,
    count: StatCount._read_count(json['count']),
    additionalProperties:
        StatCount._extras(json, 'additionalProperties') == null
        ? const {}
        : StatCount._readExtras(
            StatCount._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$StatCountToJson(StatCount instance) => <String, dynamic>{
  'value': instance.value,
  'count': ?StatCount._write_count(instance.count),
};
