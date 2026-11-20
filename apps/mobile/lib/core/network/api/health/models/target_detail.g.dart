// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'target_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TargetDetail _$TargetDetailFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['range', 'since', 'until', 'bucket_seconds', 'interval_seconds', 'target'],
    disallowNullValues: const [
      'range',
      'since',
      'until',
      'bucket_seconds',
      'interval_seconds',
      'target',
    ],
  );
  return TargetDetail(
    range: TargetDetail._read_range(json['range']),
    since: TargetDetail._read_since(json['since']),
    until: TargetDetail._read_until(json['until']),
    bucketSeconds: TargetDetail._read_bucketSeconds(json['bucket_seconds']),
    intervalSeconds: TargetDetail._read_intervalSeconds(json['interval_seconds']),
    target: TargetHealth.fromJson(json['target'] as Map<String, dynamic>),
    additionalProperties: TargetDetail._extras(json, 'additionalProperties') == null
        ? const {}
        : TargetDetail._readExtras(TargetDetail._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$TargetDetailToJson(TargetDetail instance) => <String, dynamic>{
  'range': ?TargetDetail._write_range(instance.range),
  'since': ?TargetDetail._write_since(instance.since),
  'until': ?TargetDetail._write_until(instance.until),
  'bucket_seconds': ?TargetDetail._write_bucketSeconds(instance.bucketSeconds),
  'interval_seconds': ?TargetDetail._write_intervalSeconds(instance.intervalSeconds),
  'target': instance.target.toJson(),
};
