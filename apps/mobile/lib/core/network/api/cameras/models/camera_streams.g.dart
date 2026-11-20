// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camera_streams.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CameraStreams _$CameraStreamsFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['main', 'sub'],
    disallowNullValues: const ['main'],
  );
  return CameraStreams(
    main: json['main'] as String,
    sub: json['sub'] as String?,
    additionalProperties:
        CameraStreams._extras(json, 'additionalProperties') == null
        ? const {}
        : CameraStreams._readExtras(
            CameraStreams._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$CameraStreamsToJson(CameraStreams instance) =>
    <String, dynamic>{'main': instance.main, 'sub': instance.sub};
