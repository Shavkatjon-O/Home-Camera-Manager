// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'motion_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MotionUpdate _$MotionUpdateFromJson(Map<String, dynamic> json) => MotionUpdate(
  sensitivity: MotionUpdate._read_sensitivity(json['sensitivity']),
  enabled: json['enabled'] as bool?,
  additionalProperties: MotionUpdate._extras(json, 'additionalProperties') == null
      ? const {}
      : MotionUpdate._readExtras(MotionUpdate._extras(json, 'additionalProperties')),
);

Map<String, dynamic> _$MotionUpdateToJson(MotionUpdate instance) => <String, dynamic>{
  'sensitivity': ?MotionUpdate._write_sensitivity(instance.sensitivity),
  'enabled': ?instance.enabled,
};
