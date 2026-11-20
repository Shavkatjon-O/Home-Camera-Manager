// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camera_create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CameraCreate _$CameraCreateFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['name', 'brand', 'host'],
    disallowNullValues: const ['name', 'brand', 'host', 'lenses', 'enabled'],
  );
  return CameraCreate(
    name: json['name'] as String,
    brand: CameraCreate._read_brand(json['brand']),
    host: json['host'] as String,
    deviceHost: json['device_host'] as String?,
    location: json['location'] as String?,
    rtspPort: CameraCreate._read_rtspPort(json['rtsp_port']),
    onvifPort: CameraCreate._read_onvifPort(json['onvif_port']),
    username: json['username'] as String?,
    password: json['password'] as String?,
    mainPath: json['main_path'] as String?,
    subPath: json['sub_path'] as String?,
    lenses: CameraCreate._presentValue(json, 'lenses') == null
        ? 1
        : CameraCreate._read_lenses(
            CameraCreate._presentValue(json, 'lenses') as Object,
          ),
    ptzEnabled: json['ptz_enabled'] as bool?,
    enabled: CameraCreate._presentValue(json, 'enabled') == null
        ? true
        : CameraCreate._read_enabled(
            CameraCreate._presentValue(json, 'enabled') as Object,
          ),
    connector: json['connector'] as String?,
    additionalProperties:
        CameraCreate._extras(json, 'additionalProperties') == null
        ? const {}
        : CameraCreate._readExtras(
            CameraCreate._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$CameraCreateToJson(CameraCreate instance) =>
    <String, dynamic>{
      'name': instance.name,
      'brand': ?CameraCreate._write_brand(instance.brand),
      'host': instance.host,
      'device_host': ?instance.deviceHost,
      'location': ?instance.location,
      'rtsp_port': ?CameraCreate._write_rtspPort(instance.rtspPort),
      'onvif_port': ?CameraCreate._write_onvifPort(instance.onvifPort),
      'username': ?instance.username,
      'password': ?instance.password,
      'main_path': ?instance.mainPath,
      'sub_path': ?instance.subPath,
      'lenses': ?CameraCreate._write_lenses(instance.lenses),
      'ptz_enabled': ?instance.ptzEnabled,
      'enabled': ?CameraCreate._write_enabled(instance.enabled),
      'connector': ?instance.connector,
    };
