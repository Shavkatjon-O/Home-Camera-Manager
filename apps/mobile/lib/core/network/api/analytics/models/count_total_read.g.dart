// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'count_total_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CountTotalRead _$CountTotalReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['line_uuid', 'in', 'out', 'labels'],
    disallowNullValues: const ['line_uuid', 'in', 'out', 'labels'],
  );
  return CountTotalRead(
    lineUuid: json['line_uuid'] as String,
    in2: CountTotalRead._read_in2(json['in']),
    out: CountTotalRead._read_out(json['out']),
    labels: CountTotalRead._read_labels(json['labels']),
    additionalProperties:
        CountTotalRead._extras(json, 'additionalProperties') == null
        ? const {}
        : CountTotalRead._readExtras(
            CountTotalRead._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$CountTotalReadToJson(CountTotalRead instance) =>
    <String, dynamic>{
      'line_uuid': instance.lineUuid,
      'in': ?CountTotalRead._write_in2(instance.in2),
      'out': ?CountTotalRead._write_out(instance.out),
      'labels': ?CountTotalRead._write_labels(instance.labels),
    };
