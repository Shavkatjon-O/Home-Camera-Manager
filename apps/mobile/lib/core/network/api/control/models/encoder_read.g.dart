// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'encoder_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EncoderRead _$EncoderReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'token',
      'name',
      'profiles',
      'encoding',
      'width',
      'height',
      'fps',
      'bitrate',
      'gop',
      'quality',
      'profile',
      'options',
    ],
    disallowNullValues: const ['token', 'name', 'profiles', 'options'],
  );
  return EncoderRead(
    token: json['token'] as String,
    name: json['name'] as String,
    profiles: (json['profiles'] as List<dynamic>)
        .map((e) => e as String)
        .toList(),
    encoding: json['encoding'] as String?,
    width: EncoderRead._read_width(json['width']),
    height: EncoderRead._read_height(json['height']),
    fps: json['fps'] as num?,
    bitrate: EncoderRead._read_bitrate(json['bitrate']),
    gop: EncoderRead._read_gop(json['gop']),
    quality: json['quality'] as num?,
    profile: json['profile'] as String?,
    options: (json['options'] as List<dynamic>)
        .map((e) => EncoderOptionsRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    additionalProperties:
        EncoderRead._extras(json, 'additionalProperties') == null
        ? const {}
        : EncoderRead._readExtras(
            EncoderRead._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$EncoderReadToJson(EncoderRead instance) =>
    <String, dynamic>{
      'token': instance.token,
      'name': instance.name,
      'profiles': instance.profiles,
      'encoding': instance.encoding,
      'width': EncoderRead._write_width(instance.width),
      'height': EncoderRead._write_height(instance.height),
      'fps': instance.fps,
      'bitrate': EncoderRead._write_bitrate(instance.bitrate),
      'gop': EncoderRead._write_gop(instance.gop),
      'quality': instance.quality,
      'profile': instance.profile,
      'options': instance.options.map((e) => e.toJson()).toList(),
    };
