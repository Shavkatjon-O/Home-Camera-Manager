// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthRead _$HealthReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['status'],
    disallowNullValues: const ['status'],
  );
  return HealthRead(
    status: json['status'] as String,
    additionalProperties:
        HealthRead._extras(json, 'additionalProperties') == null
        ? const {}
        : HealthRead._readExtras(
            HealthRead._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$HealthReadToJson(HealthRead instance) =>
    <String, dynamic>{'status': instance.status};
