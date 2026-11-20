// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presets_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PresetsRead _$PresetsReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['camera_uuid', 'supported'],
    disallowNullValues: const ['camera_uuid', 'supported', 'presets', 'home_supported'],
  );
  return PresetsRead(
    cameraUuid: json['camera_uuid'] as String,
    supported: json['supported'] as bool,
    reason: json['reason'] as String?,
    endpoint: json['endpoint'] as String?,
    presets: PresetsRead._presentValue(json, 'presets') == null
        ? const []
        : PresetsRead._read_presets(PresetsRead._presentValue(json, 'presets') as Object),
    maxPresets: PresetsRead._read_maxPresets(json['max_presets']),
    homeSupported: PresetsRead._presentValue(json, 'home_supported') == null
        ? false
        : PresetsRead._read_homeSupported(
            PresetsRead._presentValue(json, 'home_supported') as Object,
          ),
    additionalProperties: PresetsRead._extras(json, 'additionalProperties') == null
        ? const {}
        : PresetsRead._readExtras(PresetsRead._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$PresetsReadToJson(PresetsRead instance) => <String, dynamic>{
  'camera_uuid': instance.cameraUuid,
  'supported': instance.supported,
  'reason': ?instance.reason,
  'endpoint': ?instance.endpoint,
  'presets': ?PresetsRead._write_presets(instance.presets),
  'max_presets': ?PresetsRead._write_maxPresets(instance.maxPresets),
  'home_supported': ?PresetsRead._write_homeSupported(instance.homeSupported),
};
