// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'extras_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExtrasRead _$ExtrasReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['camera_uuid', 'supported'],
    disallowNullValues: const ['camera_uuid', 'supported', 'light', 'siren'],
  );
  return ExtrasRead(
    cameraUuid: json['camera_uuid'] as String,
    supported: json['supported'] as bool,
    reason: json['reason'] as String?,
    light: ExtrasRead._presentValue(json, 'light') == null
        ? false
        : ExtrasRead._read_light(
            ExtrasRead._presentValue(json, 'light') as Object,
          ),
    siren: ExtrasRead._presentValue(json, 'siren') == null
        ? false
        : ExtrasRead._read_siren(
            ExtrasRead._presentValue(json, 'siren') as Object,
          ),
    additionalProperties:
        ExtrasRead._extras(json, 'additionalProperties') == null
        ? const {}
        : ExtrasRead._readExtras(
            ExtrasRead._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$ExtrasReadToJson(ExtrasRead instance) =>
    <String, dynamic>{
      'camera_uuid': instance.cameraUuid,
      'supported': instance.supported,
      'reason': ?instance.reason,
      'light': ?ExtrasRead._write_light(instance.light),
      'siren': ?ExtrasRead._write_siren(instance.siren),
    };
