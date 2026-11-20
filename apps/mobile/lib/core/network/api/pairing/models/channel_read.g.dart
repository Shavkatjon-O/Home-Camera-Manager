// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChannelRead _$ChannelReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'index',
      'name',
      'main_path',
      'sub_path',
      'width',
      'height',
      'encoding',
      'ptz',
    ],
    disallowNullValues: const ['index', 'name', 'ptz'],
  );
  return ChannelRead(
    index: ChannelRead._read_index(json['index']),
    name: json['name'] as String,
    mainPath: json['main_path'] as String?,
    subPath: json['sub_path'] as String?,
    width: ChannelRead._read_width(json['width']),
    height: ChannelRead._read_height(json['height']),
    encoding: json['encoding'] as String?,
    ptz: json['ptz'] as bool,
    additionalProperties: ChannelRead._extras(json, 'additionalProperties') == null
        ? const {}
        : ChannelRead._readExtras(ChannelRead._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$ChannelReadToJson(ChannelRead instance) => <String, dynamic>{
  'index': ?ChannelRead._write_index(instance.index),
  'name': instance.name,
  'main_path': instance.mainPath,
  'sub_path': instance.subPath,
  'width': ChannelRead._write_width(instance.width),
  'height': ChannelRead._write_height(instance.height),
  'encoding': instance.encoding,
  'ptz': instance.ptz,
};
