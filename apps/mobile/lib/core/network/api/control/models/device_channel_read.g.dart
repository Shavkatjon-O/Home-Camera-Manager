// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_channel_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceChannelRead _$DeviceChannelReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['camera', 'channel', 'name', 'enabled'],
    disallowNullValues: const ['camera', 'channel', 'name', 'enabled'],
  );
  return DeviceChannelRead(
    camera: json['camera'] as String,
    channel: DeviceChannelRead._read_channel(json['channel']),
    name: json['name'] as String,
    enabled: json['enabled'] as bool,
    additionalProperties:
        DeviceChannelRead._extras(json, 'additionalProperties') == null
        ? const {}
        : DeviceChannelRead._readExtras(
            DeviceChannelRead._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$DeviceChannelReadToJson(DeviceChannelRead instance) =>
    <String, dynamic>{
      'camera': instance.camera,
      'channel': ?DeviceChannelRead._write_channel(instance.channel),
      'name': instance.name,
      'enabled': instance.enabled,
    };
