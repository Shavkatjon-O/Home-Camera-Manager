// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'replay_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReplayRead _$ReplayReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['active'],
    disallowNullValues: const ['active'],
  );
  return ReplayRead(
    active: json['active'] as bool,
    session: json['session'] as String?,
    stream: json['stream'] as String?,
    start: ReplayRead._read_start(json['start']),
    failure: json['failure'] as String?,
    additionalProperties:
        ReplayRead._extras(json, 'additionalProperties') == null
        ? const {}
        : ReplayRead._readExtras(
            ReplayRead._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$ReplayReadToJson(ReplayRead instance) =>
    <String, dynamic>{
      'active': instance.active,
      'session': ?instance.session,
      'stream': ?instance.stream,
      'start': ?ReplayRead._write_start(instance.start),
      'failure': ?instance.failure,
    };
