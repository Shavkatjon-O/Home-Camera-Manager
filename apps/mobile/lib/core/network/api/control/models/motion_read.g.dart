// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'motion_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MotionRead _$MotionReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['camera_uuid', 'supported'],
    disallowNullValues: const ['camera_uuid', 'supported'],
  );
  return MotionRead(
    cameraUuid: json['camera_uuid'] as String,
    supported: json['supported'] as bool,
    reason: json['reason'] as String?,
    sensitivity: MotionRead._read_sensitivity(json['sensitivity']),
    sensitivityRange: json['sensitivity_range'] == null
        ? null
        : RangeRead.fromJson(json['sensitivity_range'] as Map<String, dynamic>),
    enabled: json['enabled'] as bool?,
    activeCells: MotionRead._read_activeCells(json['active_cells']),
    cells: MotionRead._read_cells(json['cells']),
    additionalProperties: MotionRead._extras(json, 'additionalProperties') == null
        ? const {}
        : MotionRead._readExtras(MotionRead._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$MotionReadToJson(MotionRead instance) => <String, dynamic>{
  'camera_uuid': instance.cameraUuid,
  'supported': instance.supported,
  'reason': ?instance.reason,
  'sensitivity': ?MotionRead._write_sensitivity(instance.sensitivity),
  'sensitivity_range': ?instance.sensitivityRange?.toJson(),
  'enabled': ?instance.enabled,
  'active_cells': ?MotionRead._write_activeCells(instance.activeCells),
  'cells': ?MotionRead._write_cells(instance.cells),
};
