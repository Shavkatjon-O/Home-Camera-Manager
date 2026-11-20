// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'encoder_options_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EncoderOptionsRead _$EncoderOptionsReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'encoding',
      'resolutions',
      'fps_values',
      'fps',
      'bitrate',
      'gop',
      'quality',
      'profiles',
    ],
    disallowNullValues: const ['encoding', 'resolutions', 'fps_values', 'profiles'],
  );
  return EncoderOptionsRead(
    encoding: json['encoding'] as String,
    resolutions: (json['resolutions'] as List<dynamic>)
        .map((e) => ResolutionRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    fpsValues: (json['fps_values'] as List<dynamic>).map((e) => e as num).toList(),
    fps: json['fps'] == null ? null : RangeRead.fromJson(json['fps'] as Map<String, dynamic>),
    bitrate: json['bitrate'] == null
        ? null
        : RangeRead.fromJson(json['bitrate'] as Map<String, dynamic>),
    gop: json['gop'] == null ? null : RangeRead.fromJson(json['gop'] as Map<String, dynamic>),
    quality: json['quality'] == null
        ? null
        : RangeRead.fromJson(json['quality'] as Map<String, dynamic>),
    profiles: (json['profiles'] as List<dynamic>).map((e) => e as String).toList(),
    additionalProperties: EncoderOptionsRead._extras(json, 'additionalProperties') == null
        ? const {}
        : EncoderOptionsRead._readExtras(EncoderOptionsRead._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$EncoderOptionsReadToJson(EncoderOptionsRead instance) => <String, dynamic>{
  'encoding': instance.encoding,
  'resolutions': instance.resolutions.map((e) => e.toJson()).toList(),
  'fps_values': instance.fpsValues,
  'fps': instance.fps?.toJson(),
  'bitrate': instance.bitrate?.toJson(),
  'gop': instance.gop?.toJson(),
  'quality': instance.quality?.toJson(),
  'profiles': instance.profiles,
};
