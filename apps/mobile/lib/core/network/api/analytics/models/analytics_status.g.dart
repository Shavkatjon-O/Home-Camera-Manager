// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalyticsStatus _$AnalyticsStatusFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['pipeline', 'gpu', 'updated_at', 'views'],
    disallowNullValues: const ['gpu', 'views'],
  );
  return AnalyticsStatus(
    pipeline: json['pipeline'] as Map<String, dynamic>?,
    gpu: json['gpu'] as Map<String, dynamic>,
    updatedAt: AnalyticsStatus._read_updatedAt(json['updated_at']),
    views: (json['views'] as Map<String, dynamic>).map(
      (k, e) => MapEntry(k, e as Map<String, dynamic>),
    ),
    additionalProperties: AnalyticsStatus._extras(json, 'additionalProperties') == null
        ? const {}
        : AnalyticsStatus._readExtras(AnalyticsStatus._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$AnalyticsStatusToJson(AnalyticsStatus instance) => <String, dynamic>{
  'pipeline': instance.pipeline,
  'gpu': instance.gpu,
  'updated_at': AnalyticsStatus._write_updatedAt(instance.updatedAt),
  'views': instance.views,
};
