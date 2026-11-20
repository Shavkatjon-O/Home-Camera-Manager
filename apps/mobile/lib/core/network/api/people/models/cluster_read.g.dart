// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cluster_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClusterRead _$ClusterReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'uuid',
      'number',
      'label',
      'seen_count',
      'first_seen_at',
      'last_seen_at',
      'samples',
      'sightings',
      'created_at',
      'updated_at',
    ],
    disallowNullValues: const [
      'uuid',
      'number',
      'label',
      'seen_count',
      'first_seen_at',
      'last_seen_at',
      'samples',
      'sightings',
      'created_at',
      'updated_at',
    ],
  );
  return ClusterRead(
    uuid: json['uuid'] as String,
    number: ClusterRead._read_number(json['number']),
    label: json['label'] as String,
    seenCount: ClusterRead._read_seenCount(json['seen_count']),
    firstSeenAt: ClusterRead._read_firstSeenAt(json['first_seen_at']),
    lastSeenAt: ClusterRead._read_lastSeenAt(json['last_seen_at']),
    samples: (json['samples'] as List<dynamic>)
        .map((e) => SampleRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    sightings: (json['sightings'] as List<dynamic>)
        .map((e) => SightingRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    createdAt: ClusterRead._read_createdAt(json['created_at']),
    updatedAt: ClusterRead._read_updatedAt(json['updated_at']),
    additionalProperties: ClusterRead._extras(json, 'additionalProperties') == null
        ? const {}
        : ClusterRead._readExtras(ClusterRead._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$ClusterReadToJson(ClusterRead instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'number': ?ClusterRead._write_number(instance.number),
  'label': instance.label,
  'seen_count': ?ClusterRead._write_seenCount(instance.seenCount),
  'first_seen_at': ?ClusterRead._write_firstSeenAt(instance.firstSeenAt),
  'last_seen_at': ?ClusterRead._write_lastSeenAt(instance.lastSeenAt),
  'samples': instance.samples.map((e) => e.toJson()).toList(),
  'sightings': instance.sightings.map((e) => e.toJson()).toList(),
  'created_at': ?ClusterRead._write_createdAt(instance.createdAt),
  'updated_at': ?ClusterRead._write_updatedAt(instance.updatedAt),
};
