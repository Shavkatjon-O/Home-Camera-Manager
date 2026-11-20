// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceRead _$DeviceReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'uuid',
      'kind',
      'adapter',
      'name',
      'vendor',
      'model',
      'connector',
      'channel_count',
      'channels',
      'capabilities',
      'identified_at',
      'created_at',
    ],
    disallowNullValues: const [
      'uuid',
      'kind',
      'adapter',
      'name',
      'channel_count',
      'channels',
      'capabilities',
      'created_at',
    ],
  );
  return DeviceRead(
    uuid: json['uuid'] as String,
    kind: json['kind'] as String,
    adapter: json['adapter'] as String,
    name: json['name'] as String,
    vendor: json['vendor'] as String?,
    model: json['model'] as String?,
    connector: json['connector'] as String?,
    channelCount: DeviceRead._read_channelCount(json['channel_count']),
    channels: (json['channels'] as List<dynamic>)
        .map((e) => DeviceChannelRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    capabilities: CapabilitiesRead.fromJson(json['capabilities'] as Map<String, dynamic>),
    identifiedAt: DeviceRead._read_identifiedAt(json['identified_at']),
    createdAt: DeviceRead._read_createdAt(json['created_at']),
    additionalProperties: DeviceRead._extras(json, 'additionalProperties') == null
        ? const {}
        : DeviceRead._readExtras(DeviceRead._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$DeviceReadToJson(DeviceRead instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'kind': instance.kind,
  'adapter': instance.adapter,
  'name': instance.name,
  'vendor': instance.vendor,
  'model': instance.model,
  'connector': instance.connector,
  'channel_count': ?DeviceRead._write_channelCount(instance.channelCount),
  'channels': instance.channels.map((e) => e.toJson()).toList(),
  'capabilities': instance.capabilities.toJson(),
  'identified_at': DeviceRead._write_identifiedAt(instance.identifiedAt),
  'created_at': ?DeviceRead._write_createdAt(instance.createdAt),
};
