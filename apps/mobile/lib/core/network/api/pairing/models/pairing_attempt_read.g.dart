// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing_attempt_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PairingAttemptRead _$PairingAttemptReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'uuid',
      'method',
      'adapter',
      'last_step',
      'outcome',
      'error_code',
      'duration_ms',
      'created_at',
    ],
    disallowNullValues: const [
      'uuid',
      'method',
      'last_step',
      'outcome',
      'duration_ms',
      'created_at',
    ],
  );
  return PairingAttemptRead(
    uuid: json['uuid'] as String,
    method: PairingAttemptRead._read_method(json['method']),
    adapter: json['adapter'] as String?,
    lastStep: json['last_step'] as String,
    outcome: PairingAttemptRead._read_outcome(json['outcome']),
    errorCode: json['error_code'] as String?,
    durationMs: PairingAttemptRead._read_durationMs(json['duration_ms']),
    createdAt: PairingAttemptRead._read_createdAt(json['created_at']),
    additionalProperties:
        PairingAttemptRead._extras(json, 'additionalProperties') == null
        ? const {}
        : PairingAttemptRead._readExtras(
            PairingAttemptRead._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$PairingAttemptReadToJson(PairingAttemptRead instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'method': ?PairingAttemptRead._write_method(instance.method),
      'adapter': instance.adapter,
      'last_step': instance.lastStep,
      'outcome': ?PairingAttemptRead._write_outcome(instance.outcome),
      'error_code': instance.errorCode,
      'duration_ms': ?PairingAttemptRead._write_durationMs(instance.durationMs),
      'created_at': ?PairingAttemptRead._write_createdAt(instance.createdAt),
    };
