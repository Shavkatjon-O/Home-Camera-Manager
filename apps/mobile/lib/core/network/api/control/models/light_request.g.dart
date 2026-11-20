// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'light_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LightRequest _$LightRequestFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['mode'],
    disallowNullValues: const ['mode'],
  );
  return LightRequest(
    mode: json['mode'] as String,
    additionalProperties:
        LightRequest._extras(json, 'additionalProperties') == null
        ? const {}
        : LightRequest._readExtras(
            LightRequest._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$LightRequestToJson(LightRequest instance) =>
    <String, dynamic>{'mode': instance.mode};
