// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'latency_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LatencyStats _$LatencyStatsFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['avg_ms', 'p50_ms', 'p95_ms', 'max_ms'],
  );
  return LatencyStats(
    avgMs: json['avg_ms'] as num?,
    p50Ms: json['p50_ms'] as num?,
    p95Ms: json['p95_ms'] as num?,
    maxMs: json['max_ms'] as num?,
    additionalProperties:
        LatencyStats._extras(json, 'additionalProperties') == null
        ? const {}
        : LatencyStats._readExtras(
            LatencyStats._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$LatencyStatsToJson(LatencyStats instance) =>
    <String, dynamic>{
      'avg_ms': instance.avgMs,
      'p50_ms': instance.p50Ms,
      'p95_ms': instance.p95Ms,
      'max_ms': instance.maxMs,
    };
