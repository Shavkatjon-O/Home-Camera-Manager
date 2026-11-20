// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camera_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CameraUpdate _$CameraUpdateFromJson(Map<String, dynamic> json) => CameraUpdate(
  name: json['name'] as String?,
  brand: CameraUpdate._read_brand(json['brand']),
  host: json['host'] as String?,
  deviceHost: json['device_host'] as String?,
  location: json['location'] as String?,
  rtspPort: CameraUpdate._read_rtspPort(json['rtsp_port']),
  onvifPort: CameraUpdate._read_onvifPort(json['onvif_port']),
  username: json['username'] as String?,
  password: json['password'] as String?,
  mainPath: json['main_path'] as String?,
  subPath: json['sub_path'] as String?,
  lenses: CameraUpdate._read_lenses(json['lenses']),
  ptzEnabled: json['ptz_enabled'] as bool?,
  enabled: json['enabled'] as bool?,
  additionalProperties: CameraUpdate._extras(json, 'additionalProperties') == null
      ? const {}
      : CameraUpdate._readExtras(CameraUpdate._extras(json, 'additionalProperties')),
);

Map<String, dynamic> _$CameraUpdateToJson(CameraUpdate instance) => <String, dynamic>{
  'name': ?instance.name,
  'brand': ?CameraUpdate._write_brand(instance.brand),
  'host': ?instance.host,
  'device_host': ?instance.deviceHost,
  'location': ?instance.location,
  'rtsp_port': ?CameraUpdate._write_rtspPort(instance.rtspPort),
  'onvif_port': ?CameraUpdate._write_onvifPort(instance.onvifPort),
  'username': ?instance.username,
  'password': ?instance.password,
  'main_path': ?instance.mainPath,
  'sub_path': ?instance.subPath,
  'lenses': ?CameraUpdate._write_lenses(instance.lenses),
  'ptz_enabled': ?instance.ptzEnabled,
  'enabled': ?instance.enabled,
};
