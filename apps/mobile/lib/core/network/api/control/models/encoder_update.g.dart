// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'encoder_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EncoderUpdate _$EncoderUpdateFromJson(Map<String, dynamic> json) =>
    EncoderUpdate(
      encoding: json['encoding'] as String?,
      width: EncoderUpdate._read_width(json['width']),
      height: EncoderUpdate._read_height(json['height']),
      fps: json['fps'] as num?,
      bitrate: EncoderUpdate._read_bitrate(json['bitrate']),
      gop: EncoderUpdate._read_gop(json['gop']),
      quality: json['quality'] as num?,
      profile: json['profile'] as String?,
      additionalProperties:
          EncoderUpdate._extras(json, 'additionalProperties') == null
          ? const {}
          : EncoderUpdate._readExtras(
              EncoderUpdate._extras(json, 'additionalProperties'),
            ),
    );

Map<String, dynamic> _$EncoderUpdateToJson(EncoderUpdate instance) =>
    <String, dynamic>{
      'encoding': ?instance.encoding,
      'width': ?EncoderUpdate._write_width(instance.width),
      'height': ?EncoderUpdate._write_height(instance.height),
      'fps': ?instance.fps,
      'bitrate': ?EncoderUpdate._write_bitrate(instance.bitrate),
      'gop': ?EncoderUpdate._write_gop(instance.gop),
      'quality': ?instance.quality,
      'profile': ?instance.profile,
    };
