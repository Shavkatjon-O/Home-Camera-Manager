// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identify_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IdentifyResult _$IdentifyResultFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'adapter',
      'kind',
      'vendor',
      'model',
      'rtsp_port',
      'channels',
      'capabilities',
      'attempt',
    ],
    disallowNullValues: const ['adapter', 'kind', 'channels', 'capabilities', 'attempt'],
  );
  return IdentifyResult(
    adapter: json['adapter'] as String,
    kind: json['kind'] as String,
    vendor: json['vendor'] as String?,
    model: json['model'] as String?,
    rtspPort: IdentifyResult._read_rtspPort(json['rtsp_port']),
    channels: (json['channels'] as List<dynamic>)
        .map((e) => ChannelRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    capabilities: CapabilitiesRead.fromJson(json['capabilities'] as Map<String, dynamic>),
    attempt: json['attempt'] as String,
    additionalProperties: IdentifyResult._extras(json, 'additionalProperties') == null
        ? const {}
        : IdentifyResult._readExtras(IdentifyResult._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$IdentifyResultToJson(IdentifyResult instance) => <String, dynamic>{
  'adapter': instance.adapter,
  'kind': instance.kind,
  'vendor': instance.vendor,
  'model': instance.model,
  'rtsp_port': IdentifyResult._write_rtspPort(instance.rtspPort),
  'channels': instance.channels.map((e) => e.toJson()).toList(),
  'capabilities': instance.capabilities.toJson(),
  'attempt': instance.attempt,
};
