// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionRead _$SessionReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'uuid',
      'name',
      'platform',
      'created_at',
      'last_used_at',
      'expires_at',
      'current',
    ],
    disallowNullValues: const [
      'uuid',
      'name',
      'platform',
      'created_at',
      'last_used_at',
      'expires_at',
      'current',
    ],
  );
  return SessionRead(
    uuid: json['uuid'] as String,
    name: json['name'] as String,
    platform: json['platform'] as String,
    createdAt: SessionRead._read_createdAt(json['created_at']),
    lastUsedAt: SessionRead._read_lastUsedAt(json['last_used_at']),
    expiresAt: SessionRead._read_expiresAt(json['expires_at']),
    current: json['current'] as bool,
    additionalProperties: SessionRead._extras(json, 'additionalProperties') == null
        ? const {}
        : SessionRead._readExtras(SessionRead._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$SessionReadToJson(SessionRead instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'name': instance.name,
  'platform': instance.platform,
  'created_at': ?SessionRead._write_createdAt(instance.createdAt),
  'last_used_at': ?SessionRead._write_lastUsedAt(instance.lastUsedAt),
  'expires_at': ?SessionRead._write_expiresAt(instance.expiresAt),
  'current': instance.current,
};
