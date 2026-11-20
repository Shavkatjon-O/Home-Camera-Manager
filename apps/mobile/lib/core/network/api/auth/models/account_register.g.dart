// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_register.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountRegister _$AccountRegisterFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['email', 'password'],
    disallowNullValues: const ['email', 'password'],
  );
  return AccountRegister(
    email: json['email'] as String,
    password: json['password'] as String,
    name: json['name'] as String?,
    additionalProperties:
        AccountRegister._extras(json, 'additionalProperties') == null
        ? const {}
        : AccountRegister._readExtras(
            AccountRegister._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$AccountRegisterToJson(AccountRegister instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'name': ?instance.name,
    };
