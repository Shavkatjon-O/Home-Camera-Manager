// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identify_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IdentifyRequest _$IdentifyRequestFromJson(Map<String, dynamic> json) => IdentifyRequest(
  host: json['host'] as String?,
  port: IdentifyRequest._read_port(json['port']),
  rtspPort: IdentifyRequest._read_rtspPort(json['rtsp_port']),
  username: json['username'] as String?,
  password: json['password'] as String?,
  adapter: json['adapter'] as String?,
  rtspUrl: json['rtsp_url'] as String?,
  deviceId: json['device_id'] as String?,
  connector: json['connector'] as String?,
  additionalProperties: IdentifyRequest._extras(json, 'additionalProperties') == null
      ? const {}
      : IdentifyRequest._readExtras(IdentifyRequest._extras(json, 'additionalProperties')),
);

Map<String, dynamic> _$IdentifyRequestToJson(IdentifyRequest instance) => <String, dynamic>{
  'host': ?instance.host,
  'port': ?IdentifyRequest._write_port(instance.port),
  'rtsp_port': ?IdentifyRequest._write_rtspPort(instance.rtspPort),
  'username': ?instance.username,
  'password': ?instance.password,
  'adapter': ?instance.adapter,
  'rtsp_url': ?instance.rtspUrl,
  'device_id': ?instance.deviceId,
  'connector': ?instance.connector,
};
