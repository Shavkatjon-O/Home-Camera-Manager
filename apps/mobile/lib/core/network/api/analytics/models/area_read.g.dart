// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'area_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AreaRead _$AreaReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'uuid',
      'name',
      'occupancy',
      'entered',
      'exited',
      'since',
      'reset_at',
      'labels',
      'lines',
      'updated_at',
    ],
    disallowNullValues: const [
      'uuid',
      'name',
      'occupancy',
      'entered',
      'exited',
      'since',
      'labels',
      'lines',
      'updated_at',
    ],
  );
  return AreaRead(
    uuid: json['uuid'] as String,
    name: json['name'] as String,
    occupancy: AreaRead._read_occupancy(json['occupancy']),
    entered: AreaRead._read_entered(json['entered']),
    exited: AreaRead._read_exited(json['exited']),
    since: AreaRead._read_since(json['since']),
    resetAt: json['reset_at'] as String?,
    labels: (json['labels'] as List<dynamic>).map((e) => e as String).toList(),
    lines: (json['lines'] as List<dynamic>)
        .map((e) => AreaLineRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    updatedAt: AreaRead._read_updatedAt(json['updated_at']),
    additionalProperties: AreaRead._extras(json, 'additionalProperties') == null
        ? const {}
        : AreaRead._readExtras(AreaRead._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$AreaReadToJson(AreaRead instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'name': instance.name,
  'occupancy': ?AreaRead._write_occupancy(instance.occupancy),
  'entered': ?AreaRead._write_entered(instance.entered),
  'exited': ?AreaRead._write_exited(instance.exited),
  'since': ?AreaRead._write_since(instance.since),
  'reset_at': instance.resetAt,
  'labels': instance.labels,
  'lines': instance.lines.map((e) => e.toJson()).toList(),
  'updated_at': ?AreaRead._write_updatedAt(instance.updatedAt),
};
