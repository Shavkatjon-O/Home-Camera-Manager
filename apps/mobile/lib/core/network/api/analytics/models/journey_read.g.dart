// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journey_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JourneyRead _$JourneyReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'uuid',
      'description',
      'started_at',
      'ended_at',
      'steps',
    ],
    disallowNullValues: const [
      'uuid',
      'description',
      'started_at',
      'ended_at',
      'steps',
    ],
  );
  return JourneyRead(
    uuid: json['uuid'] as String,
    description: json['description'] as String,
    startedAt: JourneyRead._read_startedAt(json['started_at']),
    endedAt: JourneyRead._read_endedAt(json['ended_at']),
    steps: (json['steps'] as List<dynamic>)
        .map((e) => JourneyStepRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    additionalProperties:
        JourneyRead._extras(json, 'additionalProperties') == null
        ? const {}
        : JourneyRead._readExtras(
            JourneyRead._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$JourneyReadToJson(JourneyRead instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'description': instance.description,
      'started_at': ?JourneyRead._write_startedAt(instance.startedAt),
      'ended_at': ?JourneyRead._write_endedAt(instance.endedAt),
      'steps': instance.steps.map((e) => e.toJson()).toList(),
    };
