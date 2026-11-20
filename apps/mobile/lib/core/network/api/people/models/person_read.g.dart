// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PersonRead _$PersonReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'uuid',
      'name',
      'notes',
      'color',
      'sample_count',
      'upload_count',
      'samples',
      'last_seen_at',
      'sightings',
      'created_at',
      'updated_at',
    ],
    disallowNullValues: const [
      'uuid',
      'name',
      'color',
      'sample_count',
      'upload_count',
      'samples',
      'sightings',
      'created_at',
      'updated_at',
    ],
  );
  return PersonRead(
    uuid: json['uuid'] as String,
    name: json['name'] as String,
    notes: json['notes'] as String?,
    color: json['color'] as String,
    sampleCount: PersonRead._read_sampleCount(json['sample_count']),
    uploadCount: PersonRead._read_uploadCount(json['upload_count']),
    samples: (json['samples'] as List<dynamic>)
        .map((e) => SampleRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    lastSeenAt: PersonRead._read_lastSeenAt(json['last_seen_at']),
    sightings: (json['sightings'] as List<dynamic>)
        .map((e) => SightingRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    createdAt: PersonRead._read_createdAt(json['created_at']),
    updatedAt: PersonRead._read_updatedAt(json['updated_at']),
    additionalProperties:
        PersonRead._extras(json, 'additionalProperties') == null
        ? const {}
        : PersonRead._readExtras(
            PersonRead._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$PersonReadToJson(PersonRead instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'name': instance.name,
      'notes': instance.notes,
      'color': instance.color,
      'sample_count': ?PersonRead._write_sampleCount(instance.sampleCount),
      'upload_count': ?PersonRead._write_uploadCount(instance.uploadCount),
      'samples': instance.samples.map((e) => e.toJson()).toList(),
      'last_seen_at': PersonRead._write_lastSeenAt(instance.lastSeenAt),
      'sightings': instance.sightings.map((e) => e.toJson()).toList(),
      'created_at': ?PersonRead._write_createdAt(instance.createdAt),
      'updated_at': ?PersonRead._write_updatedAt(instance.updatedAt),
    };
