// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing_device_create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PairingDeviceCreate _$PairingDeviceCreateFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['name'], disallowNullValues: const ['method', 'name']);
  return PairingDeviceCreate(
    host: json['host'] as String?,
    port: PairingDeviceCreate._read_port(json['port']),
    rtspPort: PairingDeviceCreate._read_rtspPort(json['rtsp_port']),
    username: json['username'] as String?,
    password: json['password'] as String?,
    adapter: json['adapter'] as String?,
    rtspUrl: json['rtsp_url'] as String?,
    deviceId: json['device_id'] as String?,
    connector: json['connector'] as String?,
    method: PairingDeviceCreate._presentValue(json, 'method') == null
        ? PairingMethodId.manualHost
        : PairingDeviceCreate._read_method(
            PairingDeviceCreate._presentValue(json, 'method') as Object,
          ),
    name: json['name'] as String,
    channels: PairingDeviceCreate._read_channels(json['channels']),
    discovered: json['discovered'] as String?,
    attempt: json['attempt'] as String?,
    additionalProperties: PairingDeviceCreate._extras(json, 'additionalProperties') == null
        ? const {}
        : PairingDeviceCreate._readExtras(
            PairingDeviceCreate._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$PairingDeviceCreateToJson(PairingDeviceCreate instance) => <String, dynamic>{
  'host': ?instance.host,
  'port': ?PairingDeviceCreate._write_port(instance.port),
  'rtsp_port': ?PairingDeviceCreate._write_rtspPort(instance.rtspPort),
  'username': ?instance.username,
  'password': ?instance.password,
  'adapter': ?instance.adapter,
  'rtsp_url': ?instance.rtspUrl,
  'device_id': ?instance.deviceId,
  'connector': ?instance.connector,
  'method': ?PairingDeviceCreate._write_method(instance.method),
  'name': instance.name,
  'channels': ?PairingDeviceCreate._write_channels(instance.channels),
  'discovered': ?instance.discovered,
  'attempt': ?instance.attempt,
};
