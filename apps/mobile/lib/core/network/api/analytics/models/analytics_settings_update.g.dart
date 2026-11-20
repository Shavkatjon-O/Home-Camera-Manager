// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_settings_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalyticsSettingsUpdate _$AnalyticsSettingsUpdateFromJson(
  Map<String, dynamic> json,
) {
  $checkKeys(
    json,
    requiredKeys: const ['arm_mode'],
    disallowNullValues: const ['arm_mode'],
  );
  return AnalyticsSettingsUpdate(
    armMode: AnalyticsSettingsUpdate._read_armMode(json['arm_mode']),
    additionalProperties:
        AnalyticsSettingsUpdate._extras(json, 'additionalProperties') == null
        ? const {}
        : AnalyticsSettingsUpdate._readExtras(
            AnalyticsSettingsUpdate._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$AnalyticsSettingsUpdateToJson(
  AnalyticsSettingsUpdate instance,
) => <String, dynamic>{
  'arm_mode': ?AnalyticsSettingsUpdate._write_armMode(instance.armMode),
};
