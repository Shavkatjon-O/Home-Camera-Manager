// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'view_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ViewRead _$ViewReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'uuid',
      'camera_uuid',
      'camera_name',
      'lens',
      'lenses',
      'name',
      'profile',
      'enabled',
      'fps',
      'tamper',
      'faces',
      'moving',
      'appearance',
      'falls',
      'plates',
      'follow',
      'stream',
      'zones',
      'lines',
      'status',
    ],
    disallowNullValues: const [
      'uuid',
      'camera_uuid',
      'camera_name',
      'lens',
      'lenses',
      'name',
      'profile',
      'enabled',
      'fps',
      'moving',
      'appearance',
      'falls',
      'plates',
      'follow',
      'stream',
      'zones',
      'lines',
    ],
  );
  return ViewRead(
    uuid: json['uuid'] as String,
    cameraUuid: json['camera_uuid'] as String,
    cameraName: json['camera_name'] as String,
    lens: ViewRead._read_lens(json['lens']),
    lenses: ViewRead._read_lenses(json['lenses']),
    name: json['name'] as String,
    profile: ViewRead._read_profile(json['profile']),
    enabled: json['enabled'] as bool,
    fps: json['fps'] as num,
    tamper: json['tamper'] as bool?,
    faces: json['faces'] as bool?,
    moving: json['moving'] as bool,
    appearance: json['appearance'] as bool,
    falls: json['falls'] as bool,
    plates: json['plates'] as bool,
    follow: json['follow'] as bool,
    stream: ViewRead._read_stream(json['stream']),
    zones: (json['zones'] as List<dynamic>)
        .map((e) => ZoneRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    lines: (json['lines'] as List<dynamic>)
        .map((e) => LineRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    status: json['status'] as Map<String, dynamic>?,
    additionalProperties: ViewRead._extras(json, 'additionalProperties') == null
        ? const {}
        : ViewRead._readExtras(ViewRead._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$ViewReadToJson(ViewRead instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'camera_uuid': instance.cameraUuid,
  'camera_name': instance.cameraName,
  'lens': ?ViewRead._write_lens(instance.lens),
  'lenses': ?ViewRead._write_lenses(instance.lenses),
  'name': instance.name,
  'profile': ?ViewRead._write_profile(instance.profile),
  'enabled': instance.enabled,
  'fps': instance.fps,
  'tamper': instance.tamper,
  'faces': instance.faces,
  'moving': instance.moving,
  'appearance': instance.appearance,
  'falls': instance.falls,
  'plates': instance.plates,
  'follow': instance.follow,
  'stream': ?ViewRead._write_stream(instance.stream),
  'zones': instance.zones.map((e) => e.toJson()).toList(),
  'lines': instance.lines.map((e) => e.toJson()).toList(),
  'status': instance.status,
};
