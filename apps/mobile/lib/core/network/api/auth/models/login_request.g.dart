// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['username', 'password'],
    disallowNullValues: const ['username', 'password'],
  );
  return LoginRequest(
    username: json['username'] as String,
    password: json['password'] as String,
    additionalProperties: LoginRequest._extras(json, 'additionalProperties') == null
        ? const {}
        : LoginRequest._readExtras(LoginRequest._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) => <String, dynamic>{
  'username': instance.username,
  'password': instance.password,
};
