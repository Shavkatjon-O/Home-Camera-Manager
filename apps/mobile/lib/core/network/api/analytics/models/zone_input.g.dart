// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zone_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ZoneInput _$ZoneInputFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['name'],
    disallowNullValues: const [
      'name',
      'polygon',
      'whole_view',
      'labels',
      'min_dwell',
      'loiter_seconds',
      'crowd_count',
      'schedule',
      'alert',
      'enabled',
      'left_seconds',
      'taken_seconds',
      'object_labels',
      'background',
      'animals',
    ],
  );
  return ZoneInput(
    uuid: json['uuid'] as String?,
    name: json['name'] as String,
    polygon: ZoneInput._read_polygon(json['polygon']),
    wholeView: ZoneInput._presentValue(json, 'whole_view') == null
        ? false
        : ZoneInput._read_wholeView(
            ZoneInput._presentValue(json, 'whole_view') as Object,
          ),
    labels: (json['labels'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    minDwell: ZoneInput._presentValue(json, 'min_dwell') == null
        ? 1.0
        : ZoneInput._read_minDwell(
            ZoneInput._presentValue(json, 'min_dwell') as Object,
          ),
    loiterSeconds: ZoneInput._presentValue(json, 'loiter_seconds') == null
        ? 0.0
        : ZoneInput._read_loiterSeconds(
            ZoneInput._presentValue(json, 'loiter_seconds') as Object,
          ),
    crowdCount: ZoneInput._presentValue(json, 'crowd_count') == null
        ? 0
        : ZoneInput._read_crowdCount(
            ZoneInput._presentValue(json, 'crowd_count') as Object,
          ),
    schedule: (json['schedule'] as List<dynamic>?)
        ?.map((e) => Window.fromJson(e as Map<String, dynamic>))
        .toList(),
    alert: json['alert'] == null
        ? null
        : AlertPolicy.fromJson(json['alert'] as Map<String, dynamic>),
    enabled: ZoneInput._presentValue(json, 'enabled') == null
        ? true
        : ZoneInput._read_enabled(
            ZoneInput._presentValue(json, 'enabled') as Object,
          ),
    reference: json['reference'] as String?,
    leftSeconds: ZoneInput._presentValue(json, 'left_seconds') == null
        ? 0.0
        : ZoneInput._read_leftSeconds(
            ZoneInput._presentValue(json, 'left_seconds') as Object,
          ),
    takenSeconds: ZoneInput._presentValue(json, 'taken_seconds') == null
        ? 0.0
        : ZoneInput._read_takenSeconds(
            ZoneInput._presentValue(json, 'taken_seconds') as Object,
          ),
    objectLabels: (json['object_labels'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    background: ZoneInput._presentValue(json, 'background') == null
        ? false
        : ZoneInput._read_background(
            ZoneInput._presentValue(json, 'background') as Object,
          ),
    animals: ZoneInput._presentValue(json, 'animals') == null
        ? AnimalMode.record
        : ZoneInput._read_animals(
            ZoneInput._presentValue(json, 'animals') as Object,
          ),
    additionalProperties:
        ZoneInput._extras(json, 'additionalProperties') == null
        ? const {}
        : ZoneInput._readExtras(
            ZoneInput._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$ZoneInputToJson(ZoneInput instance) => <String, dynamic>{
  'uuid': ?instance.uuid,
  'name': instance.name,
  'polygon': ?ZoneInput._write_polygon(instance.polygon),
  'whole_view': ?ZoneInput._write_wholeView(instance.wholeView),
  'labels': ?instance.labels,
  'min_dwell': ?ZoneInput._write_minDwell(instance.minDwell),
  'loiter_seconds': ?ZoneInput._write_loiterSeconds(instance.loiterSeconds),
  'crowd_count': ?ZoneInput._write_crowdCount(instance.crowdCount),
  'schedule': ?instance.schedule?.map((e) => e.toJson()).toList(),
  'alert': ?instance.alert?.toJson(),
  'enabled': ?ZoneInput._write_enabled(instance.enabled),
  'reference': ?instance.reference,
  'left_seconds': ?ZoneInput._write_leftSeconds(instance.leftSeconds),
  'taken_seconds': ?ZoneInput._write_takenSeconds(instance.takenSeconds),
  'object_labels': ?instance.objectLabels,
  'background': ?ZoneInput._write_background(instance.background),
  'animals': ?ZoneInput._write_animals(instance.animals),
};
