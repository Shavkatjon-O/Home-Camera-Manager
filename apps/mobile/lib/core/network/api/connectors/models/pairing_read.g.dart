// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PairingRead _$PairingReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['uuid', 'name', 'status', 'expires_at', 'connector'],
    disallowNullValues: const ['uuid', 'name', 'status', 'expires_at'],
  );
  return PairingRead(
    uuid: json['uuid'] as String,
    name: json['name'] as String,
    status: PairingRead._read_status(json['status']),
    expiresAt: PairingRead._read_expiresAt(json['expires_at']),
    connector: json['connector'] as String?,
    additionalProperties:
        PairingRead._extras(json, 'additionalProperties') == null
        ? const {}
        : PairingRead._readExtras(
            PairingRead._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$PairingReadToJson(PairingRead instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'name': instance.name,
      'status': ?PairingRead._write_status(instance.status),
      'expires_at': ?PairingRead._write_expiresAt(instance.expiresAt),
      'connector': instance.connector,
    };
