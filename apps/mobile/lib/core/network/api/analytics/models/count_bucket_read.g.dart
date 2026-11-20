// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'count_bucket_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CountBucketRead _$CountBucketReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['line_uuid', 'at', 'label', 'in', 'out'],
    disallowNullValues: const ['line_uuid', 'at', 'label', 'in', 'out'],
  );
  return CountBucketRead(
    lineUuid: json['line_uuid'] as String,
    at: CountBucketRead._read_at(json['at']),
    label: json['label'] as String,
    in2: CountBucketRead._read_in2(json['in']),
    out: CountBucketRead._read_out(json['out']),
    additionalProperties: CountBucketRead._extras(json, 'additionalProperties') == null
        ? const {}
        : CountBucketRead._readExtras(CountBucketRead._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$CountBucketReadToJson(CountBucketRead instance) => <String, dynamic>{
  'line_uuid': instance.lineUuid,
  'at': ?CountBucketRead._write_at(instance.at),
  'label': instance.label,
  'in': ?CountBucketRead._write_in2(instance.in2),
  'out': ?CountBucketRead._write_out(instance.out),
};
