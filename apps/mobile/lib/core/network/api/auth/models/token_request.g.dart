// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenRequest _$TokenRequestFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['email', 'password'],
    disallowNullValues: const ['email', 'password', 'device_name', 'platform'],
  );
  return TokenRequest(
    email: json['email'] as String,
    password: json['password'] as String,
    deviceName: TokenRequest._presentValue(json, 'device_name') == null
        ? "Phone"
        : TokenRequest._read_deviceName(
            TokenRequest._presentValue(json, 'device_name') as Object,
          ),
    platform: TokenRequest._presentValue(json, 'platform') == null
        ? "android"
        : TokenRequest._read_platform(
            TokenRequest._presentValue(json, 'platform') as Object,
          ),
    additionalProperties:
        TokenRequest._extras(json, 'additionalProperties') == null
        ? const {}
        : TokenRequest._readExtras(
            TokenRequest._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$TokenRequestToJson(TokenRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'device_name': ?TokenRequest._write_deviceName(instance.deviceName),
      'platform': ?TokenRequest._write_platform(instance.platform),
    };
