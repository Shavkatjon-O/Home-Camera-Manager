// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceRead _$ServiceReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['service', 'version'],
    disallowNullValues: const ['service', 'version'],
  );
  return ServiceRead(
    service: json['service'] as String,
    version: json['version'] as String,
    additionalProperties:
        ServiceRead._extras(json, 'additionalProperties') == null
        ? const {}
        : ServiceRead._readExtras(
            ServiceRead._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$ServiceReadToJson(ServiceRead instance) =>
    <String, dynamic>{'service': instance.service, 'version': instance.version};
