// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_bucket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthBucket _$HealthBucketFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['start', 'samples', 'availability', 'latency_ms'],
    disallowNullValues: const ['start', 'samples'],
  );
  return HealthBucket(
    start: HealthBucket._read_start(json['start']),
    samples: HealthBucket._read_samples(json['samples']),
    availability: json['availability'] as num?,
    latencyMs: json['latency_ms'] as num?,
    additionalProperties:
        HealthBucket._extras(json, 'additionalProperties') == null
        ? const {}
        : HealthBucket._readExtras(
            HealthBucket._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$HealthBucketToJson(HealthBucket instance) =>
    <String, dynamic>{
      'start': ?HealthBucket._write_start(instance.start),
      'samples': ?HealthBucket._write_samples(instance.samples),
      'availability': instance.availability,
      'latency_ms': instance.latencyMs,
    };
