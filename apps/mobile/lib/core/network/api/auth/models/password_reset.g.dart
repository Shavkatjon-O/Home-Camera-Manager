// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_reset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PasswordReset _$PasswordResetFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['token', 'password'],
    disallowNullValues: const ['token', 'password'],
  );
  return PasswordReset(
    token: json['token'] as String,
    password: json['password'] as String,
    additionalProperties: PasswordReset._extras(json, 'additionalProperties') == null
        ? const {}
        : PasswordReset._readExtras(PasswordReset._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$PasswordResetToJson(PasswordReset instance) => <String, dynamic>{
  'token': instance.token,
  'password': instance.password,
};
