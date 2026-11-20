// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_policy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlertPolicy _$AlertPolicyFromJson(Map<String, dynamic> json) {
  $checkKeys(json, disallowNullValues: const ['mode', 'schedule', 'labels']);
  return AlertPolicy(
    mode: AlertPolicy._presentValue(json, 'mode') == null
        ? AlertMode.off
        : AlertPolicy._read_mode(
            AlertPolicy._presentValue(json, 'mode') as Object,
          ),
    schedule: (json['schedule'] as List<dynamic>?)
        ?.map((e) => Window.fromJson(e as Map<String, dynamic>))
        .toList(),
    labels: (json['labels'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    additionalProperties:
        AlertPolicy._extras(json, 'additionalProperties') == null
        ? const {}
        : AlertPolicy._readExtras(
            AlertPolicy._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$AlertPolicyToJson(AlertPolicy instance) =>
    <String, dynamic>{
      'mode': ?AlertPolicy._write_mode(instance.mode),
      'schedule': ?instance.schedule?.map((e) => e.toJson()).toList(),
      'labels': ?instance.labels,
    };
