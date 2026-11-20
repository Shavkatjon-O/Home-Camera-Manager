// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zone_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ZoneRead _$ZoneReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'uuid',
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
      'reference',
      'suspended',
    ],
    disallowNullValues: const [
      'uuid',
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
      'suspended',
      'left_seconds',
      'taken_seconds',
      'object_labels',
      'background',
      'animals',
    ],
  );
  return ZoneRead(
    uuid: json['uuid'] as String,
    name: json['name'] as String,
    polygon: (json['polygon'] as List<dynamic>)
        .map((e) => (e as List<dynamic>).map((e) => e as num).toList())
        .toList(),
    wholeView: json['whole_view'] as bool,
    labels: (json['labels'] as List<dynamic>).map((e) => e as String).toList(),
    minDwell: json['min_dwell'] as num,
    loiterSeconds: json['loiter_seconds'] as num,
    crowdCount: ZoneRead._read_crowdCount(json['crowd_count']),
    schedule: (json['schedule'] as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .toList(),
    alert: json['alert'] as Map<String, dynamic>,
    enabled: json['enabled'] as bool,
    reference: json['reference'] as String?,
    suspended: json['suspended'] as bool,
    leftSeconds: ZoneRead._presentValue(json, 'left_seconds') == null
        ? 0.0
        : ZoneRead._read_leftSeconds(
            ZoneRead._presentValue(json, 'left_seconds') as Object,
          ),
    takenSeconds: ZoneRead._presentValue(json, 'taken_seconds') == null
        ? 0.0
        : ZoneRead._read_takenSeconds(
            ZoneRead._presentValue(json, 'taken_seconds') as Object,
          ),
    objectLabels: ZoneRead._presentValue(json, 'object_labels') == null
        ? const []
        : ZoneRead._read_objectLabels(
            ZoneRead._presentValue(json, 'object_labels') as Object,
          ),
    background: ZoneRead._presentValue(json, 'background') == null
        ? false
        : ZoneRead._read_background(
            ZoneRead._presentValue(json, 'background') as Object,
          ),
    animals: ZoneRead._presentValue(json, 'animals') == null
        ? AnimalMode.record
        : ZoneRead._read_animals(
            ZoneRead._presentValue(json, 'animals') as Object,
          ),
    additionalProperties: ZoneRead._extras(json, 'additionalProperties') == null
        ? const {}
        : ZoneRead._readExtras(ZoneRead._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$ZoneReadToJson(ZoneRead instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'name': instance.name,
  'polygon': instance.polygon,
  'whole_view': instance.wholeView,
  'labels': instance.labels,
  'min_dwell': instance.minDwell,
  'loiter_seconds': instance.loiterSeconds,
  'crowd_count': ?ZoneRead._write_crowdCount(instance.crowdCount),
  'schedule': instance.schedule,
  'alert': instance.alert,
  'enabled': instance.enabled,
  'reference': instance.reference,
  'suspended': instance.suspended,
  'left_seconds': ?ZoneRead._write_leftSeconds(instance.leftSeconds),
  'taken_seconds': ?ZoneRead._write_takenSeconds(instance.takenSeconds),
  'object_labels': ?ZoneRead._write_objectLabels(instance.objectLabels),
  'background': ?ZoneRead._write_background(instance.background),
  'animals': ?ZoneRead._write_animals(instance.animals),
};
