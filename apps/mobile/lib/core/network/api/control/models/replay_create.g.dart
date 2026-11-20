// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'replay_create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReplayCreate _$ReplayCreateFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['start'], disallowNullValues: const ['start']);
  return ReplayCreate(
    start: ReplayCreate._read_start(json['start']),
    session: json['session'] as String?,
    additionalProperties: ReplayCreate._extras(json, 'additionalProperties') == null
        ? const {}
        : ReplayCreate._readExtras(ReplayCreate._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$ReplayCreateToJson(ReplayCreate instance) => <String, dynamic>{
  'start': ?ReplayCreate._write_start(instance.start),
  'session': ?instance.session,
};
