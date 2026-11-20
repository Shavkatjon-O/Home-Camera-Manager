// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'method_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MethodStats _$MethodStatsFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'method',
      'attempts',
      'succeeded',
      'failed',
      'abandoned',
      'success_rate',
      'median_duration_ms',
      'errors',
      'stopped_at',
    ],
    disallowNullValues: const [
      'method',
      'attempts',
      'succeeded',
      'failed',
      'abandoned',
      'success_rate',
      'errors',
      'stopped_at',
    ],
  );
  return MethodStats(
    method: MethodStats._read_method(json['method']),
    attempts: MethodStats._read_attempts(json['attempts']),
    succeeded: MethodStats._read_succeeded(json['succeeded']),
    failed: MethodStats._read_failed(json['failed']),
    abandoned: MethodStats._read_abandoned(json['abandoned']),
    successRate: json['success_rate'] as num,
    medianDurationMs: MethodStats._read_medianDurationMs(json['median_duration_ms']),
    errors: (json['errors'] as List<dynamic>)
        .map((e) => StatCount.fromJson(e as Map<String, dynamic>))
        .toList(),
    stoppedAt: (json['stopped_at'] as List<dynamic>)
        .map((e) => StatCount.fromJson(e as Map<String, dynamic>))
        .toList(),
    additionalProperties: MethodStats._extras(json, 'additionalProperties') == null
        ? const {}
        : MethodStats._readExtras(MethodStats._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$MethodStatsToJson(MethodStats instance) => <String, dynamic>{
  'method': ?MethodStats._write_method(instance.method),
  'attempts': ?MethodStats._write_attempts(instance.attempts),
  'succeeded': ?MethodStats._write_succeeded(instance.succeeded),
  'failed': ?MethodStats._write_failed(instance.failed),
  'abandoned': ?MethodStats._write_abandoned(instance.abandoned),
  'success_rate': instance.successRate,
  'median_duration_ms': MethodStats._write_medianDurationMs(instance.medianDurationMs),
  'errors': instance.errors.map((e) => e.toJson()).toList(),
  'stopped_at': instance.stoppedAt.map((e) => e.toJson()).toList(),
};
