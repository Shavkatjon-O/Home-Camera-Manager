// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LineRead _$LineReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'uuid',
      'name',
      'points',
      'labels',
      'direction',
      'schedule',
      'alert',
      'enabled',
      'reference',
      'suspended',
    ],
    disallowNullValues: const [
      'uuid',
      'name',
      'points',
      'labels',
      'direction',
      'schedule',
      'alert',
      'enabled',
      'suspended',
      'animals',
    ],
  );
  return LineRead(
    uuid: json['uuid'] as String,
    name: json['name'] as String,
    points: (json['points'] as List<dynamic>)
        .map((e) => (e as List<dynamic>).map((e) => e as num).toList())
        .toList(),
    labels: (json['labels'] as List<dynamic>).map((e) => e as String).toList(),
    direction: LineRead._read_direction(json['direction']),
    schedule: (json['schedule'] as List<dynamic>).map((e) => e as Map<String, dynamic>).toList(),
    alert: json['alert'] as Map<String, dynamic>,
    enabled: json['enabled'] as bool,
    reference: json['reference'] as String?,
    suspended: json['suspended'] as bool,
    animals: LineRead._presentValue(json, 'animals') == null
        ? AnimalMode.record
        : LineRead._read_animals(LineRead._presentValue(json, 'animals') as Object),
    additionalProperties: LineRead._extras(json, 'additionalProperties') == null
        ? const {}
        : LineRead._readExtras(LineRead._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$LineReadToJson(LineRead instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'name': instance.name,
  'points': instance.points,
  'labels': instance.labels,
  'direction': ?LineRead._write_direction(instance.direction),
  'schedule': instance.schedule,
  'alert': instance.alert,
  'enabled': instance.enabled,
  'reference': instance.reference,
  'suspended': instance.suspended,
  'animals': ?LineRead._write_animals(instance.animals),
};
