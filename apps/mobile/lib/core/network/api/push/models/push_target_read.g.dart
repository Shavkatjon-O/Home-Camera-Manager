// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_target_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushTargetRead _$PushTargetReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'uuid',
      'provider',
      'token',
      'enabled',
      'last_success_at',
      'last_error',
      'created_at',
    ],
    disallowNullValues: const [
      'uuid',
      'provider',
      'token',
      'enabled',
      'created_at',
    ],
  );
  return PushTargetRead(
    uuid: json['uuid'] as String,
    provider: PushTargetRead._read_provider(json['provider']),
    token: json['token'] as String,
    enabled: json['enabled'] as bool,
    lastSuccessAt: PushTargetRead._read_lastSuccessAt(json['last_success_at']),
    lastError: json['last_error'] as String?,
    createdAt: PushTargetRead._read_createdAt(json['created_at']),
    additionalProperties:
        PushTargetRead._extras(json, 'additionalProperties') == null
        ? const {}
        : PushTargetRead._readExtras(
            PushTargetRead._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$PushTargetReadToJson(PushTargetRead instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'provider': ?PushTargetRead._write_provider(instance.provider),
      'token': instance.token,
      'enabled': instance.enabled,
      'last_success_at': PushTargetRead._write_lastSuccessAt(
        instance.lastSuccessAt,
      ),
      'last_error': instance.lastError,
      'created_at': ?PushTargetRead._write_createdAt(instance.createdAt),
    };
