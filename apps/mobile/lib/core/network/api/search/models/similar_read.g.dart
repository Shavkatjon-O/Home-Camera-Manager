// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'similar_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SimilarRead _$SimilarReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'sample_uuid',
      'score',
      'source',
      'seen_at',
      'has_crop',
      'person_uuid',
      'person_name',
      'person_color',
      'cluster_uuid',
      'cluster_label',
      'event_uuid',
      'camera_uuid',
      'camera_name',
      'view_name',
    ],
    disallowNullValues: const ['sample_uuid', 'score', 'source', 'seen_at', 'has_crop'],
  );
  return SimilarRead(
    sampleUuid: json['sample_uuid'] as String,
    score: json['score'] as num,
    source: SimilarRead._read_source(json['source']),
    seenAt: SimilarRead._read_seenAt(json['seen_at']),
    hasCrop: json['has_crop'] as bool,
    personUuid: json['person_uuid'] as String?,
    personName: json['person_name'] as String?,
    personColor: json['person_color'] as String?,
    clusterUuid: json['cluster_uuid'] as String?,
    clusterLabel: json['cluster_label'] as String?,
    eventUuid: json['event_uuid'] as String?,
    cameraUuid: json['camera_uuid'] as String?,
    cameraName: json['camera_name'] as String?,
    viewName: json['view_name'] as String?,
    additionalProperties: SimilarRead._extras(json, 'additionalProperties') == null
        ? const {}
        : SimilarRead._readExtras(SimilarRead._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$SimilarReadToJson(SimilarRead instance) => <String, dynamic>{
  'sample_uuid': instance.sampleUuid,
  'score': instance.score,
  'source': ?SimilarRead._write_source(instance.source),
  'seen_at': ?SimilarRead._write_seenAt(instance.seenAt),
  'has_crop': instance.hasCrop,
  'person_uuid': instance.personUuid,
  'person_name': instance.personName,
  'person_color': instance.personColor,
  'cluster_uuid': instance.clusterUuid,
  'cluster_label': instance.clusterLabel,
  'event_uuid': instance.eventUuid,
  'camera_uuid': instance.cameraUuid,
  'camera_name': instance.cameraName,
  'view_name': instance.viewName,
};
