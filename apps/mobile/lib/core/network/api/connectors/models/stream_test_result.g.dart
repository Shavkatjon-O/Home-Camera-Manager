// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stream_test_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StreamTestResult _$StreamTestResultFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['ok'], disallowNullValues: const ['ok']);
  return StreamTestResult(
    ok: json['ok'] as bool,
    error: json['error'] as String?,
    rtspPort: StreamTestResult._read_rtspPort(json['rtsp_port']),
    mainPath: json['main_path'] as String?,
    subPath: json['sub_path'] as String?,
    ptz: json['ptz'] as bool?,
    manufacturer: json['manufacturer'] as String?,
    model: json['model'] as String?,
    additionalProperties: StreamTestResult._extras(json, 'additionalProperties') == null
        ? const {}
        : StreamTestResult._readExtras(StreamTestResult._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$StreamTestResultToJson(StreamTestResult instance) => <String, dynamic>{
  'ok': instance.ok,
  'error': ?instance.error,
  'rtsp_port': ?StreamTestResult._write_rtspPort(instance.rtspPort),
  'main_path': ?instance.mainPath,
  'sub_path': ?instance.subPath,
  'ptz': ?instance.ptz,
  'manufacturer': ?instance.manufacturer,
  'model': ?instance.model,
};
