// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camera_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CameraOrder _$CameraOrderFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['uuids'], disallowNullValues: const ['uuids']);
  return CameraOrder(
    uuids: (json['uuids'] as List<dynamic>).map((e) => e as String).toList(),
    additionalProperties: CameraOrder._extras(json, 'additionalProperties') == null
        ? const {}
        : CameraOrder._readExtras(CameraOrder._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$CameraOrderToJson(CameraOrder instance) => <String, dynamic>{
  'uuids': instance.uuids,
};
