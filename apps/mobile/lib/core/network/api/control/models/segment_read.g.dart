// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'segment_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SegmentRead _$SegmentReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['start', 'end'],
    disallowNullValues: const ['start', 'end'],
  );
  return SegmentRead(
    start: SegmentRead._read_start(json['start']),
    end: SegmentRead._read_end(json['end']),
    additionalProperties:
        SegmentRead._extras(json, 'additionalProperties') == null
        ? const {}
        : SegmentRead._readExtras(
            SegmentRead._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$SegmentReadToJson(SegmentRead instance) =>
    <String, dynamic>{
      'start': ?SegmentRead._write_start(instance.start),
      'end': ?SegmentRead._write_end(instance.end),
    };
