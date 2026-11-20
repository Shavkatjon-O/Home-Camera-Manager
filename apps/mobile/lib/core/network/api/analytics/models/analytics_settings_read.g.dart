// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_settings_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalyticsSettingsRead _$AnalyticsSettingsReadFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['arm_mode'], disallowNullValues: const ['arm_mode']);
  return AnalyticsSettingsRead(
    armMode: AnalyticsSettingsRead._read_armMode(json['arm_mode']),
    additionalProperties: AnalyticsSettingsRead._extras(json, 'additionalProperties') == null
        ? const {}
        : AnalyticsSettingsRead._readExtras(
            AnalyticsSettingsRead._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$AnalyticsSettingsReadToJson(AnalyticsSettingsRead instance) =>
    <String, dynamic>{'arm_mode': ?AnalyticsSettingsRead._write_armMode(instance.armMode)};
