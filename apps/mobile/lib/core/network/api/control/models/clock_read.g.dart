// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clock_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClockRead _$ClockReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'camera_utc',
      'server_utc',
      'offset_seconds',
      'mode',
      'timezone',
      'daylight_savings',
    ],
    disallowNullValues: const ['server_utc'],
  );
  return ClockRead(
    cameraUtc: ClockRead._read_cameraUtc(json['camera_utc']),
    serverUtc: ClockRead._read_serverUtc(json['server_utc']),
    offsetSeconds: json['offset_seconds'] as num?,
    mode: json['mode'] as String?,
    timezone: json['timezone'] as String?,
    daylightSavings: json['daylight_savings'] as bool?,
    additionalProperties:
        ClockRead._extras(json, 'additionalProperties') == null
        ? const {}
        : ClockRead._readExtras(
            ClockRead._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$ClockReadToJson(ClockRead instance) => <String, dynamic>{
  'camera_utc': ClockRead._write_cameraUtc(instance.cameraUtc),
  'server_utc': ?ClockRead._write_serverUtc(instance.serverUtc),
  'offset_seconds': instance.offsetSeconds,
  'mode': instance.mode,
  'timezone': instance.timezone,
  'daylight_savings': instance.daylightSavings,
};
