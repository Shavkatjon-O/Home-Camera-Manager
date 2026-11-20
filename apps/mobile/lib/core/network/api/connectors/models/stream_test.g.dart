// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stream_test.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StreamTest _$StreamTestFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['host'],
    disallowNullValues: const ['host', 'brand'],
  );
  return StreamTest(
    host: json['host'] as String,
    brand: StreamTest._presentValue(json, 'brand') == null
        ? CameraBrand.onvif
        : StreamTest._read_brand(
            StreamTest._presentValue(json, 'brand') as Object,
          ),
    rtspPort: StreamTest._read_rtspPort(json['rtsp_port']),
    onvifPort: StreamTest._read_onvifPort(json['onvif_port']),
    username: json['username'] as String?,
    password: json['password'] as String?,
    mainPath: json['main_path'] as String?,
    subPath: json['sub_path'] as String?,
    additionalProperties:
        StreamTest._extras(json, 'additionalProperties') == null
        ? const {}
        : StreamTest._readExtras(
            StreamTest._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$StreamTestToJson(StreamTest instance) =>
    <String, dynamic>{
      'host': instance.host,
      'brand': ?StreamTest._write_brand(instance.brand),
      'rtsp_port': ?StreamTest._write_rtspPort(instance.rtspPort),
      'onvif_port': ?StreamTest._write_onvifPort(instance.onvifPort),
      'username': ?instance.username,
      'password': ?instance.password,
      'main_path': ?instance.mainPath,
      'sub_path': ?instance.subPath,
    };
