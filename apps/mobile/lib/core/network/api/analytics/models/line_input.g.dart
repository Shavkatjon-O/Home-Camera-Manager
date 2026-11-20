// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LineInput _$LineInputFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['name', 'points'],
    disallowNullValues: const [
      'name',
      'labels',
      'direction',
      'schedule',
      'alert',
      'enabled',
      'animals',
    ],
  );
  return LineInput(
    uuid: json['uuid'] as String?,
    name: json['name'] as String,
    points: LineInput._read_points(json['points']),
    labels: (json['labels'] as List<dynamic>?)?.map((e) => e as String).toList(),
    direction: LineInput._presentValue(json, 'direction') == null
        ? LineDirection.both
        : LineInput._read_direction(LineInput._presentValue(json, 'direction') as Object),
    schedule: (json['schedule'] as List<dynamic>?)
        ?.map((e) => Window.fromJson(e as Map<String, dynamic>))
        .toList(),
    alert: json['alert'] == null
        ? null
        : AlertPolicy.fromJson(json['alert'] as Map<String, dynamic>),
    enabled: LineInput._presentValue(json, 'enabled') == null
        ? true
        : LineInput._read_enabled(LineInput._presentValue(json, 'enabled') as Object),
    reference: json['reference'] as String?,
    animals: LineInput._presentValue(json, 'animals') == null
        ? AnimalMode.record
        : LineInput._read_animals(LineInput._presentValue(json, 'animals') as Object),
    additionalProperties: LineInput._extras(json, 'additionalProperties') == null
        ? const {}
        : LineInput._readExtras(LineInput._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$LineInputToJson(LineInput instance) => <String, dynamic>{
  'uuid': ?instance.uuid,
  'name': instance.name,
  'points': LineInput._write_points(instance.points),
  'labels': ?instance.labels,
  'direction': ?LineInput._write_direction(instance.direction),
  'schedule': ?instance.schedule?.map((e) => e.toJson()).toList(),
  'alert': ?instance.alert?.toJson(),
  'enabled': ?LineInput._write_enabled(instance.enabled),
  'reference': ?instance.reference,
  'animals': ?LineInput._write_animals(instance.animals),
};
