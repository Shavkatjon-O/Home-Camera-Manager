// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_delete.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountDelete _$AccountDeleteFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['password'], disallowNullValues: const ['password']);
  return AccountDelete(
    password: json['password'] as String,
    additionalProperties: AccountDelete._extras(json, 'additionalProperties') == null
        ? const {}
        : AccountDelete._readExtras(AccountDelete._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$AccountDeleteToJson(AccountDelete instance) => <String, dynamic>{
  'password': instance.password,
};
