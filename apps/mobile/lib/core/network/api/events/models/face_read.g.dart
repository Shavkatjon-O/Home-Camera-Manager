// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'face_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FaceRead _$FaceReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'status',
      'person_uuid',
      'person_name',
      'person_color',
      'cluster_uuid',
      'cluster_label',
      'confidence',
      'sample_uuid',
      'has_crop',
    ],
    disallowNullValues: const ['status', 'has_crop'],
  );
  return FaceRead(
    status: FaceRead._read_status(json['status']),
    personUuid: json['person_uuid'] as String?,
    personName: json['person_name'] as String?,
    personColor: json['person_color'] as String?,
    clusterUuid: json['cluster_uuid'] as String?,
    clusterLabel: json['cluster_label'] as String?,
    confidence: json['confidence'] as num?,
    sampleUuid: json['sample_uuid'] as String?,
    hasCrop: json['has_crop'] as bool,
    additionalProperties: FaceRead._extras(json, 'additionalProperties') == null
        ? const {}
        : FaceRead._readExtras(FaceRead._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$FaceReadToJson(FaceRead instance) => <String, dynamic>{
  'status': ?FaceRead._write_status(instance.status),
  'person_uuid': instance.personUuid,
  'person_name': instance.personName,
  'person_color': instance.personColor,
  'cluster_uuid': instance.clusterUuid,
  'cluster_label': instance.clusterLabel,
  'confidence': instance.confidence,
  'sample_uuid': instance.sampleUuid,
  'has_crop': instance.hasCrop,
};
