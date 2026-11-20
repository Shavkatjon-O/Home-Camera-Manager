// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing_attempt_create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PairingAttemptCreate _$PairingAttemptCreateFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['method', 'last_step', 'outcome'],
    disallowNullValues: const ['method', 'last_step', 'outcome', 'duration_ms'],
  );
  return PairingAttemptCreate(
    method: PairingAttemptCreate._read_method(json['method']),
    adapter: json['adapter'] as String?,
    lastStep: json['last_step'] as String,
    outcome: PairingAttemptCreate._read_outcome(json['outcome']),
    errorCode: json['error_code'] as String?,
    durationMs: PairingAttemptCreate._presentValue(json, 'duration_ms') == null
        ? 0
        : PairingAttemptCreate._read_durationMs(
            PairingAttemptCreate._presentValue(json, 'duration_ms') as Object,
          ),
    additionalProperties:
        PairingAttemptCreate._extras(json, 'additionalProperties') == null
        ? const {}
        : PairingAttemptCreate._readExtras(
            PairingAttemptCreate._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$PairingAttemptCreateToJson(
  PairingAttemptCreate instance,
) => <String, dynamic>{
  'method': ?PairingAttemptCreate._write_method(instance.method),
  'adapter': ?instance.adapter,
  'last_step': instance.lastStep,
  'outcome': ?PairingAttemptCreate._write_outcome(instance.outcome),
  'error_code': ?instance.errorCode,
  'duration_ms': ?PairingAttemptCreate._write_durationMs(instance.durationMs),
};
