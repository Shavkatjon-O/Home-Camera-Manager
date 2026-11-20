// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'counts_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CountsRead _$CountsReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['start', 'end', 'bucket', 'timezone', 'lines', 'buckets', 'totals'],
    disallowNullValues: const ['start', 'end', 'bucket', 'timezone', 'lines', 'buckets', 'totals'],
  );
  return CountsRead(
    start: CountsRead._read_start(json['start']),
    end: CountsRead._read_end(json['end']),
    bucket: CountsRead._read_bucket(json['bucket']),
    timezone: json['timezone'] as String,
    lines: (json['lines'] as List<dynamic>)
        .map((e) => CountLineRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    buckets: (json['buckets'] as List<dynamic>)
        .map((e) => CountBucketRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    totals: (json['totals'] as List<dynamic>)
        .map((e) => CountTotalRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    additionalProperties: CountsRead._extras(json, 'additionalProperties') == null
        ? const {}
        : CountsRead._readExtras(CountsRead._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$CountsReadToJson(CountsRead instance) => <String, dynamic>{
  'start': ?CountsRead._write_start(instance.start),
  'end': ?CountsRead._write_end(instance.end),
  'bucket': ?CountsRead._write_bucket(instance.bucket),
  'timezone': instance.timezone,
  'lines': instance.lines.map((e) => e.toJson()).toList(),
  'buckets': instance.buckets.map((e) => e.toJson()).toList(),
  'totals': instance.totals.map((e) => e.toJson()).toList(),
};
