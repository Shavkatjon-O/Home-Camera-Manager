// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'range_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RangeRead _$RangeReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['min', 'max'],
    disallowNullValues: const ['min', 'max'],
  );
  return RangeRead(
    min: json['min'] as num,
    max: json['max'] as num,
    additionalProperties:
        RangeRead._extras(json, 'additionalProperties') == null
        ? const {}
        : RangeRead._readExtras(
            RangeRead._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$RangeReadToJson(RangeRead instance) => <String, dynamic>{
  'min': instance.min,
  'max': instance.max,
};
