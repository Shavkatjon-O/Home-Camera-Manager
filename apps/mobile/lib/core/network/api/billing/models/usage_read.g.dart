// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usage_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UsageRead _$UsageReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['since', 'bucket', 'totals', 'series'],
    disallowNullValues: const ['since', 'bucket', 'totals', 'series'],
  );
  return UsageRead(
    since: UsageRead._read_since(json['since']),
    bucket: json['bucket'] as String,
    totals: (json['totals'] as List<dynamic>)
        .map((e) => UsageTotal.fromJson(e as Map<String, dynamic>))
        .toList(),
    series: (json['series'] as List<dynamic>)
        .map((e) => UsagePoint.fromJson(e as Map<String, dynamic>))
        .toList(),
    additionalProperties:
        UsageRead._extras(json, 'additionalProperties') == null
        ? const {}
        : UsageRead._readExtras(
            UsageRead._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$UsageReadToJson(UsageRead instance) => <String, dynamic>{
  'since': ?UsageRead._write_since(instance.since),
  'bucket': instance.bucket,
  'totals': instance.totals.map((e) => e.toJson()).toList(),
  'series': instance.series.map((e) => e.toJson()).toList(),
};
