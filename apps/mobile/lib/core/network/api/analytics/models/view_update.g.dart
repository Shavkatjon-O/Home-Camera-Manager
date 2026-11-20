// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'view_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ViewUpdate _$ViewUpdateFromJson(Map<String, dynamic> json) => ViewUpdate(
  name: json['name'] as String?,
  profile: ViewUpdate._read_profile(json['profile']),
  enabled: json['enabled'] as bool?,
  fps: json['fps'] as num?,
  tamper: json['tamper'] as bool?,
  faces: json['faces'] as bool?,
  moving: json['moving'] as bool?,
  appearance: json['appearance'] as bool?,
  falls: json['falls'] as bool?,
  plates: json['plates'] as bool?,
  follow: json['follow'] as bool?,
  stream: ViewUpdate._read_stream(json['stream']),
  additionalProperties: ViewUpdate._extras(json, 'additionalProperties') == null
      ? const {}
      : ViewUpdate._readExtras(
          ViewUpdate._extras(json, 'additionalProperties'),
        ),
);

Map<String, dynamic> _$ViewUpdateToJson(ViewUpdate instance) =>
    <String, dynamic>{
      'name': ?instance.name,
      'profile': ?ViewUpdate._write_profile(instance.profile),
      'enabled': ?instance.enabled,
      'fps': ?instance.fps,
      'tamper': ?instance.tamper,
      'faces': ?instance.faces,
      'moving': ?instance.moving,
      'appearance': ?instance.appearance,
      'falls': ?instance.falls,
      'plates': ?instance.plates,
      'follow': ?instance.follow,
      'stream': ?ViewUpdate._write_stream(instance.stream),
    };
